package com.interview.simulator.admin.challenge.controller;

import com.interview.simulator.admin.challenge.dto.AdminChallengeRequest;
import com.interview.simulator.admin.challenge.dto.AdminChallengeResponse;
import com.interview.simulator.admin.challenge.dto.BackfillIdentityReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.service.AdminChallengeService;
import com.interview.simulator.admin.challenge.service.ChallengeImportService;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.exception.ApiException;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Arrays;

@RestController
@Validated
@RequestMapping("/api/admin/challenges")
public class AdminChallengeController {

    private static final ContentStatus[] IMPORT_STATUSES = {ContentStatus.DRAFT, ContentStatus.VALIDATED};

    private final AdminChallengeService adminChallengeService;
    private final ChallengeImportService challengeImportService;

    public AdminChallengeController(
            AdminChallengeService adminChallengeService,
            ChallengeImportService challengeImportService) {
        this.adminChallengeService = adminChallengeService;
        this.challengeImportService = challengeImportService;
    }

    @GetMapping
    public Page<AdminChallengeResponse> search(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) ContentStatus status,
            @RequestParam(required = false) ChallengeType type,
            @RequestParam(required = false) DifficultyLevel difficulty,
            @RequestParam(required = false) Long profileId,
            Pageable pageable) {
        return adminChallengeService.search(search, status, type, difficulty, profileId, pageable);
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

    @PostMapping("/backfill-identity")
    public BackfillIdentityReport backfillIdentity() {
        return adminChallengeService.backfillIdentity();
    }

    @PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ChallengeImportReport importQuestions(
            @RequestParam("file") MultipartFile file,
            @RequestParam(name = "status", defaultValue = "DRAFT") ContentStatus status,
            @RequestParam(name = "dryRun", defaultValue = "true") boolean dryRun) {
        if (Arrays.stream(IMPORT_STATUSES).noneMatch(allowed -> allowed == status)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Le statut doit être DRAFT ou VALIDATED.");
        }
        return challengeImportService.importQuestions(file, status, dryRun);
    }
}
