package com.interview.simulator.simulation.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import jakarta.validation.constraints.NotNull;

import java.util.Set;

public record StartSimulationRequest(
    @NotNull ChallengeType mode,
    DifficultyLevel difficulty,
    Set<Long> categoryIds,
    Set<Long> skillIds
) {}