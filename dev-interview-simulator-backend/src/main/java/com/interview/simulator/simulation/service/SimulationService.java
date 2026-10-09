package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.entity.SelectionType;
import com.interview.simulator.challenge.repository.ChallengeOptionRepository;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.simulation.dto.SimulationChallengeResponse;
import com.interview.simulator.simulation.dto.ChallengeCorrectionDTO;
import com.interview.simulator.simulation.dto.SimulationResponse;
import com.interview.simulator.simulation.dto.SimulationResultDTO;
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
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.exception.ResourceNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.LinkedHashSet;
import java.util.Set;

@Service
public class SimulationService {

    private final SimulationRepository simulationRepository;
    private final ChallengeRepository challengeRepository;
    private final UserRepository userRepository;
    private final SimulationChallengeRepository simulationChallengeRepository;
    private final ChallengeOptionRepository challengeOptionRepository;
    private final InterviewScenarioRepository interviewScenarioRepository;
    private final ScoringService scoringService;
    private final ProfileRepository profileRepository;

    public SimulationService(
            SimulationRepository simulationRepository,
            ChallengeRepository challengeRepository,
            UserRepository userRepository,
            SimulationChallengeRepository simulationChallengeRepository,
            ChallengeOptionRepository challengeOptionRepository,
            InterviewScenarioRepository interviewScenarioRepository,
            ScoringService scoringService,
            ProfileRepository profileRepository) {
        this.simulationRepository = simulationRepository;
        this.challengeRepository = challengeRepository;
        this.userRepository = userRepository;
        this.simulationChallengeRepository = simulationChallengeRepository;
        this.challengeOptionRepository = challengeOptionRepository;
        this.interviewScenarioRepository = interviewScenarioRepository;
        this.scoringService = scoringService;
        this.profileRepository = profileRepository;
    }

