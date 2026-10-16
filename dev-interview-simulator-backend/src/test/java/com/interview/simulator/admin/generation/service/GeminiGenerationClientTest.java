package com.interview.simulator.admin.generation.service;

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

class GeminiGenerationClientTest {

    private static final String API_KEY = "cle-de-test";
    private static final String MODEL = "gemini-test";

    private HttpServer server;
    private String baseUrl;
    private volatile int lastStatusCode;
    private volatile String lastBody;
    private volatile String lastPath;
    private volatile String lastApiKeyHeader;

    @BeforeEach
    void setUp() throws IOException {
        server = HttpServer.create(new InetSocketAddress(0), 0);
        server.createContext("/", exchange -> {
            lastPath = exchange.getRequestURI().getPath();
            lastApiKeyHeader = exchange.getRequestHeaders().getFirst("x-goog-api-key");
            byte[] payload = lastBody == null
                    ? new byte[0]
                    : lastBody.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().add("Content-Type", "application/json");
            exchange.sendResponseHeaders(lastStatusCode, payload.length);
            try (OutputStream out = exchange.getResponseBody()) {
                out.write(payload);
            }
        });
        server.start();
        baseUrl = "http://localhost:" + server.getAddress().getPort() + "/v1beta";
    }

    @AfterEach
    void tearDown() {
        server.stop(0);
    }

    @Test
    void isConfigured_ShouldBeFalseWithoutKeyOrWhenDisabled() {
        assertFalse(client(true, "").isConfigured());
        assertFalse(client(false, API_KEY).isConfigured());
        assertTrue(client(true, API_KEY).isConfigured());
    }

    @Test
    void generateText_ShouldSendKeyInHeaderAndExtractCandidateText() {
        respond(200, """
                {"candidates":[{"content":{"parts":[{"text":"{\\"questions\\":[]}"}]}}]}
                """);

        String text = client(true, API_KEY).generateText("prompt");

        assertEquals("{\"questions\":[]}", text);
        assertEquals("/v1beta/models/" + MODEL + ":generateContent", lastPath);
        assertEquals(API_KEY, lastApiKeyHeader);
    }

    @Test
    void generateText_ShouldMapQuotaExhaustedTo429() {
        respond(429, "{}");

        ApiException exception = assertThrows(ApiException.class,
                () -> client(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.TOO_MANY_REQUESTS, exception.getStatus());
        assertTrue(exception.getMessage().contains("Quota"));
    }

    @Test
    void generateText_ShouldMapRejectedKeyToBadGateway() {
        respond(403, "{\"error\":{\"message\":\"API key not valid\"}}");

        ApiException exception = assertThrows(ApiException.class,
                () -> client(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        assertFalse(exception.getMessage().contains(API_KEY));
        assertFalse(exception.getMessage().contains("not valid"));
    }

    @Test
    void generateText_ShouldMapUnknownModelToBadGateway() {
        respond(404, "{}");

        ApiException exception = assertThrows(ApiException.class,
                () -> client(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        assertTrue(exception.getMessage().contains("modèle"));
    }

    @Test
    void generateText_ShouldRejectUnreadableBody() {
        respond(200, "pas-du-json");

        ApiException exception = assertThrows(ApiException.class,
                () -> client(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
    }

    @Test
    void generateText_ShouldRejectEmptyCandidate() {
        respond(200, "{\"candidates\":[]}");

        ApiException exception = assertThrows(ApiException.class,
                () -> client(true, API_KEY).generateText("prompt"));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        assertTrue(exception.getMessage().contains("vide"));
    }

    @Test
    void providerError_ShouldCoverAllFamilies() {
        assertEquals(HttpStatus.TOO_MANY_REQUESTS, GeminiGenerationClient.providerError(429).getStatus());
        assertEquals(HttpStatus.BAD_GATEWAY, GeminiGenerationClient.providerError(401).getStatus());
        assertEquals(HttpStatus.BAD_GATEWAY, GeminiGenerationClient.providerError(403).getStatus());
        assertEquals(HttpStatus.BAD_GATEWAY, GeminiGenerationClient.providerError(404).getStatus());
        assertEquals(HttpStatus.BAD_GATEWAY, GeminiGenerationClient.providerError(500).getStatus());
        assertEquals(HttpStatus.BAD_GATEWAY, GeminiGenerationClient.providerError(503).getStatus());
    }

    private GeminiGenerationClient client(boolean enabled, String apiKey) {
        return new GeminiGenerationClient(enabled, apiKey, MODEL, baseUrl, new ObjectMapper());
    }

    private void respond(int statusCode, String body) {
        this.lastStatusCode = statusCode;
        this.lastBody = body;
    }
}
