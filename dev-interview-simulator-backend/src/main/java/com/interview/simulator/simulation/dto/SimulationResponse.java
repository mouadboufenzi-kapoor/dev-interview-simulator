package com.interview.simulator.simulation.dto;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.interview.simulator.simulation.entity.SimulationStatus;

import java.time.LocalDateTime;
import java.util.List;

public record SimulationResponse(
    Long id,
    ChallengeType mode,
    DifficultyLevel difficulty,
    Long profileId,
    SimulationStatus status,
    Integer totalScore,
    LocalDateTime startedAt,
    List<SimulationChallengeResponse> challenges,
    @JsonInclude(JsonInclude.Include.NON_NULL)
    String guestAccessToken
) {}