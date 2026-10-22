package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.service.ChallengeTimePolicy;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.entity.SelectionType;
import com.interview.simulator.challenge.repository.ChallengeOptionRepository;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.skill.entity.Skill;
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
import com.interview.simulator.simulation.repository.SimulationAnswerRepository;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.service.UserResolver;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.exception.ResourceNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.Objects;

@Service
public class SimulationService {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final int GUEST_TOKEN_BYTES = 32;

    private final SimulationRepository simulationRepository;
    private final ChallengeRepository challengeRepository;
    private final UserResolver userResolver;
    private final SimulationChallengeRepository simulationChallengeRepository;
    private final ChallengeOptionRepository challengeOptionRepository;
    private final InterviewScenarioRepository interviewScenarioRepository;
    private final ScoringService scoringService;
    private final ProfileRepository profileRepository;

    private final SimulationAnswerRepository simulationAnswerRepository;

    public SimulationService(
            SimulationRepository simulationRepository,
            ChallengeRepository challengeRepository,
            UserResolver userResolver,
            SimulationChallengeRepository simulationChallengeRepository,
            ChallengeOptionRepository challengeOptionRepository,
            InterviewScenarioRepository interviewScenarioRepository,
            ScoringService scoringService,
            ProfileRepository profileRepository,
            SimulationAnswerRepository simulationAnswerRepository) {
        this.simulationRepository = simulationRepository;
        this.challengeRepository = challengeRepository;
        this.userResolver = userResolver;
        this.simulationChallengeRepository = simulationChallengeRepository;
        this.challengeOptionRepository = challengeOptionRepository;
        this.interviewScenarioRepository = interviewScenarioRepository;
        this.scoringService = scoringService;
        this.profileRepository = profileRepository;
        this.simulationAnswerRepository = simulationAnswerRepository;
    }

    @Transactional
    public SimulationResponse startSimulation(StartSimulationRequest request) {
        // 1. Résolution de l'utilisateur : connecté → son compte ; invité → default_user (trial sans historique)
        User authenticatedUser = userResolver.currentAuthenticatedOrNull().orElse(null);
        User user = authenticatedUser != null ? authenticatedUser : userResolver.resolveOrCreate();
        boolean guest = authenticatedUser == null;
        String guestAccessToken = guest ? generateGuestAccessToken() : null;

        // 2. Trouver les challenges correspondants au mode
        List<Challenge> matchingChallenges;
        InterviewScenario scenario = null;
        Profile profile = request.profileId() != null
                ? profileRepository.findById(request.profileId())
                    .orElseThrow(() -> new ResourceNotFoundException("Profil non trouvé."))
                : null;

        if (request.mode() == ChallengeType.ARCHITECTURE) {
            // Tirage au hasard d'un scénario actif disposant d'au moins une étape VALIDATED compatible
            List<InterviewScenario> availableScenarios = interviewScenarioRepository
                    .findByModeAndActiveTrue(request.mode());
            Collections.shuffle(availableScenarios);
            List<Challenge> scenarioSteps = null;
            for (InterviewScenario candidate : availableScenarios) {
                List<Challenge> steps = challengeRepository.findScenarioChallenges(
                        request.mode(),
                        request.difficulty(),
                        profile,
                        ContentStatus.VALIDATED,
                        candidate
                );
                if (!steps.isEmpty()) {
                    scenario = candidate;
                    scenarioSteps = steps;
                    break;
                }
            }
            if (scenarioSteps == null) {
                throw new ApiException(
                        HttpStatus.UNPROCESSABLE_ENTITY,
                        "Aucun scénario Architecture disponible."
                );
            }
            matchingChallenges = scenarioSteps;
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

        // Exclusion optionnelle (ciblage depuis le bilan) : ne repropose pas les questions
        // déjà répondues. Si tout serait exclu, on garde le pool complet (repli sûr).
        if (request.excludeChallengeIds() != null && !request.excludeChallengeIds().isEmpty()) {
            List<Challenge> freshChallenges = matchingChallenges.stream()
                    .filter(challenge -> !request.excludeChallengeIds().contains(challenge.getId()))
                    .toList();
            if (!freshChallenges.isEmpty()) {
                matchingChallenges = freshChallenges;
            }
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
        simulation.setGuestAccessTokenHash(guest ? hashGuestAccessToken(guestAccessToken) : null);
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

        return mapToResponse(saved, guestAccessToken);
    }

    // Les questions Architecture mélangent l'affichage des choix pour éviter
    // que la bonne réponse soit toujours en première position. Le séquentiel
    // mélange aussi ses étapes et renumérote l'ordre de présentation ; dans les
    // deux cas, la correction serveur relit les options originales en base.
    private List<SimulationChallengeResponse.OptionResponse> presentationOptions(Challenge challenge) {
        if (challenge.getType() == ChallengeType.SEQUENTIAL_REASONING) {
            List<ChallengeOption> shuffled = new ArrayList<>(challenge.getOptions());
            Collections.shuffle(shuffled);
            List<SimulationChallengeResponse.OptionResponse> options = new ArrayList<>();
            int presentationPosition = 1;
            for (ChallengeOption option : shuffled) {
                options.add(new SimulationChallengeResponse.OptionResponse(
                        option.getId(), option.getContent(), presentationPosition++));
            }
            return options;
        }

        List<ChallengeOption> options = new ArrayList<>(challenge.getOptions());
        if (challenge.getType() == ChallengeType.ARCHITECTURE) {
            Collections.shuffle(options);
        }
        return options.stream()
                .map(option -> new SimulationChallengeResponse.OptionResponse(
                        option.getId(), option.getContent(), option.getDisplayOrder()))
                .toList();
    }

    private SimulationResponse mapToResponse(Simulation simulation, String guestAccessToken) {
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
                        sc.getDisplayOrder(),
                        sc.getChallenge().getScenario() != null
                                ? simulation.getSimulationChallenges().size()
                                : null,
                        null,
                        null,
                        ChallengeTimePolicy.normalize(
                                sc.getChallenge().getType(), sc.getChallenge().getEstimatedTimeSeconds()),
                        presentationOptions(sc.getChallenge())
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
                challengeResponses,
                guestAccessToken
        );
    }

    @Transactional
    public SubmitAnswerResponse submitAnswer(
            Long simulationId, SubmitAnswerRequest request, String guestAccessToken) {
        Simulation simulation = findOwnedSimulation(simulationId, guestAccessToken);

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

        if (request.selectedOptionIds().isEmpty()) {
            return recordTimedOutAnswer(simChallenge, request.responseTimeMs());
        }

        // Raisonnement séquentiel : réponse = permutation complète des étapes.
        if (simChallenge.getChallenge().getType() == ChallengeType.SEQUENTIAL_REASONING) {
            return submitSequentialAnswer(simChallenge, request);
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
        // Verdict et score partagent le même critère (ScoringService) :
        // points pleins ⇔ réponse correcte, jamais l'un sans l'autre.
        boolean isCorrect = scoringService.isExactSelection(
                simChallenge.getChallenge(), selectedOptionSet);
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
                        selectedOptionIds),
                null // expectedOrder : réservé au raisonnement séquentiel
        );
    }

