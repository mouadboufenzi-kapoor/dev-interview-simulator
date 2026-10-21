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
        Double averageSuccessRate,
        Double bestSuccessRate,
        List<StatEntry> byCategory,
        List<TypeStat> byType,
        List<WeakPointEntry> weakPoints,
        PagedSimulations simulations
) {
    public record StatEntry(
            Long id,
            String name,
            int answered,
            int correct,
            double successRate
    ) {}

    public record WeakPointEntry(
            Long id,
            String name,
            int answered,
            int correct,
            double successRate,
            String source
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
            String status,
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
