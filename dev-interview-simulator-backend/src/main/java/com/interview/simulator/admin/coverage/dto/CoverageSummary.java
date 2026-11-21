package com.interview.simulator.admin.coverage.dto;

import com.interview.simulator.challenge.entity.DifficultyLevel;

import java.util.List;

public record CoverageSummary(List<Row> rows) {
    public record Row(
            Long profileId,
            String profileCode,
            String profileName,
            DifficultyLevel difficulty,
            long contentCount
    ) {}
}