    @Transactional
    public SimulationResponse startSimulation(StartSimulationRequest request) {
        // 1. Récupérer l'utilisateur par défaut (pour le MVP sans authentification)
        User user = userRepository.findByUsername("default_user")
                .orElseGet(() -> userRepository.save(new User("default_user", "dev@example.com")));

        // 2. Trouver les challenges correspondants au mode
        List<Challenge> matchingChallenges;
        InterviewScenario scenario = null;
        Profile profile = request.profileId() != null
                ? profileRepository.findById(request.profileId())
                    .orElseThrow(() -> new ResourceNotFoundException("Profil non trouvé."))
                : null;

        if (request.mode() == ChallengeType.ARCHITECTURE) {
            scenario = interviewScenarioRepository.findFirstByModeAndActiveTrue(request.mode())
                    .orElseThrow(() -> new ApiException(
                            HttpStatus.UNPROCESSABLE_ENTITY,
                            "Aucun scénario Architecture disponible."
                    ));
            matchingChallenges = challengeRepository.findScenarioChallenges(
                    request.mode(),
                    request.difficulty(),
                    profile,
                    ContentStatus.VALIDATED,
                    scenario
            );
        } else {
            matchingChallenges = challengeRepository.findMatchingChallenges(
                    request.mode(),
                    request.difficulty(),
                    profile,
                    ContentStatus.VALIDATED,
                    request.categoryIds(),
                    request.skillIds()
            );
        }

        if (matchingChallenges.isEmpty()) {
            throw new ApiException(
                    HttpStatus.UNPROCESSABLE_ENTITY,
                    "Aucune question trouvée pour les critères sélectionnés."
            );
        }

        // 3. Architecture conserve l'ordre des étapes ; les autres modes restent aléatoires
        List<Challenge> selectedChallenges = new ArrayList<>(matchingChallenges);
        if (request.mode() != ChallengeType.ARCHITECTURE) {
            Collections.shuffle(selectedChallenges);
            if (selectedChallenges.size() > 10) {
                selectedChallenges = selectedChallenges.subList(0, 10);
            }
        } else if (request.questionCount() != null
                && request.questionCount() < selectedChallenges.size()) {
            selectedChallenges = selectedChallenges.subList(0, request.questionCount());
        }

        // 4. Créer la simulation
        Simulation simulation = new Simulation();
        simulation.setUser(user);
        simulation.setMode(request.mode());
        simulation.setDifficulty(request.difficulty());
        simulation.setProfile(profile);

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
                        sc.getChallenge().getType(),
                        sc.getChallenge().getSelectionType(),
                        sc.getChallenge().getCodeSnippet(),
                        sc.getChallenge().getCodeLanguage(),
                        sc.getChallenge().getScenario() != null
                                ? sc.getChallenge().getScenario().getTitle()
                                : null,
                        sc.getChallenge().getScenario() != null
                                ? sc.getChallenge().getScenario().getDescription()
                                : null,
                        sc.getChallenge().getStepOrder(),
                        sc.getChallenge().getScenario() != null
                                ? sc.getChallenge().getScenario().getChallenges().size()
                                : null,
                        null,
                        null,
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
                simulation.getProfile() != null ? simulation.getProfile().getId() : null,
                simulation.getStatus(),
                simulation.getTotalScore(),
                simulation.getStartedAt(),
                challengeResponses
        );
    }

    @Transactional
    public SubmitAnswerResponse submitAnswer(Long simulationId, SubmitAnswerRequest request) {
        Simulation simulation = simulationRepository.findById(simulationId)
                .orElseThrow(() -> new ResourceNotFoundException("Simulation non trouvée."));

        if (simulation.getStatus() != SimulationStatus.IN_PROGRESS) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Cette simulation n'est plus en cours."
            );
        }

        SimulationChallenge simChallenge = simulationChallengeRepository.findById(request.simulationChallengeId())
                .orElseThrow(() -> new ResourceNotFoundException("Question de simulation non trouvée."));

        if (!simulationId.equals(simChallenge.getSimulation().getId())) {
            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "La question n'appartient pas à cette simulation."
            );
        }

        if (simChallenge.getAnswer() != null) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Une réponse a déjà été enregistrée pour cette question."
            );
        }

        if (simulation.getMode() == ChallengeType.ARCHITECTURE) {
            SimulationChallenge expectedChallenge = simulation.getSimulationChallenges().stream()
                    .filter(challenge -> challenge.getAnswer() == null)
                    .min(java.util.Comparator.comparingInt(SimulationChallenge::getDisplayOrder))
                    .orElse(null);

            if (expectedChallenge == null || !expectedChallenge.getId().equals(simChallenge.getId())) {
                throw new ApiException(
                        HttpStatus.CONFLICT,
                        "Les étapes Architecture doivent être répondues dans l'ordre."
                );
            }
        }

        if (simChallenge.getChallenge().getSelectionType() == SelectionType.SINGLE_CHOICE
                && request.selectedOptionIds().size() != 1) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Une seule option doit être sélectionnée pour cette question.");
        }

        Set<Long> selectedOptionIds = new LinkedHashSet<>(request.selectedOptionIds());
        List<ChallengeOption> selectedOptions = selectedOptionIds.stream()
                .map(optionId -> challengeOptionRepository.findById(optionId)
                        .orElseThrow(() -> new ResourceNotFoundException(
                                "Option sélectionnée non trouvée: " + optionId)))
                .toList();

        if (selectedOptions.stream().anyMatch(option ->
                !simChallenge.getChallenge().getId().equals(option.getChallenge().getId()))) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Une option sélectionnée n'appartient pas à cette question.");
        }

        Set<ChallengeOption> selectedOptionSet = new LinkedHashSet<>(selectedOptions);
        boolean isCorrect = selectedOptionSet.stream().allMatch(ChallengeOption::isCorrect)
                && selectedOptionSet.size() == simChallenge.getChallenge().getOptions().stream()
                .filter(ChallengeOption::isCorrect)
                .count();
        int scoreAwarded = scoringService.calculateScore(simChallenge.getChallenge(), selectedOptionSet);

        SimulationAnswer answer = new SimulationAnswer();
        answer.setSimulationChallenge(simChallenge);
        answer.setSelectedOptions(selectedOptionSet);
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
                correctOptionId,
                simChallenge.getChallenge().getRevealedInformation(),
                simChallenge.getChallenge().getTradeoff(),
                ChallengeCorrectionDTO.forOptions(
                        simChallenge.getChallenge().getOptions(),
                        selectedOptionIds)
        );
    }

    @Transactional
    public SimulationSummaryResponse completeSimulation(Long simulationId) {
        Simulation simulation = simulationRepository.findById(simulationId)
                .orElseThrow(() -> new ResourceNotFoundException("Simulation non trouvée."));

        if (simulation.getStatus() != SimulationStatus.IN_PROGRESS) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Cette simulation est déjà terminée."
            );
        }

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

    @Transactional(readOnly = true)
    public SimulationResultDTO getSimulationResult(Long simulationId) {
        Simulation simulation = simulationRepository.findById(simulationId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Simulation introuvable avec l'ID: " + simulationId));

        List<SimulationAnswer> answers = simulation.getSimulationChallenges().stream()
                .map(SimulationChallenge::getAnswer)
                .filter(answer -> answer != null)
                .toList();

        List<SimulationResultDTO.QuestionSummaryDTO> questionSummaries = answers.stream()
                .map(answer -> {
                    Challenge challenge = answer.getSimulationChallenge().getChallenge();

                    ChallengeOption correctOption = challenge.getOptions().stream()
                            .filter(ChallengeOption::isCorrect)
                            .findFirst()
                            .orElse(null);

                    return new SimulationResultDTO.QuestionSummaryDTO(
                            challenge.getId(),
                            challenge.getTitle(),
                            challenge.getContext(),
                            challenge.getQuestion(),
                            answer.getSelectedOptions().stream()
                                    .map(ChallengeOption::getContent)
                                    .collect(java.util.stream.Collectors.joining(", ")),
                            correctOption != null ? correctOption.getContent() : "Inconnue",
                            answer.isCorrect(),
                            challenge.getExplanation(),
                            answer.getScore(),
                            answer.getResponseTimeMs()
                    );
                })
                .toList();

        int totalScore = answers.stream()
                .mapToInt(answer -> answer.getScore() != null ? answer.getScore() : 0)
                .sum();

        int maxScore = answers.stream()
                .mapToInt(answer -> answer.getSimulationChallenge().getChallenge().getPoints())
                .sum();

        int correctAnswersCount = (int) answers.stream()
                .filter(SimulationAnswer::isCorrect)
                .count();

        long totalTimeSpentSeconds = answers.stream()
                .mapToLong(answer -> answer.getResponseTimeMs() != null
                        ? answer.getResponseTimeMs()
                        : 0L)
                .sum() / 1000;

        double successPercentage = maxScore > 0
                ? ((double) totalScore / maxScore) * 100
                : 0.0;

        return new SimulationResultDTO(
                simulation.getId(),
                totalScore,
                maxScore,
                Math.round(successPercentage * 100.0) / 100.0,
                totalTimeSpentSeconds,
                answers.size(),
                correctAnswersCount,
                questionSummaries
        );
    }
}