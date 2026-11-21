package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.simulation.dto.SimulationResponse;
import com.interview.simulator.simulation.dto.StartSimulationRequest;
import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.repository.SimulationAnswerRepository;
import com.interview.simulator.simulation.repository.SimulationChallengeRepository;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.service.UserResolver;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SimulationServiceTest {

    @Mock private SimulationRepository simulationRepository;
    @Mock private ChallengeRepository challengeRepository;
    @Mock private UserResolver userResolver;
    @Mock private SimulationChallengeRepository simulationChallengeRepository;
    @Mock private InterviewScenarioRepository interviewScenarioRepository;
    @Mock private ProfileRepository profileRepository;
    @Mock private SimulationAnswerRepository simulationAnswerRepository;

    @InjectMocks private SimulationService simulationService;

    @Test
    void startArchitectureSimulationIncludesEveryStepFromSelectedScenario() {
        User user = new User("guest", "guest@example.test");
        InterviewScenario scenario = scenario(1L, "Platform design");
        List<Challenge> steps = List.of(
                challenge(scenario, 1, "Step one"),
                challenge(scenario, 2, "Step two"),
                challenge(scenario, 3, "Step three"),
                challenge(scenario, 4, "Step four"),
                challenge(scenario, 5, "Step five"),
                challenge(scenario, 6, "Step six")
        );
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        when(interviewScenarioRepository.findByModeAndActiveTrue(ChallengeType.ARCHITECTURE))
                .thenReturn(List.of(scenario));
        when(challengeRepository.findScenarioChallenges(
                eq(ChallengeType.ARCHITECTURE), eq(DifficultyLevel.INTERMEDIATE), eq(null),
                eq(ContentStatus.VALIDATED), eq(scenario))).thenReturn(steps);
        when(simulationRepository.save(any(Simulation.class))).thenAnswer(invocation -> {
            Simulation simulation = invocation.getArgument(0);
            ReflectionTestUtils.setField(simulation, "id", 11L);
            return simulation;
        });

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
                ChallengeType.ARCHITECTURE, DifficultyLevel.INTERMEDIATE, null,
                Set.of(), Set.of(), null, null));

        assertEquals(6, response.challenges().size());
        assertEquals(List.of(1, 2, 3, 4, 5, 6), response.challenges().stream()
                .map(challenge -> challenge.stepOrder()).toList());
    }

    @Test
    void startPlacementSimulationUsesFiveOrderedMixedChallenges() {
        User user = new User("guest", "guest@example.test");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        when(challengeRepository.findByTitleAndContentHash(anyString(), anyString()))
            .thenReturn(Optional.empty());

        Challenge juniorOne = placementChallenge(101L, "Junior one",
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.JUNIOR);
        Challenge juniorTwo = placementChallenge(102L, "Junior two",
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.JUNIOR);
        Challenge intermediate = placementChallenge(103L, "Intermediate",
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.INTERMEDIATE);
        Challenge codeReview = placementChallenge(104L, "Code review",
            ChallengeType.CODE_REVIEW, DifficultyLevel.INTERMEDIATE);
        Challenge advanced = placementChallenge(105L, "Advanced",
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.ADVANCED);

        when(challengeRepository.findPlacementFallbackCandidates(
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.JUNIOR))
            .thenReturn(List.of(juniorOne, juniorTwo));
        when(challengeRepository.findPlacementFallbackCandidates(
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.INTERMEDIATE))
            .thenReturn(List.of(intermediate));
        when(challengeRepository.findPlacementFallbackCandidates(
            ChallengeType.CODE_REVIEW, DifficultyLevel.INTERMEDIATE))
            .thenReturn(List.of(codeReview));
        when(challengeRepository.findPlacementFallbackCandidates(
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.ADVANCED))
            .thenReturn(List.of(advanced));

        when(simulationRepository.save(any(Simulation.class))).thenAnswer(invocation -> {
            Simulation simulation = invocation.getArgument(0);
            ReflectionTestUtils.setField(simulation, "id", 22L);
            return simulation;
        });

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), null, true));

        assertEquals(5, response.challenges().size());
        assertEquals(ChallengeType.SITUATIONAL_QCM, response.mode());
        assertEquals(List.of(
            ChallengeType.SITUATIONAL_QCM,
            ChallengeType.SITUATIONAL_QCM,
            ChallengeType.SITUATIONAL_QCM,
            ChallengeType.CODE_REVIEW,
            ChallengeType.SITUATIONAL_QCM),
            response.challenges().stream().map(challenge -> challenge.type()).toList());
    }

    private InterviewScenario scenario(Long id, String title) {
        InterviewScenario scenario = new InterviewScenario();
        ReflectionTestUtils.setField(scenario, "id", id);
        scenario.setTitle(title);
        scenario.setMode(ChallengeType.ARCHITECTURE);
        scenario.setActive(true);
        return scenario;
    }

    private Challenge challenge(InterviewScenario scenario, int order, String title) {
        Challenge challenge = new Challenge();
        challenge.setTitle(title);
        challenge.setType(ChallengeType.ARCHITECTURE);
        challenge.setDifficulty(DifficultyLevel.INTERMEDIATE);
        challenge.setQuestion(title + " question?");
        challenge.setScenario(scenario);
        challenge.setStepOrder(order);
        challenge.setStatus(ContentStatus.VALIDATED);
        return challenge;
    }

    private Challenge placementChallenge(
            Long id, String title, ChallengeType type, DifficultyLevel difficulty) {
        Challenge challenge = new Challenge();
        ReflectionTestUtils.setField(challenge, "id", id);
        challenge.setTitle(title);
        challenge.setType(type);
        challenge.setDifficulty(difficulty);
        challenge.setQuestion(title);
        challenge.setStatus(ContentStatus.VALIDATED);
        challenge.setActive(true);
        return challenge;
    }
}
