package com.interview.simulator.admin.profile.dto;

import com.interview.simulator.challenge.entity.ChallengeType;

import java.util.Set;

public record AdminProfileResponse(
        Long id,
        String code,
        String name,
        String description,
        boolean active,
        Set<ChallengeType> allowedTypes
) {}
