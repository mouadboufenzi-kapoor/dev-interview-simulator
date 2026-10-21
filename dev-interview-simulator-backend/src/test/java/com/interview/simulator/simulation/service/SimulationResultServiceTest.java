package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.exception.ResourceNotFoundException;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.simulation.dto.SimulationResultDTO;
import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.entity.SimulationAnswer;
import com.interview.simulator.simulation.entity.SimulationChallenge;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.service.UserResolver;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class SimulationResultServiceTest {

    @Test
    void includesAnsweredTimedOutAndUnansweredQuestionsInDisplayOrder() throws Exception {
        Simulation simulation = new Simulation();
        simulation.setMode(ChallengeType.SITUATIONAL_QCM);
        simulation.getSimulationChallenges().add(question(simulation, 3, "Jamais atteinte", null));
        simulation.getSimulationChallenges().add(question(simulation, 1, "Répondue", answeredAnswer()));
        simulation.getSimulationChallenges().add(question(simulation, 2, "Expirée", timedOutAnswer()));

        simulation.setUser(new User(UserResolver.GUEST_USERNAME, "guest@example.com"));
        simulation.setGuestAccessTokenHash(null);

        String guestAccessToken = "test-guest-token";
        simulation.setGuestAccessTokenHash(HexFormat.of().formatHex(
                MessageDigest.getInstance("SHA-256")
                        .digest(guestAccessToken.getBytes(StandardCharsets.US_ASCII))));
        SimulationRepository repository = mock(SimulationRepository.class);
        when(repository.findById(42L)).thenReturn(Optional.of(simulation));
        UserResolver userResolver = mock(UserResolver.class);
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.empty());
        SimulationService service = new SimulationService(
                repository, null, userResolver, null, null, null, new ScoringService(), null, null);

        SimulationResultDTO result = service.getSimulationResult(42L, guestAccessToken);

        assertEquals(3, result.totalQuestions());
        assertEquals(1, result.correctAnswersCount());
        assertEquals(30, result.maxPossibleScore());
        assertEquals(33.33, result.successPercentage());
        assertEquals(List.of("Répondue", "Expirée", "Jamais atteinte"),
                result.questions().stream().map(SimulationResultDTO.QuestionSummaryDTO::title).toList());
        assertEquals(List.of(
                        SimulationResultDTO.QuestionStatus.ANSWERED,
                        SimulationResultDTO.QuestionStatus.TIMED_OUT,
                        SimulationResultDTO.QuestionStatus.UNANSWERED),
                result.questions().stream().map(SimulationResultDTO.QuestionSummaryDTO::status).toList());
        assertEquals("Choix utilisateur", result.questions().get(0).userSelectedOptionContent());
        assertEquals(List.of("Java"), result.questions().get(0).categories());
        assertEquals(List.of("Debugging"), result.questions().get(0).skills());
        assertEquals(List.of("Spring Boot"), result.questions().get(1).categories());
        assertEquals(List.of("Problem Solving"), result.questions().get(1).skills());
        assertEquals(List.of("Java"), result.questions().get(2).categories());
        assertEquals(List.of(), result.questions().get(2).skills());
        assertNull(result.questions().get(1).userSelectedOptionContent());
        assertNull(result.questions().get(2).userSelectedOptionContent());
        assertEquals(0, result.questions().get(1).pointsEarned());
        assertEquals(0, result.questions().get(2).pointsEarned());
        assertNull(result.questions().get(2).timeSpentMs());
        assertEquals(List.of("Java", "Spring Boot"), result.categoryResults().stream()
                .map(SimulationResultDTO.CompetencyResult::name).toList());
        assertEquals(List.of("Debugging", "Problem Solving"), result.skillResults().stream()
                .map(SimulationResultDTO.CompetencyResult::name).toList());
        assertEquals(1, result.categoryResults().get(0).correct());
        assertEquals(2, result.categoryResults().get(0).total());
        assertEquals(0, result.categoryResults().get(1).correct());
        assertEquals(1, result.categoryResults().get(1).total());
        assertEquals(1, result.skillResults().get(0).correct());
        assertEquals(1, result.skillResults().get(0).total());
        assertEquals(0, result.skillResults().get(1).correct());
        assertEquals(1, result.skillResults().get(1).total());
        assertEquals(List.of("Spring Boot", "Java"), result.weakCategoryResults().stream()
                .map(SimulationResultDTO.CompetencyResult::name).toList());
        assertEquals(List.of("Problem Solving"), result.weakSkillResults().stream()
                .map(SimulationResultDTO.CompetencyResult::name).toList());
    }

    @Test
    void rejectsAuthenticatedUserWhenSimulationBelongsToAnotherAccount() {
        Simulation simulation = new Simulation();
        User owner = mock(User.class);
        when(owner.getId()).thenReturn(10L);
        simulation.setUser(owner);
        SimulationRepository repository = mock(SimulationRepository.class);
        when(repository.findById(42L)).thenReturn(Optional.of(simulation));
        User currentUser = mock(User.class);
        when(currentUser.getId()).thenReturn(20L);
        UserResolver userResolver = mock(UserResolver.class);
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(currentUser));
        SimulationService service = new SimulationService(
                repository, null, userResolver, null, null, null, new ScoringService(), null, null);

        assertThrows(ResourceNotFoundException.class, () -> service.getSimulationResult(42L, null));
    }

    @Test
    void rejectsGuestWithoutMatchingSimulationAccessToken() {
        Simulation simulation = new Simulation();
        simulation.setUser(new User("default_user", "guest@example.com"));
        simulation.setGuestAccessTokenHash("some-stored-hash");
        SimulationRepository repository = mock(SimulationRepository.class);
        when(repository.findById(42L)).thenReturn(Optional.of(simulation));
        UserResolver userResolver = mock(UserResolver.class);
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.empty());
        SimulationService service = new SimulationService(
                repository, null, userResolver, null, null, null, new ScoringService(), null, null);

        assertThrows(ResourceNotFoundException.class, () -> service.getSimulationResult(42L, null));
        assertThrows(ResourceNotFoundException.class,
                () -> service.getSimulationResult(42L, "not-the-guest-token"));
    }

    private SimulationChallenge question(
            Simulation simulation, int order, String title, SimulationAnswer answer) {
        Challenge challenge = new Challenge();
        challenge.setTitle(title);
        challenge.setQuestion("Question " + title);
        challenge.setPoints(10);
        Category category = mock(Category.class);
        when(category.getId()).thenReturn(title.equals("Expirée") ? 2L : 1L);
        when(category.getName()).thenReturn(title.equals("Expirée") ? "Spring Boot" : "Java");
        challenge.getCategories().add(category);
        if (!title.equals("Jamais atteinte")) {
            Skill skill = mock(Skill.class);
            when(skill.getId()).thenReturn(title.equals("Expirée") ? 3L : 2L);
            when(skill.getName()).thenReturn(title.equals("Expirée") ? "Problem Solving" : "Debugging");
            challenge.getSkills().add(skill);
        }
        ChallengeOption correct = mock(ChallengeOption.class);
        when(correct.isCorrect()).thenReturn(true);
        when(correct.getContent()).thenReturn("Réponse attendue");
        when(correct.getDisplayOrder()).thenReturn(1);
        challenge.getOptions().add(correct);

        SimulationChallenge simulationChallenge = new SimulationChallenge();
        simulationChallenge.setSimulation(simulation);
        simulationChallenge.setChallenge(challenge);
        simulationChallenge.setDisplayOrder(order);
        if (answer != null) {
            answer.setSimulationChallenge(simulationChallenge);
            simulationChallenge.setAnswer(answer);
        }
        return simulationChallenge;
    }

    private SimulationAnswer answeredAnswer() {
        SimulationAnswer answer = new SimulationAnswer();
        ChallengeOption selected = mock(ChallengeOption.class);
        when(selected.getContent()).thenReturn("Choix utilisateur");
        answer.setSelectedOptions(new LinkedHashSet<>(Set.of(selected)));
        answer.setCorrect(true);
        answer.setScore(10);
        answer.setResponseTimeMs(5_000L);
        return answer;
    }

    private SimulationAnswer timedOutAnswer() {
        SimulationAnswer answer = new SimulationAnswer();
        answer.setSelectedOptions(new LinkedHashSet<>());
        answer.setCorrect(false);
        answer.setScore(0);
        answer.setResponseTimeMs(90_000L);
        return answer;
    }
}
