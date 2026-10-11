package com.interview.simulator.admin.scenario.dto;

import com.interview.simulator.challenge.entity.ChallengeType;

public record AdminScenarioResponse(
        Long id,
        String title,
        String description,
        ChallengeType mode,
        boolean active,
        long stepCount
) {}
