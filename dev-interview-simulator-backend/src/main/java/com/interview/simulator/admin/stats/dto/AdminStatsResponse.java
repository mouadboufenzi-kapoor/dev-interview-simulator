package com.interview.simulator.admin.stats.dto;

import java.util.Map;

public record AdminStatsResponse(
        long totalChallenges,
        long challengesDraft,
        long challengesValidated,
        long challengesArchived,
        Map<String, Long> challengesByType,
        long totalProfiles,
        long activeProfiles,
        long totalScenarios,
        long activeScenarios,
        long totalSimulations,
        long completedSimulations,
        long inProgressSimulations
) {}
