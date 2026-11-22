package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.category.entity.Category;
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
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
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
    void startPlacementSimulationDrawsSixOrderedChallenges() {
        User user = new User("guest", "guest@example.test");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        stubPlacementPool(List.of(
            placementChallenge(101L, "Java junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Java"),
            placementChallenge(102L, "Spring junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Spring Boot"),
            placementChallenge(103L, "Java intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Java"),
            placementChallenge(104L, "Spring review", ChallengeType.CODE_REVIEW,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(105L, "Spring intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(106L, "Java advanced", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.ADVANCED, "Java")
        ));
        stubSimulationSave(22L);

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), null, true));

        assertEquals(List.of(101L, 102L, 103L, 104L, 105L, 106L),
            response.challenges().stream().map(challenge -> challenge.challengeId()).toList());
        Map<Long, DifficultyLevel> difficulties = Map.of(
            101L, DifficultyLevel.JUNIOR,
            102L, DifficultyLevel.JUNIOR,
            103L, DifficultyLevel.INTERMEDIATE,
            104L, DifficultyLevel.INTERMEDIATE,
            105L, DifficultyLevel.INTERMEDIATE,
            106L, DifficultyLevel.ADVANCED);
        assertEquals(List.of(
            DifficultyLevel.JUNIOR,
            DifficultyLevel.JUNIOR,
            DifficultyLevel.INTERMEDIATE,
            DifficultyLevel.INTERMEDIATE,
            DifficultyLevel.INTERMEDIATE,
            DifficultyLevel.ADVANCED),
            response.challenges().stream()
                .map(challenge -> difficulties.get(challenge.challengeId()))
                .toList());
    }

    @Test
    void placementDrawNeverSelectsQuestionsOutsideJavaAndSpringBoot() {
        User user = new User("guest", "guest@example.test");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        stubPlacementPool(List.of(
            placementChallenge(101L, "Java junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Java"),
            placementChallenge(102L, "Spring junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Spring Boot"),
            placementChallenge(103L, "Java intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Java"),
            placementChallenge(104L, "Spring review", ChallengeType.CODE_REVIEW,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(105L, "Spring intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(106L, "Java advanced", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.ADVANCED, "Java"),
            placementChallenge(201L, "SQL junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "SQL / PostgreSQL"),
            placementChallenge(202L, "JPA review", ChallengeType.CODE_REVIEW,
                DifficultyLevel.INTERMEDIATE, "JPA / Hibernate"),
            placementChallenge(203L, "API intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "API / Backend"),
            placementChallenge(204L, "SQL advanced", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.ADVANCED, "SQL / PostgreSQL")
        ));
        stubSimulationSave(26L);

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), null, true));

        assertEquals(Set.of(101L, 102L, 103L, 104L, 105L, 106L),
            response.challenges().stream()
                .map(challenge -> challenge.challengeId())
                .collect(Collectors.toSet()));
    }

    @Test
    void placementDrawNeverRepeatsAQuestion() {
        User user = new User("guest", "guest@example.test");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        stubPlacementPool(List.of(
            placementChallenge(101L, "Java junior one", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Java"),
            placementChallenge(102L, "Java junior two", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Java"),
            placementChallenge(103L, "Spring junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Spring Boot"),
            placementChallenge(104L, "Java intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Java"),
            placementChallenge(105L, "Spring intermediate one", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(106L, "Spring intermediate two", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(107L, "Spring review", ChallengeType.CODE_REVIEW,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(108L, "Java advanced", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.ADVANCED, "Java")
        ));
        stubSimulationSave(27L);

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), null, true));

        assertEquals(6, response.challenges().size());
        assertEquals(6, response.challenges().stream()
            .map(challenge -> challenge.challengeId())
            .distinct()
            .count());
    }

    @Test
    void placementDrawSkipsSeenChallenges() {
        User user = new User("guest", "guest@example.test");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        stubPlacementPool(List.of(
            placementChallenge(101L, "Java junior seen", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Java"),
            placementChallenge(102L, "Java junior fresh", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Java"),
            placementChallenge(103L, "Spring junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Spring Boot"),
            placementChallenge(104L, "Java intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Java"),
            placementChallenge(105L, "Spring review", ChallengeType.CODE_REVIEW,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(106L, "Spring intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(107L, "Java advanced", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.ADVANCED, "Java")
        ));
        stubSimulationSave(28L);

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), Set.of(101L), true));

        List<Long> challengeIds = response.challenges().stream()
            .map(challenge -> challenge.challengeId())
            .toList();
        assertEquals(102L, challengeIds.get(0));
        assertFalse(challengeIds.contains(101L));
    }

    @Test
    void placementDrawFallsBackToOtherCategoryThenToQcm() {
        User user = new User("guest", "guest@example.test");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        stubPlacementPool(List.of(
            placementChallenge(102L, "Spring junior one", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Spring Boot"),
            placementChallenge(103L, "Spring junior two", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Spring Boot"),
            placementChallenge(105L, "Java intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Java"),
            placementChallenge(107L, "Spring intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(108L, "Java advanced", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.ADVANCED, "Java")
        ));
        stubSimulationSave(29L);

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), null, true));

        assertEquals(5, response.challenges().size());
        assertEquals(Set.of(102L, 103L), Set.copyOf(response.challenges().stream()
            .limit(2)
            .map(challenge -> challenge.challengeId())
            .toList()));
        assertEquals(ChallengeType.SITUATIONAL_QCM, response.challenges().get(3).type());
        assertEquals(107L, response.challenges().get(3).challengeId());
    }

    @Test
    void placementPositionWithoutCandidateDoesNotFailStart() {
        User user = new User("guest", "guest@example.test");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        stubPlacementPool(List.of(
            placementChallenge(101L, "Java junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Java"),
            placementChallenge(102L, "Spring junior", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR, "Spring Boot"),
            placementChallenge(103L, "Java intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Java"),
            placementChallenge(104L, "Spring review", ChallengeType.CODE_REVIEW,
                DifficultyLevel.INTERMEDIATE, "Spring Boot"),
            placementChallenge(105L, "Spring intermediate", ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.INTERMEDIATE, "Spring Boot")
        ));
        stubSimulationSave(30L);

        SimulationResponse response = simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), null, true));

        assertEquals(5, response.challenges().size());
    }

    @Test
    void placementSimulationIsFlaggedAsPlacement() {
        User user = new User("guest", "guest@example.test");
        Challenge junior = placementChallenge(101L, "Junior",
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.JUNIOR, "Java");
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        stubPlacementPool(List.of(junior));
        when(simulationRepository.save(any(Simulation.class))).thenAnswer(invocation -> {
            Simulation simulation = invocation.getArgument(0);
            ReflectionTestUtils.setField(simulation, "id", 24L);
            return simulation;
        });
        ArgumentCaptor<Simulation> captor = ArgumentCaptor.forClass(Simulation.class);

        simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, null, null,
            Set.of(), Set.of(), null, true));

        verify(simulationRepository).save(captor.capture());
        assertTrue(captor.getValue().isPlacement());
    }

    @Test
    void configuredSimulationIsNotFlaggedAsPlacement() {
        User user = new User("guest", "guest@example.test");
        Challenge challenge = placementChallenge(201L, "Configured",
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.JUNIOR);
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));
        when(challengeRepository.findMatchingChallenges(
            eq(ChallengeType.SITUATIONAL_QCM), eq(DifficultyLevel.JUNIOR), eq(null),
            eq(ContentStatus.VALIDATED), any(), any()))
            .thenReturn(List.of(challenge));
        when(simulationRepository.save(any(Simulation.class))).thenAnswer(invocation -> {
            Simulation simulation = invocation.getArgument(0);
            ReflectionTestUtils.setField(simulation, "id", 25L);
            return simulation;
        });
        ArgumentCaptor<Simulation> captor = ArgumentCaptor.forClass(Simulation.class);

        simulationService.startSimulation(new StartSimulationRequest(
            ChallengeType.SITUATIONAL_QCM, DifficultyLevel.JUNIOR, null,
            Set.of(), Set.of(), null, false));

        verify(simulationRepository).save(captor.capture());
        assertFalse(captor.getValue().isPlacement());
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
            Long id, String title, ChallengeType type, DifficultyLevel difficulty,
            String... categories) {
        Challenge challenge = new Challenge();
        ReflectionTestUtils.setField(challenge, "id", id);
        challenge.setTitle(title);
        challenge.setType(type);
        challenge.setDifficulty(difficulty);
        challenge.setQuestion(title);
        challenge.setStatus(ContentStatus.VALIDATED);
        challenge.setActive(true);
        for (String category : categories) {
            challenge.getCategories().add(new Category(category, null));
        }
        return challenge;
    }

    private void stubPlacementPool(List<Challenge> pool) {
        when(challengeRepository.findPlacementFallbackCandidates(
            any(ChallengeType.class), any(DifficultyLevel.class), anyCollection()))
            .thenAnswer(invocation -> {
                ChallengeType type = invocation.getArgument(0);
                DifficultyLevel difficulty = invocation.getArgument(1);
                Collection<String> categories = invocation.getArgument(2);
                return pool.stream()
                    .filter(challenge -> challenge.getType() == type)
                    .filter(challenge -> challenge.getDifficulty() == difficulty)
                    .filter(challenge -> challenge.getCategories().stream()
                        .anyMatch(category -> categories.contains(category.getName())))
                    .toList();
            });
    }

    private void stubSimulationSave(Long id) {
        when(simulationRepository.save(any(Simulation.class))).thenAnswer(invocation -> {
            Simulation simulation = invocation.getArgument(0);
            ReflectionTestUtils.setField(simulation, "id", id);
            return simulation;
        });
    }
}
