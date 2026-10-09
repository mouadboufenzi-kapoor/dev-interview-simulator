package com.interview.simulator.admin.challenge.dto;

import com.interview.simulator.challenge.entity.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

public record AdminChallengeResponse(
        Long id,
        String title,
        ChallengeType type,
        DifficultyLevel difficulty,
        SelectionType selectionType,
        String context,
        String question,
        String codeSnippet,
        String codeLanguage,
        String revealedInformation,
        String tradeoff,
        String explanation,
        Integer estimatedTimeSeconds,
        Integer points,
        ContentStatus status,
        boolean active,
        Set<Long> categoryIds,
        Set<Long> skillIds,
        Set<Long> profileIds,
        List<AdminChallengeOptionResponse> options,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {}
