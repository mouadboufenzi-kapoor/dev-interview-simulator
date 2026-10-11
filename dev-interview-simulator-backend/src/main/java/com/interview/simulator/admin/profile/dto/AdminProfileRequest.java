package com.interview.simulator.admin.profile.dto;

import jakarta.validation.constraints.NotBlank;

public record AdminProfileRequest(
        @NotBlank String code,
        @NotBlank String name,
        String description,
        Boolean active
) {}
