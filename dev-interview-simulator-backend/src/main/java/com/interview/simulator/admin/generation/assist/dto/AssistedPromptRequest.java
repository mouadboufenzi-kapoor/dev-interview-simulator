package com.interview.simulator.admin.generation.assist.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.util.Set;

public record AssistedPromptRequest(
        Set<@Positive Long> profileIds,
        Set<@Positive Long> categoryIds,
        Set<@Positive Long> skillIds,
        @NotNull DifficultyLevel difficulty,
        @NotNull ChallengeType type,
        @Min(1) int count,
        String instructions) {
}