package com.interview.simulator.admin.stats.service;

import com.interview.simulator.admin.stats.dto.AdminStatsResponse;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.simulation.entity.SimulationStatus;
import com.interview.simulator.simulation.repository.SimulationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class AdminStatsService {

    private final ChallengeRepository challengeRepository;
    private final ProfileRepository profileRepository;
    private final InterviewScenarioRepository interviewScenarioRepository;
    private final SimulationRepository simulationRepository;

    public AdminStatsService(
            ChallengeRepository challengeRepository,
            ProfileRepository profileRepository,
            InterviewScenarioRepository interviewScenarioRepository,
            SimulationRepository simulationRepository) {
        this.challengeRepository = challengeRepository;
        this.profileRepository = profileRepository;
        this.interviewScenarioRepository = interviewScenarioRepository;
        this.simulationRepository = simulationRepository;
    }

    @Transactional(readOnly = true)
    public AdminStatsResponse getStats() {
        Map<String, Long> byType = new LinkedHashMap<>();
        for (ChallengeType type : ChallengeType.values()) {
            byType.put(type.name(), challengeRepository.countByType(type));
        }

        return new AdminStatsResponse(
                challengeRepository.count(),
                challengeRepository.countByStatus(ContentStatus.DRAFT),
                challengeRepository.countByStatus(ContentStatus.VALIDATED),
                challengeRepository.countByStatus(ContentStatus.ARCHIVED),
                byType,
                profileRepository.count(),
                profileRepository.countByActiveTrue(),
                interviewScenarioRepository.count(),
                interviewScenarioRepository.countByActiveTrue(),
                simulationRepository.count(),
                simulationRepository.countByStatus(SimulationStatus.COMPLETED),
                simulationRepository.countByStatus(SimulationStatus.IN_PROGRESS)
        );
    }
}
