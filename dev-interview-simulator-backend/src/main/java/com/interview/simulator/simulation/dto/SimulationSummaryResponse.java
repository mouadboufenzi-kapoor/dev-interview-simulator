package com.interview.simulator.simulation.dto;

import com.interview.simulator.simulation.entity.SimulationStatus;
import java.time.LocalDateTime;

public record SimulationSummaryResponse(
    Long simulationId,
    SimulationStatus status,
    Integer totalScore,
    int totalQuestions,
    int correctAnswers,
    LocalDateTime startedAt,
    LocalDateTime completedAt
) {}