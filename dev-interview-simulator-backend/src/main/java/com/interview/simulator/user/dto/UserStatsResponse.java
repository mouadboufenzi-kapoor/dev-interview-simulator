package com.interview.simulator.user.dto;

import java.util.List;

public record UserStatsResponse(
        long totalSimulations,
        long completedSimulations,
        long totalAnswers,
        long correctAnswers,
        Double globalSuccessRate,
        Double recentSuccessRate,
        Double previousSuccessRate,
        String trend,
        List<StatEntry> byCategory,
        List<TypeStat> byType,
        List<StatEntry> weakPoints,
        PagedSimulations simulations
) {
    public record StatEntry(
            Long id,
            String name,
            int answered,
            int correct,
            double successRate
    ) {}

    public record TypeStat(
            String type,
            int answered,
            int correct,
            double successRate
    ) {}

    public record RecentSimulation(
            Long id,
            String mode,
            String difficulty,
            int totalQuestions,
            int correctAnswers,
            int totalScore,
            String startedAt
    ) {}

    public record PagedSimulations(
            List<RecentSimulation> content,
            int page,
            int size,
            long totalElements,
            int totalPages
    ) {}
}
