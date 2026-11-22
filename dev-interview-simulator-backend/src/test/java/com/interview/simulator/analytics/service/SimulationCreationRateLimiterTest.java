package com.interview.simulator.analytics.service;

import org.junit.jupiter.api.Test;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SimulationCreationRateLimiterTest {

    private static final long NOW = 1_700_000_000_000L;
    private static final long WINDOW_MS = Duration.ofHours(1).toMillis();
    private static final int GUEST_LIMIT = 30;
    private static final int USER_LIMIT = 120;

    private final SimulationCreationRateLimiter limiter =
            new SimulationCreationRateLimiter(GUEST_LIMIT, USER_LIMIT, Duration.ofHours(1));

    @Test
    void guestStaysAllowedUpToTheLimit() {
        for (int index = 0; index < GUEST_LIMIT; index++) {
            assertTrue(limiter.allow("ip:203.0.113.7", false, NOW).allowed());
        }

        SimulationCreationRateLimiter.Decision decision =
                limiter.allow("ip:203.0.113.7", false, NOW);

        assertFalse(decision.allowed());
        assertEquals(3600L, decision.retryAfterSeconds());
    }

    @Test
    void windowResetsAfterOneHour() {
        for (int index = 0; index < GUEST_LIMIT; index++) {
            limiter.allow("ip:203.0.113.7", false, NOW);
        }
        assertFalse(limiter.allow("ip:203.0.113.7", false, NOW).allowed());

        assertTrue(limiter.allow("ip:203.0.113.7", false, NOW + WINDOW_MS).allowed());
    }

    @Test
    void separateIpsAndUsersHaveIndependentCounters() {
        for (int index = 0; index < GUEST_LIMIT; index++) {
            assertTrue(limiter.allow("ip:203.0.113.7", false, NOW).allowed());
        }

        assertFalse(limiter.allow("ip:203.0.113.7", false, NOW).allowed());
        assertTrue(limiter.allow("ip:198.51.100.9", false, NOW).allowed());
        assertTrue(limiter.allow("user:1", true, NOW).allowed());
        assertTrue(limiter.allow("user:2", true, NOW).allowed());
    }

    @Test
    void authenticatedUserGetsTheUserLimit() {
        for (int index = 0; index < USER_LIMIT; index++) {
            assertTrue(limiter.allow("user:42", true, NOW).allowed());
        }

        assertFalse(limiter.allow("user:42", true, NOW).allowed());
    }

    @Test
    void expiredEntriesAreCleanedUp() {
        for (int index = 0; index <= SimulationCreationRateLimiter.MAX_TRACKED_CLIENTS; index++) {
            limiter.allow("ip:10.0.0." + index, false, NOW);
        }

        limiter.allow("ip:192.0.2.1", false, NOW + WINDOW_MS);

        assertEquals(1, limiter.trackedClients());
    }
}
