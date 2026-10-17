package com.interview.simulator.admin.generation.assist.controller;

import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.generation.assist.dto.AssistedAnalysisResponse;
import com.interview.simulator.admin.generation.assist.dto.AssistedJsonRequest;
import com.interview.simulator.admin.generation.assist.dto.AssistedPromptRequest;
import com.interview.simulator.admin.generation.assist.dto.AssistedPromptResponse;
import com.interview.simulator.admin.generation.assist.service.AssistedGenerationService;
import jakarta.validation.Valid;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@Validated
@RequestMapping("/api/admin/generation/assist")
public class AdminAssistedGenerationController {

    private final AssistedGenerationService assistedGenerationService;

    public AdminAssistedGenerationController(AssistedGenerationService assistedGenerationService) {
        this.assistedGenerationService = assistedGenerationService;
    }

    @PostMapping("/prompt")
    public AssistedPromptResponse prompt(@Valid @RequestBody AssistedPromptRequest request) {
        return assistedGenerationService.prompt(request);
    }

    @PostMapping("/analyze")
    public AssistedAnalysisResponse analyze(@Valid @RequestBody AssistedJsonRequest request) {
        return assistedGenerationService.analyze(request.json());
    }

    @PostMapping("/import")
    public ChallengeImportReport importQuestions(@Valid @RequestBody AssistedJsonRequest request) {
        return assistedGenerationService.importJson(request.json());
    }
}