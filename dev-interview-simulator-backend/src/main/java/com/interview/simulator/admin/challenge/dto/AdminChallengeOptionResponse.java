package com.interview.simulator.admin.challenge.dto;

import com.interview.simulator.challenge.entity.OptionSeverity;

public record AdminChallengeOptionResponse(
        Long id,
        String content,
        boolean correct,
        OptionSeverity severity,
        String explanation,
        int displayOrder
) {}
