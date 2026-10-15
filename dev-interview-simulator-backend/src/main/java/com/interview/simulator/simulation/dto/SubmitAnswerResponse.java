package com.interview.simulator.simulation.dto;

public record SubmitAnswerResponse(
    Long answerId,
    boolean isCorrect,
    Integer scoreAwarded,
    Integer totalSimulationScore,
    String explanation,
    Long correctOptionId,
    String revealedInformation,
    String tradeoff,
    java.util.List<ChallengeCorrectionDTO> corrections,
    /** Raisonnement séquentiel uniquement : ids des étapes dans l'ordre attendu. */
    java.util.List<Long> expectedOrder
) {}