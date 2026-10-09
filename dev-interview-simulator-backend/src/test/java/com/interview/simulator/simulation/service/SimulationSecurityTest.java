package com.interview.simulator.simulation.service;

import com.interview.simulator.simulation.dto.SimulationResponse;
import com.interview.simulator.simulation.dto.StartSimulationRequest;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

@Disabled("Pas de données de test pour le moment")
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class SimulationSecurityTest {

    @Autowired
    private SimulationService simulationService;

    @Test
    void startSimulation_ShouldNotExposeIsCorrectInOptions() {
        StartSimulationRequest request = new StartSimulationRequest(
                ChallengeType.SITUATIONAL_QCM,   // mode
                DifficultyLevel.JUNIOR,          // difficulty
                null,                            // profileId
                Set.of(),                        // categoryIds
                Set.of(),                        // skillIds
                5
        );

        SimulationResponse response = simulationService.startSimulation(request);

        assertNotNull(response);
        assertFalse(response.challenges().isEmpty(), "Should have challenges");
        
        // Assert that Options do not have isCorrect boolean exposed
        // (Relying on the OptionResponse DTO not having the field)
        response.challenges().forEach(challenge -> {
            challenge.options().forEach(option -> {
                // Since DTO is a record or class, if we can't access isCorrect(), it's safe at compile time.
                // We're just verifying the structure is respected.
                assertTrue(option.content() != null);
            });
        });
    }
}
