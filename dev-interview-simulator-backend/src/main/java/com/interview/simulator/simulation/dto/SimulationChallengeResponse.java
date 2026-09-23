package com.interview.simulator.simulation.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.SelectionType;
import java.util.List;

public record SimulationChallengeResponse(
    Long simulationChallengeId,
    int displayOrder,
    Long challengeId,
    String title,
    String context,
    String question,
    ChallengeType type,
    SelectionType selectionType,
    String codeSnippet,
    String codeLanguage,
    List<OptionResponse> options
) {
    public record OptionResponse(
        Long id,
        String content,
        int displayOrder
    ) {}
}