package com.interview.simulator.admin.scenario.service;

import com.interview.simulator.admin.scenario.dto.AdminScenarioRequest;
import com.interview.simulator.admin.scenario.dto.AdminScenarioResponse;
import com.interview.simulator.admin.scenario.dto.AdminScenarioStepResponse;
import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.exception.ResourceNotFoundException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AdminScenarioService {

    private final InterviewScenarioRepository interviewScenarioRepository;
    private final ChallengeRepository challengeRepository;

    public AdminScenarioService(
            InterviewScenarioRepository interviewScenarioRepository,
            ChallengeRepository challengeRepository) {
        this.interviewScenarioRepository = interviewScenarioRepository;
        this.challengeRepository = challengeRepository;
    }

    @Transactional(readOnly = true)
    public List<AdminScenarioResponse> getActiveScenarios() {
        return interviewScenarioRepository.findByActiveTrueOrderByTitleAsc().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public AdminScenarioResponse create(AdminScenarioRequest request) {
        InterviewScenario scenario = new InterviewScenario();
        scenario.setTitle(request.title().trim());
        scenario.setDescription(request.description());
        scenario.setMode(ChallengeType.ARCHITECTURE);
        scenario.setActive(true);
        try {
            return toResponse(interviewScenarioRepository.saveAndFlush(scenario));
        } catch (DataIntegrityViolationException e) {
            throw new ApiException(HttpStatus.CONFLICT, "Un scénario avec ce titre existe déjà.");
        }
    }

    @Transactional(readOnly = true)
    public List<AdminScenarioStepResponse> getSteps(Long scenarioId) {
        findScenario(scenarioId);
        return challengeRepository.findByScenarioIdOrderByStepOrderAsc(scenarioId).stream()
                .map(challenge -> new AdminScenarioStepResponse(
                        challenge.getId(),
                        challenge.getTitle(),
                        challenge.getStepOrder()
                ))
                .toList();
    }

    private AdminScenarioResponse toResponse(InterviewScenario scenario) {
        return new AdminScenarioResponse(
                scenario.getId(),
                scenario.getTitle(),
                scenario.getDescription(),
                scenario.getMode(),
                scenario.isActive(),
                challengeRepository.countByScenarioId(scenario.getId())
        );
    }

    private InterviewScenario findScenario(Long id) {
        return interviewScenarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Scénario introuvable."));
    }
}
