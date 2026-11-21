package com.interview.simulator.admin.user.dto;

import com.interview.simulator.user.entity.UserRole;

import java.time.LocalDateTime;

public record AdminUserResponse(
        Long id,
        String username,
        String email,
        UserRole role,
        boolean enabled,
        LocalDateTime createdAt
) {}
