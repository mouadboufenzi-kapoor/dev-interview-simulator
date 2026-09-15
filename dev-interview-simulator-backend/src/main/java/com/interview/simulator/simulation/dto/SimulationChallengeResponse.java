package com.interview.simulator.simulation.dto;

import java.util.List;

public record SimulationChallengeResponse(
    Long simulationChallengeId,
    int displayOrder,
    Long challengeId,
    String title,
    String context,
    String question,
    List<OptionResponse> options
) {
    public record OptionResponse(
        Long id,
        String content,
        int displayOrder
    ) {}
}