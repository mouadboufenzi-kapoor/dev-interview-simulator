package com.interview.simulator.admin.coverage.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;

import java.util.List;
import java.util.Set;

public record CoverageOptionsResponse(
        List<ProfileOption> profiles,
        List<ChallengeType> types,
        List<DifficultyLevel> difficulties,
        List<TaxonomyOption> categories,
        List<TaxonomyOption> skills
) {
    public record ProfileOption(Long id, String code, String name, Set<ChallengeType> allowedTypes) {}
    public record TaxonomyOption(Long id, String name) {}
}
