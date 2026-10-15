package com.interview.simulator.profile.dto;

import com.interview.simulator.challenge.entity.ChallengeType;

import java.util.Set;

public record ProfileResponse(
    Long id,
    String code,
    String name,
    String description,
    Set<ChallengeType> allowedTypes
) {}
