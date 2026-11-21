package com.interview.simulator.simulation.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record ClaimSimulationsRequest(
        @NotNull @Size(max = 50) List<@NotBlank String> tokens
) {
}
