package com.interview.simulator.admin.coverage.controller;

import com.interview.simulator.admin.coverage.dto.CoverageDetailPage;
import com.interview.simulator.admin.coverage.dto.CoverageOptionsResponse;
import com.interview.simulator.admin.coverage.dto.CoverageReport;
import com.interview.simulator.admin.coverage.service.AdminCoverageService;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import jakarta.validation.constraints.Positive;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Validated
@RequestMapping("/api/admin/coverage")
public class AdminCoverageController {

    private final AdminCoverageService adminCoverageService;

    public AdminCoverageController(AdminCoverageService adminCoverageService) {
        this.adminCoverageService = adminCoverageService;
    }

    @GetMapping("/options")
    public CoverageOptionsResponse getOptions() {
        return adminCoverageService.getOptions();
    }

    @GetMapping
    public CoverageReport getCoverage(
            @RequestParam(required = false) @Positive Long profileId,
            @RequestParam(required = false) DifficultyLevel difficulty,
            @RequestParam(required = false) ChallengeType type,
            @RequestParam String dimension) {
        return adminCoverageService.getCoverage(profileId, difficulty, type, dimension);
    }

    @GetMapping("/details")
    public CoverageDetailPage getDetails(
            @RequestParam @Positive Long profileId,
            @RequestParam DifficultyLevel difficulty,
            @RequestParam ChallengeType type,
            @RequestParam String dimension,
            @RequestParam @Positive Long taxonomyId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return adminCoverageService.getDetails(profileId, difficulty, type, dimension, taxonomyId, page, size);
    }

    @GetMapping("/scenarios/{scenarioId}/steps")
    public CoverageDetailPage getScenarioSteps(
            @PathVariable @Positive Long scenarioId,
            @RequestParam @Positive Long profileId,
            @RequestParam DifficultyLevel difficulty,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        return adminCoverageService.getScenarioSteps(profileId, difficulty, scenarioId, page, size);
    }
}
