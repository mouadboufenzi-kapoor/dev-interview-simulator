package com.interview.simulator.simulation.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

public record SubmitAnswerRequest(
    @NotNull @Positive Long simulationChallengeId,
    @NotNull @Positive Long selectedOptionId,
    @PositiveOrZero Long responseTimeMs
) {}