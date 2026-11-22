package com.interview.simulator.simulation.controller;

import com.interview.simulator.analytics.service.SimulationCreationRateLimiter;
import com.interview.simulator.exception.RateLimitExceededException;
import com.interview.simulator.simulation.dto.*;
import com.interview.simulator.simulation.service.SimulationService;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.service.UserResolver;
import jakarta.servlet.http.HttpServletRequest;
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
    private final SimulationCreationRateLimiter creationRateLimiter;
    private final UserResolver userResolver;

    public SimulationController(
            SimulationService simulationService,
            SimulationCreationRateLimiter creationRateLimiter,
            UserResolver userResolver) {
        this.simulationService = simulationService;
        this.creationRateLimiter = creationRateLimiter;
        this.userResolver = userResolver;
    }

    @PostMapping
    public ResponseEntity<SimulationResponse> startSimulation(
            @Valid @RequestBody StartSimulationRequest request,
            HttpServletRequest httpRequest) {
        User authenticatedUser = userResolver.currentAuthenticatedOrNull().orElse(null);
        String clientKey = authenticatedUser != null
                ? "user:" + authenticatedUser.getId()
                : "ip:" + httpRequest.getRemoteAddr();
        SimulationCreationRateLimiter.Decision decision =
                creationRateLimiter.allow(clientKey, authenticatedUser != null);
        if (!decision.allowed()) {
            throw new RateLimitExceededException(decision.retryAfterSeconds());
        }
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