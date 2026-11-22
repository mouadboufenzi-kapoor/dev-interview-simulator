package com.interview.simulator.analytics.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.HexFormat;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class SimulationCreationRateLimiter {

    static final int MAX_TRACKED_CLIENTS = 10_000;

    private final int guestLimit;
    private final int userLimit;
    private final long windowMs;
    private final ConcurrentHashMap<String, Window> windows = new ConcurrentHashMap<>();

    public SimulationCreationRateLimiter(
            @Value("${app.simulation.rate-limit.guest-limit:30}") int guestLimit,
            @Value("${app.simulation.rate-limit.user-limit:120}") int userLimit,
            @Value("${app.simulation.rate-limit.window:PT1H}") Duration window) {
        this.guestLimit = guestLimit;
        this.userLimit = userLimit;
        this.windowMs = window.toMillis();
    }

    public Decision allow(String clientKey, boolean authenticated) {
        return allow(clientKey, authenticated, System.currentTimeMillis());
    }

    Decision allow(String clientKey, boolean authenticated, long now) {
        int limit = authenticated ? userLimit : guestLimit;
        Window window = windows.compute(hash(clientKey), (key, current) ->
                current == null || now - current.start() >= windowMs
                        ? new Window(now, 1)
                        : new Window(current.start(), current.count() + 1));
        if (windows.size() > MAX_TRACKED_CLIENTS) {
            windows.entrySet().removeIf(entry -> now - entry.getValue().start() >= windowMs);
        }
        if (window.count() <= limit) {
            return new Decision(true, 0L);
        }
        long remainingMs = Math.max(0L, windowMs - (now - window.start()));
        return new Decision(false, Math.max(1L, (remainingMs + 999L) / 1000L));
    }

    int trackedClients() {
        return windows.size();
    }

    private String hash(String clientKey) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest((clientKey == null ? "unknown" : clientKey)
                            .getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 indisponible.", exception);
        }
    }

    public record Decision(boolean allowed, long retryAfterSeconds) {
    }

    private record Window(long start, int count) {
    }
}
