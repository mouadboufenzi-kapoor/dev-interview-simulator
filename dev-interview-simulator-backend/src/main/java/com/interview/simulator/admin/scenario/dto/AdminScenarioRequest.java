package com.interview.simulator.admin.scenario.dto;

import jakarta.validation.constraints.NotBlank;

public record AdminScenarioRequest(
        @NotBlank String title,
        String description
) {}
