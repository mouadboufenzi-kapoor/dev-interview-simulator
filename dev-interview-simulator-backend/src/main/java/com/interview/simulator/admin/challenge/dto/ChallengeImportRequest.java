package com.interview.simulator.admin.challenge.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.OptionSeverity;
import com.interview.simulator.challenge.entity.SelectionType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

import java.util.List;
import java.util.Set;

public record ChallengeImportRequest(
        List<ImportedQuestion> questions
) {

    public record ImportedQuestion(
            String externalId,
            @NotBlank String title,
            @NotNull ChallengeType type,
            @NotNull DifficultyLevel difficulty,
            @NotNull SelectionType selectionType,
            String context,
            @NotBlank String question,
            String codeSnippet,
            String codeLanguage,
            String explanation,
            String revealedInformation,
            String tradeoff,
            @Positive Integer estimatedTimeSeconds,
            @Positive Integer points,
            Set<String> categories,
            Set<String> skills,
            Set<String> profiles,
            String scenario,
            Integer stepOrder,
            @Valid List<ImportedOption> options
    ) {
    }

    public record ImportedOption(
            @NotBlank String content,
            boolean correct,
            OptionSeverity severity,
            String explanation,
            @PositiveOrZero int displayOrder
    ) {
    }
}