    private SubmitAnswerResponse recordTimedOutAnswer(
            SimulationChallenge simChallenge,
            Long responseTimeMs) {
        Simulation simulation = simChallenge.getSimulation();
        Challenge challenge = simChallenge.getChallenge();
        Set<ChallengeOption> emptySelection = new LinkedHashSet<>();
        List<Long> expectedOrder = challenge.getType() == ChallengeType.SEQUENTIAL_REASONING
                ? challenge.getOptions().stream()
                    .sorted(Comparator.comparingInt(ChallengeOption::getDisplayOrder))
                    .map(ChallengeOption::getId).toList()
                : null;

        SimulationAnswer answer = new SimulationAnswer();
        answer.setSimulationChallenge(simChallenge);
        answer.setSelectedOptions(emptySelection);
        answer.setCorrect(false);
        answer.setScore(0);
        answer.setResponseTimeMs(responseTimeMs);
        simChallenge.setAnswer(answer);
        simulationAnswerRepository.save(answer);

        return new SubmitAnswerResponse(answer.getId(), false, 0,
                simulation.getTotalScore(), "Temps écoulé : aucune réponse n'a été enregistrée.", null,
                null, null,
                ChallengeCorrectionDTO.forOptions(challenge.getOptions(), Set.of()), expectedOrder);
    }

