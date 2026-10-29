package com.interview.simulator.admin.scenario.controller;

import com.interview.simulator.admin.scenario.dto.AdminScenarioRequest;
import com.interview.simulator.admin.scenario.dto.AdminScenarioResponse;
import com.interview.simulator.admin.scenario.dto.AdminScenarioStepResponse;
import com.interview.simulator.admin.scenario.service.AdminScenarioService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@Validated
@RequestMapping("/api/admin/scenarios")
public class AdminScenarioController {

    private final AdminScenarioService adminScenarioService;

    public AdminScenarioController(AdminScenarioService adminScenarioService) {
        this.adminScenarioService = adminScenarioService;
    }

    @GetMapping
    public Page<AdminScenarioResponse> getScenarios(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return adminScenarioService.getScenarios(page, size);
    }

    @GetMapping("/{id}/steps")
    public List<AdminScenarioStepResponse> getSteps(@PathVariable @Positive Long id) {
        return adminScenarioService.getSteps(id);
    }

    @PostMapping
    public ResponseEntity<AdminScenarioResponse> create(@Valid @RequestBody AdminScenarioRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(adminScenarioService.create(request));
    }
}
