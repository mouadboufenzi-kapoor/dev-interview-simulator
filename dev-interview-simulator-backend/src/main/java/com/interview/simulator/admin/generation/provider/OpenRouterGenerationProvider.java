package com.interview.simulator.admin.generation.provider;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.exception.ApiException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Service
public class OpenRouterGenerationProvider implements LLMGenerationProvider {

    private static final Logger logger = LoggerFactory.getLogger(OpenRouterGenerationProvider.class);
    private static final Duration CONNECT_TIMEOUT = Duration.ofSeconds(10);
    private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(60);
    private static final String CHAT_COMPLETIONS_PATH = "/chat/completions";
    private static final int SUCCESS_STATUS = 200;

    private final boolean enabled;
    private final String apiKey;
    private final String model;
    private final String baseUrl;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public OpenRouterGenerationProvider(
            @Value("${app.generation.enabled:true}") boolean enabled,
            @Value("${app.generation.openrouter.api-key:}") String apiKey,
            @Value("${app.generation.openrouter.model:openai/gpt-oss-120b}") String model,
            @Value("${app.generation.openrouter.base-url:https://openrouter.ai/api/v1}") String baseUrl,
            ObjectMapper objectMapper) {
        this.enabled = enabled;
        this.apiKey = apiKey;
        this.model = model;
        this.baseUrl = baseUrl;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder().connectTimeout(CONNECT_TIMEOUT).build();
    }

    @Override
    public boolean isConfigured() {
        return enabled && apiKey != null && !apiKey.isBlank();
    }

    @Override
    public String providerName() {
        return "openrouter";
    }

    @Override
    public String generateText(String prompt) {
        return generateText(prompt, null);
    }

    @Override
    public String generateText(String prompt, String requestedModel) {
        HttpResponse<String> response;
        try {
            response = httpClient.send(buildRequest(prompt, requestedModel), HttpResponse.BodyHandlers.ofString());
        } catch (HttpTimeoutException e) {
            throw new ApiException(HttpStatus.GATEWAY_TIMEOUT,
                    "Le service de génération n'a pas répondu à temps.");
        } catch (IOException e) {
            throw new ApiException(HttpStatus.BAD_GATEWAY, "Le service de génération est injoignable.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ApiException(HttpStatus.BAD_GATEWAY, "La génération a été interrompue.");
        }
        if (response.statusCode() != SUCCESS_STATUS) {
            logger.warn("Le fournisseur de génération a répondu avec le statut HTTP {}", response.statusCode());
            throw providerError(response.statusCode());
        }
        return extractText(response.body());
    }

    static ApiException providerError(int statusCode) {
        return switch (statusCode) {
            case 429 -> new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                    "Quota de génération épuisé ou limite de débit atteinte : réessayez plus tard ou vérifiez le quota du compte du fournisseur.");
            case 401, 403 -> new ApiException(HttpStatus.BAD_GATEWAY,
                    "Le fournisseur de génération a refusé la clé API configurée.");
            case 404 -> new ApiException(HttpStatus.BAD_GATEWAY,
                    "Le modèle de génération configuré est introuvable.");
            default -> new ApiException(HttpStatus.BAD_GATEWAY, "Le fournisseur de génération est indisponible.");
        };
    }

    private HttpRequest buildRequest(String prompt, String requestedModel) {
        String effectiveModel = requestedModel == null || requestedModel.isBlank() ? model : requestedModel;
        return HttpRequest.newBuilder(URI.create(baseUrl + CHAT_COMPLETIONS_PATH))
                .timeout(REQUEST_TIMEOUT)
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(payload(prompt, effectiveModel)))
                .build();
    }

    private String payload(String prompt, String effectiveModel) {
        try {
            return objectMapper.writeValueAsString(Map.of(
                    "model", effectiveModel,
                    "messages", List.of(Map.of("role", "user", "content", prompt)),
                    "response_format", Map.of("type", "json_object")));
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Construction du corps de requête générique échouée.", e);
        }
    }

    private String extractText(String body) {
        try {
            JsonNode text = objectMapper.readTree(body)
                    .path("choices").path(0).path("message").path("content");
            if (!text.isTextual() || text.asText().isBlank()) {
                throw new ApiException(HttpStatus.BAD_GATEWAY,
                        "Le fournisseur de génération a renvoyé une réponse vide.");
            }
            return text.asText();
        } catch (JsonProcessingException e) {
            throw new ApiException(HttpStatus.BAD_GATEWAY,
                    "Le fournisseur de génération a renvoyé une réponse illisible.");
        }
    }
}