    // ===== Raisonnement séquentiel =====
    // La réponse est une PERMUTATION des étapes du challenge. Le DTO de
    // démarrage ne contenait jamais l'ordre attendu (mélange + renumérotation
    // dans presentationOptions) ; ici on compare l'ordre soumis à displayOrder
    // relu en base. Score partiel : points × (positions correctes / total).
    private SubmitAnswerResponse submitSequentialAnswer(SimulationChallenge simChallenge, SubmitAnswerRequest request) {
        Challenge challenge = simChallenge.getChallenge();
        Simulation simulation = simChallenge.getSimulation();
        List<Long> submittedOrder = request.selectedOptionIds();

        List<ChallengeOption> expectedOptions = challenge.getOptions().stream()
                .sorted(Comparator.comparingInt(ChallengeOption::getDisplayOrder))
                .toList();

        // Permutation exacte : mêmes étapes, aucune doublon, aucun manquant.
        boolean permutation = submittedOrder.size() == expectedOptions.size()
                && new java.util.HashSet<>(submittedOrder).size() == submittedOrder.size()
                && submittedOrder.containsAll(
                        expectedOptions.stream().map(ChallengeOption::getId).toList());
        if (!permutation) {
            throw new ApiException(
                    HttpStatus.UNPROCESSABLE_ENTITY,
                    "La réponse doit être une permutation complète des étapes.");
        }

        boolean isCorrect = java.util.Objects.equals(submittedOrder,
                expectedOptions.stream().map(ChallengeOption::getId).toList());
        int scoreAwarded = scoringService.calculateSequenceScore(challenge, submittedOrder);

        SimulationAnswer answer = new SimulationAnswer();
        answer.setSimulationChallenge(simChallenge);
        // LinkedHashSet : conserve l'ordre de soumission côté entité.
        Set<ChallengeOption> submittedOptions = new LinkedHashSet<>();
        for (Long optionId : submittedOrder) {
            submittedOptions.add(challenge.getOptions().stream()
                    .filter(option -> option.getId().equals(optionId))
                    .findFirst()
                    .orElseThrow());
        }
        answer.setSelectedOptions(submittedOptions);
        answer.setCorrect(isCorrect);
        answer.setScore(scoreAwarded);
        answer.setResponseTimeMs(request.responseTimeMs());
        simChallenge.setAnswer(answer);
        simulation.setTotalScore(simulation.getTotalScore() + scoreAwarded);

        // Position de chaque étape de la réponse sur la jointure (V11) — colonne
        // nullable, écrite uniquement pour ce type : les QCM restent NULL.
        simulationAnswerRepository.save(answer);
        simulationAnswerRepository.flush();
        int position = 1;
        for (Long optionId : submittedOrder) {
            simulationAnswerRepository.updateAnswerOptionPosition(answer.getId(), optionId, position++);
        }

        // Corrections : isCorrect = « l'étape est à sa bonne position ».
        List<ChallengeCorrectionDTO> corrections = new ArrayList<>();
        for (int i = 0; i < expectedOptions.size(); i++) {
            ChallengeOption option = expectedOptions.get(i);
            corrections.add(new ChallengeCorrectionDTO(
                    option.getId(),
                    option.getContent(),
                    option.getId().equals(submittedOrder.get(i)),
                    true,
                    null,
                    option.getExplanation()));
        }

        return new SubmitAnswerResponse(
                answer.getId(),
                isCorrect,
                scoreAwarded,
                simulation.getTotalScore(),
                challenge.getExplanation(),
                null,
                null,
                null,
                corrections,
                expectedOptions.stream().map(ChallengeOption::getId).toList());
    }

