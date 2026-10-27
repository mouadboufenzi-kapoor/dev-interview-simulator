package com.interview.simulator.admin.generation.provider;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.exception.ApiException;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class OpenRouterGenerationProviderTest {

    private static final String API_KEY = "cle-de-test";
    private static final String MODEL = "provider/model-test";

    private HttpServer server;
    private String baseUrl;
    private volatile int responseStatus;
    private volatile String responseBody;
    private volatile String receivedRequestBody;
    private volatile String authorizationHeader;
    private volatile String requestPath;

    @BeforeEach
    void setUp() throws IOException {
        server = HttpServer.create(new InetSocketAddress(0), 0);
        server.createContext("/", exchange -> {
            requestPath = exchange.getRequestURI().getPath();
            authorizationHeader = exchange.getRequestHeaders().getFirst("Authorization");
            receivedRequestBody = new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8);
            byte[] payload = responseBody.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().add("Content-Type", "application/json");
            exchange.sendResponseHeaders(responseStatus, payload.length);
            try (OutputStream out = exchange.getResponseBody()) {
                out.write(payload);
            }
        });
        server.start();
        baseUrl = "http://localhost:" + server.getAddress().getPort() + "/api/v1";
    }

    @AfterEach
    void tearDown() {
        server.stop(0);
    }

    @Test
    void isConfigured_ShouldRequireEnabledAndKey() {
        assertFalse(provider(true, "").isConfigured());
        assertFalse(provider(false, API_KEY).isConfigured());
        assertTrue(provider(true, API_KEY).isConfigured());
    }

    @Test
    void generateText_ShouldSendBearerKeyAndJsonObjectFormat() throws Exception {
        respond(200, """
                {"choices":[{"message":{"content":"{\\"questions\\":[]}"}}]}
                """);

        String result = provider(true, API_KEY).generateText("prompt", MODEL);

        JsonNode request = new ObjectMapper().readTree(receivedRequestBody);
        assertEquals("{\"questions\":[]}", result);
        assertEquals("/api/v1/chat/completions", requestPath);
        assertEquals("Bearer " + API_KEY, authorizationHeader);
        assertEquals(MODEL, request.path("model").asText());
        assertEquals("json_object", request.path("response_format").path("type").asText());
    }

    @Test
    void generateText_ShouldMapRateLimitTo429() {
        respond(429, "{}");

        ApiException exception = assertThrows(ApiException.class,
                () -> provider(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.TOO_MANY_REQUESTS, exception.getStatus());
    }

    @Test
    void generateText_ShouldNotExposeProviderBodyOrKeyOnAuthenticationFailure() {
        respond(401, "{\"error\":{\"message\":\"private details\"}}");

        ApiException exception = assertThrows(ApiException.class,
                () -> provider(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        assertFalse(exception.getMessage().contains(API_KEY));
        assertFalse(exception.getMessage().contains("private details"));
    }

    @Test
    void generateText_ShouldRejectUnreadableCompletion() {
        respond(200, "not-json");

        ApiException exception = assertThrows(ApiException.class,
                () -> provider(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
    }

    private OpenRouterGenerationProvider provider(boolean enabled, String apiKey) {
        return new OpenRouterGenerationProvider(enabled, apiKey, MODEL, baseUrl, new ObjectMapper());
    }

    private void respond(int status, String body) {
        responseStatus = status;
        responseBody = body;
    }
}
