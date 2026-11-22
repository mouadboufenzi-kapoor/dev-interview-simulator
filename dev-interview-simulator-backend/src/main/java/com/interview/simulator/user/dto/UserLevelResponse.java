package com.interview.simulator.user.dto;

public record UserLevelResponse(
        String currentLevel,
        String nextLevel,
        int answeredCount,
        int windowSize,
        int successRatePercent,
        int requiredSuccessRate
) {
}