    @Transactional
    public SimulationSummaryResponse abandonSimulation(Long simulationId, String guestAccessToken) {
        Simulation simulation = findOwnedSimulation(simulationId, guestAccessToken);

        // Idempotent : seul un en-cours bascule en ABANDONNÉ — une session déjà
        // terminée (bilan consulté depuis l'historique) n'est jamais rétrogradée.
        if (simulation.getStatus() == SimulationStatus.IN_PROGRESS) {
            simulation.setStatus(SimulationStatus.ABANDONED);
        }

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

    @Transactional
    public SimulationSummaryResponse completeSimulation(Long simulationId, String guestAccessToken) {
        Simulation simulation = findOwnedSimulation(simulationId, guestAccessToken);

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
    public SimulationResultDTO getSimulationResult(Long simulationId, String guestAccessToken) {
        Simulation simulation = findOwnedSimulation(simulationId, guestAccessToken);

        List<SimulationAnswer> answers = simulation.getSimulationChallenges().stream()
                .map(SimulationChallenge::getAnswer)
                .filter(answer -> answer != null)
                .toList();
        int totalQuestions = simulation.getSimulationChallenges().size();

        List<SimulationResultDTO.QuestionSummaryDTO> questionSummaries = simulation.getSimulationChallenges().stream()
                .sorted(Comparator.comparingInt(SimulationChallenge::getDisplayOrder))
                .map(simulationChallenge -> {
                    SimulationAnswer answer = simulationChallenge.getAnswer();
                    Challenge challenge = simulationChallenge.getChallenge();
                    SimulationResultDTO.QuestionStatus status = answer == null
                            ? SimulationResultDTO.QuestionStatus.UNANSWERED
                            : answer.getSelectedOptions().isEmpty()
                                    ? SimulationResultDTO.QuestionStatus.TIMED_OUT
                                    : SimulationResultDTO.QuestionStatus.ANSWERED;
                    String selectedContent = answer == null || answer.getSelectedOptions().isEmpty()
                            ? null
                            : answer.getSelectedOptions().stream()
                                    .map(ChallengeOption::getContent)
                                    .collect(java.util.stream.Collectors.joining(", "));
                    boolean isCorrect = answer != null && answer.isCorrect();
                    int score = answer != null && answer.getScore() != null ? answer.getScore() : 0;
                    Long responseTimeMs = answer == null ? null : answer.getResponseTimeMs();

                    // Toutes les bonnes options (et non plus la première seule) :
                    // un QCM multiple doit afficher l'intégralité de la bonne réponse.
                    // En séquentiel, l'ordre des options = l'ordre attendu.
                    String correctContent = challenge.getOptions().stream()
                            .filter(ChallengeOption::isCorrect)
                            .sorted(Comparator.comparingInt(ChallengeOption::getDisplayOrder))
                            .map(ChallengeOption::getContent)
                            .collect(java.util.stream.Collectors.joining(", "));

                    return new SimulationResultDTO.QuestionSummaryDTO(
                            challenge.getId(),
                            challenge.getTitle(),
                            challenge.getContext(),
                            challenge.getQuestion(),
                            selectedContent,
                            !correctContent.isBlank() ? correctContent : "Inconnue",
                            isCorrect,
                            status,
                            challenge.getExplanation(),
                            score,
                            responseTimeMs,
                            challenge.getCategories().stream()
                                    .map(Category::getName)
                                    .sorted()
                                    .toList(),
                            challenge.getSkills().stream()
                                    .map(Skill::getName)
                                    .sorted()
                                    .toList()
                    );
                })
                .toList();

        int totalScore = answers.stream()
                .mapToInt(answer -> answer.getScore() != null ? answer.getScore() : 0)
                .sum();

        int maxScore = simulation.getSimulationChallenges().stream()
                .map(SimulationChallenge::getChallenge)
                .mapToInt(challenge -> challenge.getPoints() != null ? challenge.getPoints() : 0)
                .sum();

        int correctAnswersCount = (int) answers.stream()
                .filter(SimulationAnswer::isCorrect)
                .count();

        long totalTimeSpentSeconds = answers.stream()
                .mapToLong(answer -> answer.getResponseTimeMs() != null
                        ? answer.getResponseTimeMs()
                        : 0L)
                .sum() / 1000;

        // Taux de réussite = bonnes réponses / nombre total de questions
        // (invariant métier). Le ratio points/points reste affiché
        // séparément via totalScore / maxPossibleScore.
        double successPercentage = totalQuestions == 0
                ? 0.0
                : ((double) correctAnswersCount / totalQuestions) * 100;

        // Breakdown distinct par domaine technique et compétence transversale.
        // Toutes les questions comptent dans le dénominateur : une question expirée
        // ou jamais atteinte n'est pas une réussite, mais reste visible dans le diagnostic.
        Map<Long, int[]> skillAgg = new LinkedHashMap<>();
        Map<Long, String> skillNames = new HashMap<>();
        Map<Long, int[]> categoryAgg = new LinkedHashMap<>();
        Map<Long, String> categoryNames = new HashMap<>();
        int answeredWithSkills = 0;

        for (SimulationChallenge simulationChallenge : simulation.getSimulationChallenges()) {
            Challenge challenge = simulationChallenge.getChallenge();
            SimulationAnswer answer = simulationChallenge.getAnswer();
            boolean correct = answer != null && answer.isCorrect();
            if (answer != null && !challenge.getSkills().isEmpty()) {
                answeredWithSkills++;
            }
            for (Skill skill : challenge.getSkills()) {
                int[] agg = skillAgg.computeIfAbsent(skill.getId(), k -> new int[2]);
                agg[1]++;
                if (correct) {
                    agg[0]++;
                }
                skillNames.put(skill.getId(), skill.getName());
            }
            for (Category category : challenge.getCategories()) {
                int[] agg = categoryAgg.computeIfAbsent(category.getId(), k -> new int[2]);
                agg[1]++;
                if (correct) {
                    agg[0]++;
                }
                categoryNames.put(category.getId(), category.getName());
            }
        }

        List<SimulationResultDTO.CompetencyResult> categoryResults = toCompetencyResults(
                categoryAgg, categoryNames, true);
        List<SimulationResultDTO.CompetencyResult> skillResults = toCompetencyResults(
                skillAgg, skillNames, true);
        List<SimulationResultDTO.CompetencyResult> categoryPriorityResults = toCompetencyResults(
                categoryAgg, categoryNames, false);
        List<SimulationResultDTO.CompetencyResult> skillPriorityResults = toCompetencyResults(
                skillAgg, skillNames, false);

        // Conservé pour compatibilité avec les anciens clients : l'axe historique
        // reste disponible, tandis que les nouvelles interfaces reçoivent les deux.
        double skillCoverage = answers.isEmpty() ? 0.0 : (double) answeredWithSkills / answers.size();
        boolean useSkills = skillCoverage >= 0.5 && !skillResults.isEmpty();
        SimulationResultDTO.CompetencySource competencySource = useSkills
                ? SimulationResultDTO.CompetencySource.SKILL
                : SimulationResultDTO.CompetencySource.CATEGORY;
        List<SimulationResultDTO.CompetencyResult> competencyResults = useSkills
                ? skillResults
                : categoryResults;

        return new SimulationResultDTO(
                simulation.getId(),
                totalScore,
                maxScore,
                Math.round(successPercentage * 100.0) / 100.0,
                totalTimeSpentSeconds,
                simulation.getSimulationChallenges().size(),
                correctAnswersCount,
                simulation.getMode(),
                simulation.getDifficulty(),
                simulation.getProfile() != null ? simulation.getProfile().getId() : null,
                competencySource,
                competencyResults,
                categoryPriorityResults,
                skillPriorityResults,
                categoryResults,
                skillResults,
                questionSummaries
        );
    }

    private Simulation findOwnedSimulation(Long simulationId, String guestAccessToken) {
        Simulation simulation = simulationRepository.findById(simulationId)
                .orElseThrow(() -> new ResourceNotFoundException("Simulation introuvable."));
        User authenticatedUser = userResolver.currentAuthenticatedOrNull().orElse(null);
        if (authenticatedUser != null) {
            if (!Objects.equals(authenticatedUser.getId(), simulation.getUser().getId())) {
                throw new ResourceNotFoundException("Simulation introuvable.");
            }
            return simulation;
        }
        if (!UserResolver.GUEST_USERNAME.equals(simulation.getUser().getUsername())
                || !hasValidGuestAccessToken(simulation, guestAccessToken)) {
            throw new ResourceNotFoundException("Simulation introuvable.");
        }
        return simulation;
    }

    private String generateGuestAccessToken() {
        byte[] tokenBytes = new byte[GUEST_TOKEN_BYTES];
        SECURE_RANDOM.nextBytes(tokenBytes);
        return java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
    }

    private String hashGuestAccessToken(String guestAccessToken) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(guestAccessToken.getBytes(java.nio.charset.StandardCharsets.US_ASCII));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 indisponible.", exception);
        }
    }

