package com.interview.simulator.simulation.dto;

import java.util.List;

public record SimulationResultDTO(
    Long simulationId,
    Integer totalScore,
    Integer maxPossibleScore,
    Double successPercentage,
    Long totalTimeSpentSeconds,
    Integer totalQuestions,
    Integer correctAnswersCount,
    List<QuestionSummaryDTO> questions
) {
    public record QuestionSummaryDTO(
        Long challengeId,
        String title,
        String context,
        String question,
        String userSelectedOptionContent,
        String correctOptionContent,
        Boolean isCorrect,
        String explanation,
        Integer pointsEarned,
        Long timeSpentMs
    ) {}
}
