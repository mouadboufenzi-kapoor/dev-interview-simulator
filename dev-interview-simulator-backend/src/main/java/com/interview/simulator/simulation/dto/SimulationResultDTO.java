package com.interview.simulator.simulation.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;

import java.util.List;

public record SimulationResultDTO(
    Long simulationId,
    Integer totalScore,
    Integer maxPossibleScore,
    Double successPercentage,
    Long totalTimeSpentSeconds,
    Integer totalQuestions,
    Integer correctAnswersCount,
    ChallengeType mode,
    DifficultyLevel difficulty,
    Long profileId,
    CompetencySource competencySource,
    List<CompetencyResult> competencyResults,
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
        QuestionStatus status,
        String explanation,
        Integer pointsEarned,
        Long timeSpentMs
    ) {}

    /**
     * Compétence évaluée (skill ou catégorie) avec son taux de réussite :
     * correct / total sur les questions répondues de la simulation.
     */
    public record CompetencyResult(Long id, String name, Integer correct, Integer total) {}

    public enum QuestionStatus { ANSWERED, TIMED_OUT, UNANSWERED }

    /**
     * Axe du breakdown retourné : SKILL si au moins la moitié des questions
     * portent un skill, sinon CATEGORY (couverture complète en base).
     */
    public enum CompetencySource { SKILL, CATEGORY }
}
