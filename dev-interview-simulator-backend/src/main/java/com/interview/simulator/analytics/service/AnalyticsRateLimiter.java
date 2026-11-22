package com.interview.simulator.analytics.service;

import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class AnalyticsRateLimiter {

    private static final int MAX_REQUESTS_PER_WINDOW = 60;
    private static final long WINDOW_MS = 60_000L;
    private static final int MAX_TRACKED_CLIENTS = 10_000;

    private final ConcurrentHashMap<String, Window> windows = new ConcurrentHashMap<>();

    public boolean allow(String clientAddress) {
        long now = System.currentTimeMillis();
        Window window = windows.compute(hash(clientAddress), (key, current) ->
                current == null || now - current.start() >= WINDOW_MS
                        ? new Window(now, 1)
                        : new Window(current.start(), current.count() + 1));
        if (windows.size() > MAX_TRACKED_CLIENTS) {
            windows.entrySet().removeIf(entry -> now - entry.getValue().start() >= WINDOW_MS);
        }
        return window.count() <= MAX_REQUESTS_PER_WINDOW;
    }

    private String hash(String clientAddress) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest((clientAddress == null ? "unknown" : clientAddress)
                            .getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 indisponible.", exception);
        }
    }

    private record Window(long start, int count) {
    }
}
