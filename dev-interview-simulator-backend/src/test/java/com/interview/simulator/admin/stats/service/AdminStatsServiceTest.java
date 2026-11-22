package com.interview.simulator.admin.stats.service;

import com.interview.simulator.admin.stats.dto.AdminStatsResponse;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.simulation.entity.SimulationStatus;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.repository.UserRepository;
import com.interview.simulator.user.service.UserResolver;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AdminStatsServiceTest {

    @Mock private ChallengeRepository challengeRepository;
    @Mock private ProfileRepository profileRepository;
    @Mock private InterviewScenarioRepository interviewScenarioRepository;
    @Mock private SimulationRepository simulationRepository;
    @Mock private UserRepository userRepository;

    @InjectMocks private AdminStatsService adminStatsService;

    @Test
    void placementCountersAreSeparateFromExistingOnes() {
        when(simulationRepository.count()).thenReturn(40L);
        when(simulationRepository.countByStatus(SimulationStatus.COMPLETED)).thenReturn(25L);
        when(simulationRepository.countByPlacementTrue()).thenReturn(12L);
        when(simulationRepository.countByPlacementTrueAndStatus(SimulationStatus.COMPLETED))
                .thenReturn(7L);
        when(simulationRepository.countByPlacementTrueAndUserUsername(UserResolver.GUEST_USERNAME))
                .thenReturn(9L);

        AdminStatsResponse response = adminStatsService.getStats();

        assertEquals(40L, response.totalSimulations());
        assertEquals(25L, response.completedSimulations());
        assertEquals(12L, response.placementSimulations());
        assertEquals(7L, response.placementCompleted());
        assertEquals(9L, response.guestPlacementSimulations());
    }
}
