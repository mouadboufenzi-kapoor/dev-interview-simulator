package com.interview.simulator.simulation.dto;

import java.util.List;

public record ChallengeCorrectionDTO(
        Long optionId,
        String content,
        boolean isCorrect,
        boolean wasSelected,
        String severity,
        String explanation
) {
    public static List<ChallengeCorrectionDTO> forOptions(
            List<com.interview.simulator.challenge.entity.ChallengeOption> options,
            java.util.Set<Long> selectedOptionIds) {
        return options.stream()
                .map(option -> new ChallengeCorrectionDTO(
                        option.getId(),
                        option.getContent(),
                        option.isCorrect(),
                        selectedOptionIds.contains(option.getId()),
                        option.getSeverity() != null ? option.getSeverity().name() : null,
                        option.getExplanation()
                ))
                .toList();
    }
}
