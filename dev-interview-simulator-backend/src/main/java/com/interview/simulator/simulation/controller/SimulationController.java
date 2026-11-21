package com.interview.simulator.simulation.controller;

import com.interview.simulator.simulation.dto.*;
import com.interview.simulator.simulation.service.SimulationService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.validation.annotation.Validated;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@Validated
@RequestMapping("/api/simulations")
public class SimulationController {

    private final SimulationService simulationService;

    public SimulationController(SimulationService simulationService) {
        this.simulationService = simulationService;
    }

    @PostMapping
    public ResponseEntity<SimulationResponse> startSimulation(@Valid @RequestBody StartSimulationRequest request) {
        SimulationResponse response = simulationService.startSimulation(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/claim")
    public ResponseEntity<ClaimSimulationsResponse> claimSimulations(
            @Valid @RequestBody ClaimSimulationsRequest request) {
        return ResponseEntity.ok(simulationService.claimSimulations(request));
    }

    @PostMapping("/{id}/abandon")
    public ResponseEntity<SimulationSummaryResponse> abandonSimulation(
            @PathVariable @Positive Long id,
            @RequestHeader(value = "X-Guest-Access-Token", required = false) String guestAccessToken,
            @RequestParam(value = "guestAccessToken", required = false) String bodyGuestAccessToken) {
        return ResponseEntity.ok(simulationService.abandonSimulation(
                id,
                resolveGuestAccessToken(guestAccessToken, bodyGuestAccessToken)
        ));
    }

    @PostMapping("/{id}/seen")
    public ResponseEntity<Void> markSimulationSeen(
            @PathVariable @Positive Long id,
            @RequestHeader(value = "X-Guest-Access-Token", required = false) String guestAccessToken,
            @RequestParam(value = "guestAccessToken", required = false) String bodyGuestAccessToken) {
        simulationService.markSimulationSeen(
                id,
                resolveGuestAccessToken(guestAccessToken, bodyGuestAccessToken)
        );
        return ResponseEntity.noContent().build();
    }

    private String resolveGuestAccessToken(
            String headerToken,
            String bodyToken) {
        if (headerToken != null) {
            return headerToken;
        }
        return bodyToken;
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<SimulationSummaryResponse> completeSimulation(
            @PathVariable @Positive Long id,
            @RequestHeader(value = "X-Guest-Access-Token", required = false) String guestAccessToken) {
        SimulationSummaryResponse response = simulationService.completeSimulation(id, guestAccessToken);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/answers")
    public ResponseEntity<SubmitAnswerResponse> submitAnswer(
            @PathVariable @Positive Long id,
            @Valid @RequestBody SubmitAnswerRequest request,
            @RequestHeader(value = "X-Guest-Access-Token", required = false) String guestAccessToken) {
        return ResponseEntity.ok(simulationService.submitAnswer(id, request, guestAccessToken));
    }

    @GetMapping("/{id}/result")
    public ResponseEntity<SimulationResultDTO> getSimulationResult(
            @PathVariable @Positive Long id,
            @RequestHeader(value = "X-Guest-Access-Token", required = false) String guestAccessToken) {
        return ResponseEntity.ok(simulationService.getSimulationResult(id, guestAccessToken));
    }
}