package com.interview.simulator.simulation.dto;

import jakarta.validation.constraints.NotNull;

public record SubmitAnswerRequest(
    @NotNull Long simulationChallengeId,
    @NotNull Long selectedOptionId,
    Long responseTimeMs
) {}