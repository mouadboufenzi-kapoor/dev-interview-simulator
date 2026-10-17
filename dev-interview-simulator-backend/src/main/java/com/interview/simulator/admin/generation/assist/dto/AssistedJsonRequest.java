package com.interview.simulator.admin.generation.assist.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AssistedJsonRequest(
        @NotBlank @Size(max = 400_000) String json) {
}