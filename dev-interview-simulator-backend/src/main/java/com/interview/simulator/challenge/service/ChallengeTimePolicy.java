package com.interview.simulator.challenge.service;

import com.interview.simulator.challenge.entity.ChallengeType;

/** Shared duration policy for generated, imported, manually edited, and presented challenges. */
public final class ChallengeTimePolicy {

    public static final int SITUATIONAL_QCM_SECONDS = 70;
    public static final int MAX_SECONDS = 120;
    public static final int DEFAULT_SECONDS = 90;

    private ChallengeTimePolicy() {
    }

    public static int normalize(ChallengeType type, Integer requestedSeconds) {
        if (type == ChallengeType.SITUATIONAL_QCM) {
            return SITUATIONAL_QCM_SECONDS;
        }
        if (requestedSeconds == null) {
            return DEFAULT_SECONDS;
        }
        return Math.min(requestedSeconds, MAX_SECONDS);
    }

    public static String promptRule(ChallengeType type) {
        if (type == ChallengeType.SITUATIONAL_QCM) {
            return "Durée : estimatedTimeSeconds doit valoir exactement 70 (70 secondes) pour chaque question SITUATIONAL_QCM.\n";
        }
        return "Durée : estimatedTimeSeconds doit être un entier positif inférieur ou égal à 120 (2 minutes maximum) pour chaque question.\n";
    }
}
