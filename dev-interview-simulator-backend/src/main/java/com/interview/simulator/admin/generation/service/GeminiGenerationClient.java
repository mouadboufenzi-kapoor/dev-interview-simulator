package com.interview.simulator.admin.generation.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.admin.generation.provider.LLMGenerationProvider;
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
public class GeminiGenerationClient implements LLMGenerationProvider {

    private static final Logger logger = LoggerFactory.getLogger(GeminiGenerationClient.class);

    private static final Duration CONNECT_TIMEOUT = Duration.ofSeconds(10);
    private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(60);
    private static final String API_KEY_HEADER = "x-goog-api-key";
    private static final String CONTENT_TYPE_HEADER = "Content-Type";
    private static final String APPLICATION_JSON = "application/json";
    private static final String GENERATE_PATH_FORMAT = "/models/%s:generateContent";
    private static final String RESPONSE_MIME_TYPE = "application/json";
    private static final int SUCCESS_STATUS = 200;
    private static final int QUOTA_STATUS = 429;
    private static final int AUTH_STATUS = 401;
    private static final int FORBIDDEN_STATUS = 403;
    private static final int MODEL_NOT_FOUND_STATUS = 404;

    private final boolean enabled;
    private final String apiKey;
    private final String model;
    private final String baseUrl;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public GeminiGenerationClient(
            @Value("${app.generation.enabled:true}") boolean enabled,
            @Value("${app.generation.gemini.api-key:}") String apiKey,
            @Value("${app.generation.gemini.model:gemini-3.8-flash}") String model,
            @Value("${app.generation.gemini.base-url:https://generativelanguage.googleapis.com/v1beta}") String baseUrl,
            ObjectMapper objectMapper) {
        this.enabled = enabled;
        this.apiKey = apiKey;
        this.model = model;
        this.baseUrl = baseUrl;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder().connectTimeout(CONNECT_TIMEOUT).build();
    }

    public boolean isConfigured() {
        return enabled && apiKey != null && !apiKey.isBlank();
    }

    public String generateText(String prompt) {
        return generateText(prompt, null);
    }

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
            case QUOTA_STATUS -> new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                    "Quota de génération épuisé ou limite de débit atteinte : réessayez plus tard ou vérifiez le quota du compte du fournisseur.");
            case AUTH_STATUS, FORBIDDEN_STATUS -> new ApiException(HttpStatus.BAD_GATEWAY,
                    "Le fournisseur de génération a refusé la clé API configurée.");
            case MODEL_NOT_FOUND_STATUS -> new ApiException(HttpStatus.BAD_GATEWAY,
                    "Le modèle de génération configuré est introuvable.");
            default -> new ApiException(HttpStatus.BAD_GATEWAY, "Le fournisseur de génération est indisponible.");
        };
    }

    private HttpRequest buildRequest(String prompt, String requestedModel) {
        String effectiveModel = requestedModel == null || requestedModel.isBlank() ? model : requestedModel;
        return HttpRequest.newBuilder(URI.create(baseUrl + String.format(GENERATE_PATH_FORMAT, effectiveModel)))
                .timeout(REQUEST_TIMEOUT)
                .header(API_KEY_HEADER, apiKey)
                .header(CONTENT_TYPE_HEADER, APPLICATION_JSON)
                .POST(HttpRequest.BodyPublishers.ofString(payload(prompt)))
                .build();
    }

    private String payload(String prompt) {
        try {
            return objectMapper.writeValueAsString(Map.of(
                    "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt)))),
                    "generationConfig", Map.of("responseMimeType", RESPONSE_MIME_TYPE)));
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Construction du corps de requête générique échouée.", e);
        }
    }

    private String extractText(String body) {
        try {
            JsonNode text = objectMapper.readTree(body)
                    .path("candidates").path(0).path("content").path("parts").path(0).path("text");
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
