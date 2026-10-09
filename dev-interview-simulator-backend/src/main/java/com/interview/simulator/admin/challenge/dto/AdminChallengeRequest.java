package com.interview.simulator.admin.challenge.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.SelectionType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.util.List;
import java.util.Set;

public record AdminChallengeRequest(
        @NotBlank String title,
        @NotNull ChallengeType type,
        @NotNull DifficultyLevel difficulty,
        @NotNull SelectionType selectionType,
        String context,
        @NotBlank String question,
        String codeSnippet,
        String codeLanguage,
        String revealedInformation,
        String tradeoff,
        String explanation,
        @Positive Integer estimatedTimeSeconds,
        @Positive Integer points,
        Set<@Positive Long> categoryIds,
        Set<@Positive Long> skillIds,
        Set<@Positive Long> profileIds,
        @Valid List<AdminChallengeOptionRequest> options
) {}
