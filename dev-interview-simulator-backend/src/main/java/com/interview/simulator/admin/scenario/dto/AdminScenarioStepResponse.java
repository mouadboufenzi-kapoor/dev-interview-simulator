package com.interview.simulator.admin.scenario.dto;

public record AdminScenarioStepResponse(
        Long challengeId,
        String title,
        Integer stepOrder
) {}
