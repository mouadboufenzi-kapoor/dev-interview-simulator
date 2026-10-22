package com.interview.simulator.user.service;

import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.dto.UserStatsResponse;
import com.interview.simulator.user.entity.User;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.PageImpl;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class UserStatsServiceTest {

    private final UserResolver userResolver = mock(UserResolver.class);

    @Test
    void reportsWeakPointsByCategoryAndSkillWithVolume() {
        User user = new User("tester", "tester@example.com");
        ReflectionTestUtils.setField(user, "id", 7L);
        when(userResolver.currentOrNull()).thenReturn(Optional.of(user));

        SimulationRepository repository = mock(SimulationRepository.class);
        when(repository.findUserSimulationCounts(7L)).thenAnswer(
                invocation -> new Object[]{new Object[]{2L, 2L}});
        when(repository.findUserAnswerCounts(7L)).thenAnswer(
                invocation -> new Object[]{new Object[]{10L, 7L}});
        when(repository.findUserCategoryStats(7L)).thenReturn(java.util.Arrays.asList(
                new Object[]{new Object[]{2L, "Spring Boot", 3L, 0L}},
                new Object[]{new Object[]{1L, "Java", 4L, 2L}}));
        when(repository.findUserSkillStats(7L)).thenReturn(java.util.Arrays.asList(
                new Object[]{new Object[]{4L, "Problem Solving", 3L, 0L}},
                new Object[]{new Object[]{3L, "Debugging", 4L, 3L}}));
        when(repository.findUserTypeStats(7L)).thenReturn(java.util.Collections.singletonList(
                new Object[]{new Object[]{"SITUATIONAL_QCM", 7L, 3L}}));
        when(repository.findRecentCompletedSimulationRates(7L)).thenReturn(List.of());
        when(repository.findCompletedSimulationRateSummary(7L)).thenAnswer(
                invocation -> new Object[]{new Object[]{42.5, 75.0}});
        when(repository.findRecentSimulationsByUserId(org.mockito.ArgumentMatchers.eq(7L), any()))
                .thenReturn(new PageImpl<>(List.of(), org.springframework.data.domain.PageRequest.of(0, 5), 0));
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
        assertEquals(70.0, stats.globalSuccessRate());
        assertEquals(42.0, stats.averageSuccessRate());
        assertEquals(75.0, stats.bestSuccessRate());
        verify(repository).findRecentSimulationsByUserId(org.mockito.ArgumentMatchers.eq(7L), any());
    }
}
