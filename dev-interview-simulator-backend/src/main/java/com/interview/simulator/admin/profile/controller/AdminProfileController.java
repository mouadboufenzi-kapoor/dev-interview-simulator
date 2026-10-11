package com.interview.simulator.admin.profile.controller;

import com.interview.simulator.admin.profile.dto.AdminProfileRequest;
import com.interview.simulator.admin.profile.dto.AdminProfileResponse;
import com.interview.simulator.admin.profile.service.AdminProfileService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@Validated
@RequestMapping("/api/admin/profiles")
public class AdminProfileController {

    private final AdminProfileService adminProfileService;

    public AdminProfileController(AdminProfileService adminProfileService) {
        this.adminProfileService = adminProfileService;
    }

    @GetMapping
    public List<AdminProfileResponse> getAllProfiles() {
        return adminProfileService.getAllProfiles();
    }

    @PostMapping
    public ResponseEntity<AdminProfileResponse> create(@Valid @RequestBody AdminProfileRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(adminProfileService.create(request));
    }

    @PutMapping("/{id}")
    public AdminProfileResponse update(
            @PathVariable @Positive Long id,
            @Valid @RequestBody AdminProfileRequest request) {
        return adminProfileService.update(id, request);
    }

    @PatchMapping("/{id}/active")
    public AdminProfileResponse setActive(
            @PathVariable @Positive Long id,
            @RequestParam boolean active) {
        return adminProfileService.setActive(id, active);
    }
}
