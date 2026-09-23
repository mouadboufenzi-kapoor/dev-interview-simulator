package com.interview.simulator.simulation.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.util.List;

public record SubmitAnswerRequest(
    @NotNull @Positive Long simulationChallengeId,
    @NotNull @Size(min = 1) List<@Positive Long> selectedOptionIds,
    @PositiveOrZero Long responseTimeMs
) {}