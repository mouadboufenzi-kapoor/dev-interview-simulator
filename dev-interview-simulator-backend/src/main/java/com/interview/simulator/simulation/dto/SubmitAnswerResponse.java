package com.interview.simulator.simulation.dto;

public record SubmitAnswerResponse(
    Long answerId,
    boolean isCorrect,
    Integer scoreAwarded,
    Integer totalSimulationScore,
    String explanation,
    Long correctOptionId,
    java.util.List<ChallengeCorrectionDTO> corrections
) {}