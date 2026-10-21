package com.interview.simulator.user.service;

import com.interview.simulator.category.entity.Category;
import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.entity.SimulationAnswer;
import com.interview.simulator.simulation.entity.SimulationChallenge;
import com.interview.simulator.simulation.entity.SimulationStatus;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.user.dto.UserStatsResponse;
import com.interview.simulator.user.entity.User;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class UserStatsServiceTest {

    private final UserResolver userResolver = mock(UserResolver.class);

    @Test
    void reportsWeakPointsByCategoryAndSkillWithVolume() {
        User user = new User("tester", "tester@example.com");
        when(userResolver.currentOrNull()).thenReturn(Optional.of(user));

        Category java = category(1L, "Java");
        Category spring = category(2L, "Spring Boot");
        Skill debugging = skill(3L, "Debugging");
        Skill problemSolving = skill(4L, "Problem Solving");

        Simulation simulation = new Simulation();
        simulation.setMode(ChallengeType.SITUATIONAL_QCM);
        simulation.setStatus(SimulationStatus.COMPLETED);
        for (int i = 0; i < 3; i++) {
            simulation.getSimulationChallenges().add(
                    challenge(simulation, i, java, debugging, i < 2));
            simulation.getSimulationChallenges().add(
                    challenge(simulation, i + 3, spring, problemSolving, false));
        }
        simulation.getSimulationChallenges().add(
                challenge(simulation, 6, java, debugging, false));

        SimulationRepository repository = mock(SimulationRepository.class);
        when(repository.findAllByUserIdWithChallenges(null)).thenReturn(List.of(simulation));
        UserStatsService service = new UserStatsService(userResolver, repository);

        UserStatsResponse stats = service.getStats(0, 5);

        assertEquals(4, stats.weakPoints().size());
        assertEquals("Spring Boot", stats.weakPoints().get(0).name());
        assertEquals("CATEGORY", stats.weakPoints().get(0).source());
        assertEquals(0, stats.weakPoints().get(0).correct());
        assertEquals(3, stats.weakPoints().get(0).answered());
        assertEquals("Problem Solving", stats.weakPoints().get(1).name());
        assertEquals("SKILL", stats.weakPoints().get(1).source());
        assertEquals(0, stats.weakPoints().get(1).correct());
        assertEquals(3, stats.weakPoints().get(1).answered());
        assertEquals("Java", stats.weakPoints().get(2).name());
        assertEquals(2, stats.weakPoints().get(2).correct());
        assertEquals(4, stats.weakPoints().get(2).answered());
    }

    private SimulationChallenge challenge(
            Simulation simulation, int order, Category category, Skill skill, boolean correct) {
        Challenge challenge = new Challenge();
        challenge.setType(ChallengeType.SITUATIONAL_QCM);
        challenge.getCategories().add(category);
        challenge.getSkills().add(skill);

        SimulationChallenge simulationChallenge = new SimulationChallenge();
        simulationChallenge.setSimulation(simulation);
        simulationChallenge.setChallenge(challenge);
        simulationChallenge.setDisplayOrder(order);

        SimulationAnswer answer = new SimulationAnswer();
        answer.setCorrect(correct);
        answer.setScore(correct ? 10 : 0);
        answer.setSelectedOptions(Set.of());
        answer.setSimulationChallenge(simulationChallenge);
        simulationChallenge.setAnswer(answer);
        return simulationChallenge;
    }

    private Category category(Long id, String name) {
        Category category = mock(Category.class);
        when(category.getId()).thenReturn(id);
        when(category.getName()).thenReturn(name);
        return category;
    }

    private Skill skill(Long id, String name) {
        Skill skill = mock(Skill.class);
        when(skill.getId()).thenReturn(id);
        when(skill.getName()).thenReturn(name);
        return skill;
    }
}
