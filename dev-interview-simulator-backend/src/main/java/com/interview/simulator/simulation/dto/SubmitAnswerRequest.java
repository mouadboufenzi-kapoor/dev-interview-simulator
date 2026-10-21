package com.interview.simulator.simulation.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

import java.util.List;

public record SubmitAnswerRequest(
    @NotNull @Positive Long simulationChallengeId,
    @NotNull List<@Positive Long> selectedOptionIds,
    @PositiveOrZero Long responseTimeMs
) {}