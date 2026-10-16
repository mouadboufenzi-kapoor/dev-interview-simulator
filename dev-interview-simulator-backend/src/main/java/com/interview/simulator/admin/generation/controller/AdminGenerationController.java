package com.interview.simulator.admin.generation.controller;

import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.generation.dto.ChallengeGenerationRequest;
import com.interview.simulator.admin.generation.service.ChallengeGenerationService;
import jakarta.validation.Valid;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Validated
@RequestMapping("/api/admin/challenges")
public class AdminGenerationController {

    private final ChallengeGenerationService challengeGenerationService;

    public AdminGenerationController(ChallengeGenerationService challengeGenerationService) {
        this.challengeGenerationService = challengeGenerationService;
    }

    @PostMapping("/generate")
    public ChallengeImportReport generate(@Valid @RequestBody ChallengeGenerationRequest request) {
        return challengeGenerationService.generate(request);
    }
}
