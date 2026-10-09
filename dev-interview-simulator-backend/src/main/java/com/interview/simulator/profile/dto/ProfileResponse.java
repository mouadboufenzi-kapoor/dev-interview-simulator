package com.interview.simulator.profile.dto;

public record ProfileResponse(
    Long id,
    String code,
    String name,
    String description
) {}
