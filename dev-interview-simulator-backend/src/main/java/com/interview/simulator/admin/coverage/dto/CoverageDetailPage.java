package com.interview.simulator.admin.coverage.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;

import java.util.List;

public record CoverageDetailPage(
        List<ContentItem> content,
        int number,
        int size,
        long totalElements,
        int totalPages
) {
    public record ContentItem(
            Long id,
            String title,
            String question,
            ChallengeType type,
            DifficultyLevel difficulty,
            Integer stepOrder,
            Long scenarioId,
            String scenarioTitle,
            long stepCount
    ) {}
}
