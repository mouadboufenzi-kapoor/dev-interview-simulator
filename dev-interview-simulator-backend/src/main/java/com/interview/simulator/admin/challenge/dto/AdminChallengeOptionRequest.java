package com.interview.simulator.admin.challenge.dto;

import com.interview.simulator.challenge.entity.OptionSeverity;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;

public record AdminChallengeOptionRequest(
        Long id,
        @NotBlank String content,
        boolean correct,
        OptionSeverity severity,
        String explanation,
        @PositiveOrZero int displayOrder
) {}
