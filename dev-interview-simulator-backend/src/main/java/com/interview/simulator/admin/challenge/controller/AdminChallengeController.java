package com.interview.simulator.admin.challenge.controller;

import com.interview.simulator.admin.challenge.dto.AdminChallengeRequest;
import com.interview.simulator.admin.challenge.dto.AdminChallengeResponse;
import com.interview.simulator.admin.challenge.service.AdminChallengeService;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@Validated
@RequestMapping("/api/admin/challenges")
public class AdminChallengeController {

    private final AdminChallengeService adminChallengeService;

    public AdminChallengeController(AdminChallengeService adminChallengeService) {
        this.adminChallengeService = adminChallengeService;
    }

    @GetMapping
    public Page<AdminChallengeResponse> search(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) ContentStatus status,
            @RequestParam(required = false) ChallengeType type,
            @RequestParam(required = false) DifficultyLevel difficulty,
            Pageable pageable) {
        return adminChallengeService.search(search, status, type, difficulty, pageable);
    }

    @GetMapping("/{id}")
    public AdminChallengeResponse get(@PathVariable @Positive Long id) {
        return adminChallengeService.get(id);
    }

    @PostMapping
    public ResponseEntity<AdminChallengeResponse> create(
            @Valid @RequestBody AdminChallengeRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(adminChallengeService.create(request));
    }

    @PutMapping("/{id}")
    public AdminChallengeResponse update(
            @PathVariable @Positive Long id,
            @Valid @RequestBody AdminChallengeRequest request) {
        return adminChallengeService.update(id, request);
    }

    @PatchMapping("/{id}/status")
    public AdminChallengeResponse changeStatus(
            @PathVariable @Positive Long id,
            @RequestParam ContentStatus status) {
        return adminChallengeService.changeStatus(id, status);
    }
}
