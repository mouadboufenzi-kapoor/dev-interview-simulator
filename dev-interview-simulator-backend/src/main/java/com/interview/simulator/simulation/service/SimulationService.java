package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.repository.ChallengeOptionRepository;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.simulation.dto.SimulationChallengeResponse;
import com.interview.simulator.simulation.dto.SimulationResponse;
import com.interview.simulator.simulation.dto.SimulationSummaryResponse;
import com.interview.simulator.simulation.dto.StartSimulationRequest;
import com.interview.simulator.simulation.dto.SubmitAnswerRequest;
import com.interview.simulator.simulation.dto.SubmitAnswerResponse;
import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.entity.SimulationAnswer;
import com.interview.simulator.simulation.entity.SimulationChallenge;
import com.interview.simulator.simulation.entity.SimulationStatus;
import com.interview.simulator.simulation.repository.SimulationChallengeRepository;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
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

    @Transactional
    public SubmitAnswerResponse submitAnswer(Long simulationId, SubmitAnswerRequest request) {
        Simulation simulation = simulationRepository.findById(simulationId)
                .orElseThrow(() -> new IllegalArgumentException("Simulation non trouvée"));

        SimulationChallenge simChallenge = simulationChallengeRepository.findById(request.simulationChallengeId())
                .orElseThrow(() -> new IllegalArgumentException("Question de simulation non trouvée"));

        ChallengeOption selectedOption = challengeOptionRepository.findById(request.selectedOptionId())
                .orElseThrow(() -> new IllegalArgumentException("Option sélectionnée non trouvée"));

        boolean isCorrect = selectedOption.isCorrect();
        int scoreAwarded = isCorrect ? simChallenge.getChallenge().getPoints() : 0;

        SimulationAnswer answer = new SimulationAnswer();
        answer.setSimulationChallenge(simChallenge);
        answer.setSelectedOption(selectedOption);
        answer.setCorrect(isCorrect);
        answer.setScore(scoreAwarded);
        answer.setResponseTimeMs(request.responseTimeMs());

        simChallenge.setAnswer(answer);

        // Mise à jour du score global
        simulation.setTotalScore(simulation.getTotalScore() + scoreAwarded);

        // Trouver l'option correcte pour le feedback
        ChallengeOption correctOption = simChallenge.getChallenge().getOptions().stream()
                .filter(ChallengeOption::isCorrect)
                .findFirst()
                .orElse(null);

        Long correctOptionId = correctOption != null ? correctOption.getId() : null;

        return new SubmitAnswerResponse(
                answer.getId(),
                isCorrect,
                scoreAwarded,
                simulation.getTotalScore(),
                simChallenge.getChallenge().getExplanation(),
                correctOptionId
        );
    }

    @Transactional
    public SimulationSummaryResponse completeSimulation(Long simulationId) {
        Simulation simulation = simulationRepository.findById(simulationId)
                .orElseThrow(() -> new IllegalArgumentException("Simulation non trouvée"));

        simulation.setStatus(SimulationStatus.COMPLETED);
        simulation.setCompletedAt(LocalDateTime.now());

        int totalQuestions = simulation.getSimulationChallenges().size();
        int correctAnswers = (int) simulation.getSimulationChallenges().stream()
                .filter(sc -> sc.getAnswer() != null && sc.getAnswer().isCorrect())
                .count();

        return new SimulationSummaryResponse(
                simulation.getId(),
                simulation.getStatus(),
                simulation.getTotalScore(),
                totalQuestions,
                correctAnswers,
                simulation.getStartedAt(),
                simulation.getCompletedAt()
        );
    }
}