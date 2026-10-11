package com.interview.simulator.admin.profile.dto;

public record AdminProfileResponse(
        Long id,
        String code,
        String name,
        String description,
        boolean active
) {}
