package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.repository.ChallengeOptionRepository;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.simulation.dto.SimulationChallengeResponse;
import com.interview.simulator.simulation.dto.SimulationResponse;
import com.interview.simulator.simulation.dto.StartSimulationRequest;
import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.entity.SimulationChallenge;
import com.interview.simulator.simulation.repository.SimulationChallengeRepository;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
public class SimulationService {

    private final SimulationRepository simulationRepository;
    private final ChallengeRepository challengeRepository;
    private final UserRepository userRepository;
    private final SimulationChallengeRepository simulationChallengeRepository;
    private final ChallengeOptionRepository challengeOptionRepository;

    public SimulationService(
            SimulationRepository simulationRepository,
            ChallengeRepository challengeRepository,
            UserRepository userRepository,
            SimulationChallengeRepository simulationChallengeRepository,
            ChallengeOptionRepository challengeOptionRepository) {
        this.simulationRepository = simulationRepository;
        this.challengeRepository = challengeRepository;
        this.userRepository = userRepository;
        this.simulationChallengeRepository = simulationChallengeRepository;
        this.challengeOptionRepository = challengeOptionRepository;
    }

    @Transactional
    public SimulationResponse startSimulation(StartSimulationRequest request) {
        // 1. Récupérer l'utilisateur par défaut (pour le MVP sans authentification)
        User user = userRepository.findByUsername("default_user")
                .orElseGet(() -> userRepository.save(new User("default_user", "dev@example.com")));

        // 2. Trouver les challenges correspondants aux filtres
        List<Challenge> matchingChallenges = challengeRepository.findMatchingChallenges(
                request.mode(),
                request.categoryIds(),
                request.skillIds()
        );

        if (matchingChallenges.isEmpty()) {
            throw new IllegalArgumentException("Aucune question trouvée pour les critères sélectionnés.");
        }

        // 3. Tirage aléatoire de 10 questions maximum
        List<Challenge> selectedChallenges = new ArrayList<>(matchingChallenges);
        Collections.shuffle(selectedChallenges);
        if (selectedChallenges.size() > 10) {
            selectedChallenges = selectedChallenges.subList(0, 10);
        }

        // 4. Créer la simulation
        Simulation simulation = new Simulation();
        simulation.setUser(user);
        simulation.setMode(request.mode());
        simulation.setDifficulty(request.difficulty());

        // 5. Associer les questions avec leur ordre d'affichage
        int order = 1;
        for (Challenge challenge : selectedChallenges) {
            SimulationChallenge sc = new SimulationChallenge();
            sc.setSimulation(simulation);
            sc.setChallenge(challenge);
            sc.setDisplayOrder(order++);
            simulation.getSimulationChallenges().add(sc);
        }

        Simulation saved = simulationRepository.save(simulation);

        return mapToResponse(saved);
    }

    private SimulationResponse mapToResponse(Simulation simulation) {
        List<SimulationChallengeResponse> challengeResponses = simulation.getSimulationChallenges().stream()
                .map(sc -> new SimulationChallengeResponse(
                        sc.getId(),
                        sc.getDisplayOrder(),
                        sc.getChallenge().getId(),
                        sc.getChallenge().getTitle(),
                        sc.getChallenge().getContext(),
                        sc.getChallenge().getQuestion(),
                        sc.getChallenge().getOptions().stream()
                                .map(o -> new SimulationChallengeResponse.OptionResponse(
                                        o.getId(),
                                        o.getContent(),
                                        o.getDisplayOrder()
                                ))
                                .toList()
                ))
                .toList();

        return new SimulationResponse(
                simulation.getId(),
                simulation.getMode(),
                simulation.getDifficulty(),
                simulation.getStatus(),
                simulation.getTotalScore(),
                simulation.getStartedAt(),
                challengeResponses
        );
    }
}