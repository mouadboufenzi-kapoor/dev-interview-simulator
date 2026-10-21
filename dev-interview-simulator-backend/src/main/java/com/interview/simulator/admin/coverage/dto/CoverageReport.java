package com.interview.simulator.admin.coverage.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;

import java.util.List;

public record CoverageReport(List<CoverageCell> cells) {
    public record CoverageCell(
            Long profileId,
            String profileName,
            DifficultyLevel difficulty,
            ChallengeType type,
            Long taxonomyId,
            String taxonomyName,
            long count
    ) {}
}
