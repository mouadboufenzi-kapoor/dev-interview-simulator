package com.interview.simulator.admin.scenario.service;

import com.interview.simulator.admin.scenario.dto.AdminScenarioResponse;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AdminScenarioServiceTest {

    @Mock private InterviewScenarioRepository interviewScenarioRepository;
    @Mock private ChallengeRepository challengeRepository;

    @InjectMocks private AdminScenarioService adminScenarioService;

    @Test
    void getScenariosIncludesActiveInactiveAndZeroStepScenarios() {
        InterviewScenario populated = scenario(1L, "A populated", true);
        InterviewScenario empty = scenario(2L, "B empty", false);
        when(interviewScenarioRepository.findByModeOrderByTitleAscIdAsc(
                eq(ChallengeType.ARCHITECTURE), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(populated, empty), PageRequest.of(0, 10), 2));
        when(challengeRepository.countByScenarioId(1L)).thenReturn(3L);
        when(challengeRepository.countByScenarioId(2L)).thenReturn(0L);

        var result = adminScenarioService.getScenarios(0, 10);

        assertEquals(2, result.getTotalElements());
        List<AdminScenarioResponse> scenarios = result.getContent();
        assertEquals(2, scenarios.size());
        assertEquals("A populated", scenarios.get(0).title());
        assertEquals(3L, scenarios.get(0).stepCount());
        assertEquals("B empty", scenarios.get(1).title());
        assertEquals(0L, scenarios.get(1).stepCount());
        assertEquals(10, result.getSize());
    }

    private InterviewScenario scenario(Long id, String title, boolean active) {
        InterviewScenario scenario = new InterviewScenario();
        ReflectionTestUtils.setField(scenario, "id", id);
        scenario.setTitle(title);
        scenario.setMode(ChallengeType.ARCHITECTURE);
        scenario.setActive(active);
        return scenario;
    }
}
