package com.interview.simulator.admin.profile.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import jakarta.validation.constraints.NotBlank;

import java.util.Set;

public record AdminProfileRequest(
        @NotBlank String code,
        @NotBlank String name,
        String description,
        Boolean active,
        Set<ChallengeType> allowedTypes
) {}
