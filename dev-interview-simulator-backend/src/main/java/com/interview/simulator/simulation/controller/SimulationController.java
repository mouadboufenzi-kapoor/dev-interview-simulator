package com.interview.simulator.simulation.controller;

import com.interview.simulator.simulation.dto.SimulationResponse;
import com.interview.simulator.simulation.dto.StartSimulationRequest;
import com.interview.simulator.simulation.service.SimulationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
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
}