    private boolean hasValidGuestAccessToken(
            Simulation simulation, String guestAccessToken) {
        if (guestAccessToken == null || guestAccessToken.isBlank()) {
            return false;
        }
        String providedHash = hashGuestAccessToken(guestAccessToken);
        String storedHash = simulation.getGuestAccessTokenHash();
        return storedHash != null && MessageDigest.isEqual(
                providedHash.getBytes(java.nio.charset.StandardCharsets.US_ASCII),
                storedHash.getBytes(java.nio.charset.StandardCharsets.US_ASCII));
    }

    private List<SimulationResultDTO.CompetencyResult> toCompetencyResults(
            Map<Long, int[]> aggregates, Map<Long, String> names) {
        return toCompetencyResults(aggregates, names, false);
    }

    private List<SimulationResultDTO.CompetencyResult> toCompetencyResults(
            Map<Long, int[]> aggregates, Map<Long, String> names, boolean includePerfectScores) {
        Comparator<SimulationResultDTO.CompetencyResult> rateComparator = Comparator.comparingDouble(
                (SimulationResultDTO.CompetencyResult result) -> (double) result.correct() / result.total());
        if (includePerfectScores) {
            rateComparator = rateComparator.reversed();
        }
        Comparator<SimulationResultDTO.CompetencyResult> comparator = rateComparator
                .thenComparing(Comparator.comparingInt(
                        SimulationResultDTO.CompetencyResult::total).reversed());
        return aggregates.entrySet().stream()
                .filter(entry -> includePerfectScores || entry.getValue()[0] < entry.getValue()[1])
                .map(entry -> new SimulationResultDTO.CompetencyResult(
                        entry.getKey(), names.get(entry.getKey()), entry.getValue()[0], entry.getValue()[1]))
                .sorted(comparator)
                .toList();
    }
}
