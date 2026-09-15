package com.interview.simulator.simulation.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.simulation.entity.SimulationStatus;

import java.time.LocalDateTime;
import java.util.List;

public record SimulationResponse(
    Long id,
    ChallengeType mode,
    DifficultyLevel difficulty,
    SimulationStatus status,
    Integer totalScore,
    LocalDateTime startedAt,
    List<SimulationChallengeResponse> challenges
) {}