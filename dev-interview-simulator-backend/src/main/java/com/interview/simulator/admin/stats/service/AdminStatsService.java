package com.interview.simulator.admin.stats.service;

import com.interview.simulator.admin.stats.dto.AdminStatsResponse;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.simulation.entity.SimulationStatus;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.repository.UserRepository;
import com.interview.simulator.user.service.UserResolver;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class AdminStatsService {

    private static final int NEW_USERS_WINDOW_DAYS = 7;
    private static final int NEW_USERS_LONG_WINDOW_DAYS = 30;

    private final ChallengeRepository challengeRepository;
    private final ProfileRepository profileRepository;
    private final InterviewScenarioRepository interviewScenarioRepository;
    private final SimulationRepository simulationRepository;
    private final UserRepository userRepository;

    public AdminStatsService(
            ChallengeRepository challengeRepository,
            ProfileRepository profileRepository,
            InterviewScenarioRepository interviewScenarioRepository,
            SimulationRepository simulationRepository,
            UserRepository userRepository) {
        this.challengeRepository = challengeRepository;
        this.profileRepository = profileRepository;
        this.interviewScenarioRepository = interviewScenarioRepository;
        this.simulationRepository = simulationRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public AdminStatsResponse getStats() {
        Map<String, Long> byType = new LinkedHashMap<>();
        for (ChallengeType type : ChallengeType.values()) {
            byType.put(type.name(), challengeRepository.countByType(type));
        }

        long totalSimulations = simulationRepository.count();
        long completedSimulations = simulationRepository.countByStatus(SimulationStatus.COMPLETED);
        long inProgressSimulations = simulationRepository.countByStatus(SimulationStatus.IN_PROGRESS);
        long abandonedSimulations = simulationRepository.countByStatus(SimulationStatus.ABANDONED);
        long registeredSimulations = simulationRepository.countByUserUsernameNot(UserResolver.GUEST_USERNAME);
        long activeUsers = simulationRepository.countDistinctRegisteredUsersWithSimulations(
                UserResolver.GUEST_USERNAME);
        long placementSimulations = simulationRepository.countByPlacementTrue();
        long placementCompleted =
                simulationRepository.countByPlacementTrueAndStatus(SimulationStatus.COMPLETED);
        long guestPlacementSimulations =
                simulationRepository.countByPlacementTrueAndUserUsername(UserResolver.GUEST_USERNAME);
        LocalDateTime now = LocalDateTime.now();

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
                totalSimulations,
                completedSimulations,
                inProgressSimulations,
                userRepository.countByUsernameNot(UserResolver.GUEST_USERNAME),
                userRepository.countByUsernameNotAndCreatedAtAfter(
                        UserResolver.GUEST_USERNAME, now.minusDays(NEW_USERS_WINDOW_DAYS)),
                userRepository.countByUsernameNotAndCreatedAtAfter(
                        UserResolver.GUEST_USERNAME, now.minusDays(NEW_USERS_LONG_WINDOW_DAYS)),
                abandonedSimulations,
                percentage(completedSimulations, totalSimulations),
                average(registeredSimulations, activeUsers),
                placementSimulations,
                placementCompleted,
                guestPlacementSimulations
        );
    }

    private Double percentage(long part, long total) {
        return total == 0 ? null : Math.round(part * 1000.0 / total) / 10.0;
    }

    private Double average(long simulations, long users) {
        return users == 0 ? null : Math.round(simulations * 10.0 / users) / 10.0;
    }
}
