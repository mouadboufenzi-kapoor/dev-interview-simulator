package com.interview.simulator.admin.challenge.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.DuplicateEntry;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.ImportError;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.ImportWarning;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.ExecutedCounts;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.PlannedCounts;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedOption;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.admin.challenge.validation.ValidatedStatusValidator;
import com.interview.simulator.admin.challenge.validation.ChallengeTypeValidatorRegistry;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ChallengeImportService {

    private static final int MAX_QUESTIONS_PER_FILE = 500;
    private static final int DEFAULT_POINTS = 10;
    private static final String LEGACY_EXTERNAL_ID_PREFIX = "legacy-";
    private static final String SCENARIO_KEY_SEPARATOR = "|";
    private static final int FIRST_STEP_ORDER = 1;

    private final ChallengeRepository challengeRepository;
    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;
    private final ProfileRepository profileRepository;
    private final InterviewScenarioRepository interviewScenarioRepository;
    private final ChallengeTypeValidatorRegistry validatorRegistry;
    private final ChallengeIdentityService challengeIdentityService;
    private final TransactionTemplate transactionTemplate;
    private final ObjectMapper objectMapper;
    private final Validator beanValidator;

    public ChallengeImportService(
            ChallengeRepository challengeRepository,
            CategoryRepository categoryRepository,
            SkillRepository skillRepository,
            ProfileRepository profileRepository,
            InterviewScenarioRepository interviewScenarioRepository,
            ChallengeTypeValidatorRegistry validatorRegistry,
            ChallengeIdentityService challengeIdentityService,
            TransactionTemplate transactionTemplate,
            ObjectMapper objectMapper,
            Validator beanValidator) {
        this.challengeRepository = challengeRepository;
        this.categoryRepository = categoryRepository;
        this.skillRepository = skillRepository;
        this.profileRepository = profileRepository;
        this.interviewScenarioRepository = interviewScenarioRepository;
        this.validatorRegistry = validatorRegistry;
        this.challengeIdentityService = challengeIdentityService;
        this.transactionTemplate = transactionTemplate;
        this.objectMapper = objectMapper;
        this.beanValidator = beanValidator;
    }

    public ChallengeImportReport importQuestions(MultipartFile file, ContentStatus status, boolean dryRun) {
        return importQuestions(parseQuestions(file), status, dryRun);
    }

    public ChallengeImportReport importQuestions(List<ImportedQuestion> questions, ContentStatus status, boolean dryRun) {
        if (questions.size() > MAX_QUESTIONS_PER_FILE) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Le fichier dépasse la limite de " + MAX_QUESTIONS_PER_FILE + " questions.");
        }
        ImportState state = new ImportState(dryRun);
        List<QuestionOutcome> outcomes = new ArrayList<>();
        Map<String, Integer> stepOrderClaims = new HashMap<>();
        Map<String, Integer> firstExternalIdIndex = new HashMap<>();
        for (int index = 0; index < questions.size(); index++) {
            outcomes.add(importOne(questions.get(index), index, status, dryRun,
                    stepOrderClaims, firstExternalIdIndex, state));
        }
        addContiguityWarnings(outcomes, dryRun, state);
        return state.toReport();
    }

    private List<ImportedQuestion> parseQuestions(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Le fichier JSON est obligatoire.");
        }
        try {
            ChallengeImportRequest request = objectMapper.readValue(file.getBytes(), ChallengeImportRequest.class);
            if (request.questions() == null) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "La liste « questions » est obligatoire.");
            }
            return request.questions();
        } catch (IOException e) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Fichier JSON illisible : " + e.getMessage());
        }
    }

    private QuestionOutcome importOne(
            ImportedQuestion question,
            int index,
            ContentStatus status,
            boolean dryRun,
            Map<String, Integer> stepOrderClaims,
            Map<String, Integer> firstExternalIdIndex,
            ImportState state) {
        String label = labelOf(question);
        List<String> problems = validationProblems(question);
        problems.addAll(fileProblems(question, index, stepOrderClaims, firstExternalIdIndex));
        if (!problems.isEmpty()) {
            QuestionOutcome outcome = QuestionOutcome.error(index, String.join(" ; ", problems));
            state.addError(index, label, outcome.reason());
            return outcome;
        }
        QuestionOutcome outcome = transactionTemplate.execute(
                transactionStatus -> persistOne(question, index, status, dryRun, state));
        state.record(outcome, label);
        if (outcome.type() == OutcomeType.ERROR) {
            releaseStepOrderClaim(question, index, stepOrderClaims);
        }
        return outcome;
    }

    private List<String> validationProblems(ImportedQuestion question) {
        List<String> problems = new ArrayList<>();
        Set<ConstraintViolation<ImportedQuestion>> violations = beanValidator.validate(question);
        violations.forEach(violation ->
                problems.add(violation.getPropertyPath() + " : " + violation.getMessage()));
        if (question.type() != null) {
            problems.addAll(validatorRegistry.get(question.type()).validate(question));
        }
        return problems;
    }

    private List<String> fileProblems(
            ImportedQuestion question,
            int index,
            Map<String, Integer> stepOrderClaims,
            Map<String, Integer> firstExternalIdIndex) {
        String externalId = question.externalId();
        if (isBlank(externalId)) {
            return List.of("L'identifiant externe est obligatoire.");
        }
        List<String> problems = new ArrayList<>();
        if (externalId.startsWith(LEGACY_EXTERNAL_ID_PREFIX)) {
            problems.add("Un identifiant externe ne peut pas commencer par « "
                    + LEGACY_EXTERNAL_ID_PREFIX + " ».");
        }
        Integer firstIndex = firstExternalIdIndex.putIfAbsent(externalId, index);
        if (firstIndex != null) {
            problems.add("L'identifiant externe « " + externalId
                    + " » est déjà utilisé par la question à l'index " + firstIndex + ".");
        }
        if (hasScenarioStep(question)) {
            String claimKey = scenarioClaimKey(question);
            Integer claimant = stepOrderClaims.putIfAbsent(claimKey, index);
            if (claimant != null) {
                problems.add("L'ordre d'étape " + question.stepOrder() + " du scénario « "
                        + question.scenario() + " » est déjà pris par la question à l'index " + claimant + ".");
            }
        }
        return problems;
    }

    private void releaseStepOrderClaim(ImportedQuestion question, int index, Map<String, Integer> stepOrderClaims) {
        if (!hasScenarioStep(question)) {
            return;
        }
        String claimKey = scenarioClaimKey(question);
        if (Integer.valueOf(index).equals(stepOrderClaims.get(claimKey))) {
            stepOrderClaims.remove(claimKey);
        }
    }

    private boolean hasScenarioStep(ImportedQuestion question) {
        return question.type() == ChallengeType.ARCHITECTURE
                && question.stepOrder() != null
                && !isBlank(question.scenario());
    }

    private String scenarioClaimKey(ImportedQuestion question) {
        return normalizeKey(question.scenario()) + SCENARIO_KEY_SEPARATOR + question.stepOrder();
    }

    private String normalizeKey(String value) {
        return value.trim().toLowerCase(Locale.ROOT);
    }


    private QuestionOutcome persistOne(
            ImportedQuestion question,
            int index,
            ContentStatus status,
            boolean dryRun,
            ImportState state) {
        String contentHash = challengeIdentityService.contentHash(toTransientChallenge(question));
        Optional<Challenge> existing = challengeRepository.findByExternalId(question.externalId());
        if (existing.isPresent()) {
            return updateExisting(existing.get(), question, index, contentHash, dryRun, state);
        }
        List<Challenge> sameHash = challengeRepository.findByContentHash(contentHash);
        if (!sameHash.isEmpty()) {
            Challenge duplicate = sameHash.get(0);
            return QuestionOutcome.duplicate(index, duplicate.getId(), duplicate.getTitle());
        }
        return createNew(question, index, contentHash, status, dryRun, state);
    }

    private QuestionOutcome updateExisting(
            Challenge challenge,
            ImportedQuestion question,
            int index,
            String contentHash,
            boolean dryRun,
            ImportState state) {
        List<Challenge> sameHash = challengeRepository.findByContentHash(contentHash).stream()
                .filter(other -> !other.getId().equals(challenge.getId()))
                .toList();
        if (!sameHash.isEmpty()) {
            return QuestionOutcome.error(index, "Le hash du contenu correspond déjà à la question "
                    + sameHash.get(0).getId() + " (« " + sameHash.get(0).getTitle() + " »).");
        }
        Relations relations = resolveRelations(question);
        if (relations.error() != null) {
            return QuestionOutcome.error(index, relations.error());
        }
        String taxonomyProblem = ValidatedStatusValidator.violationMessage(
                challenge.getStatus(), relations.categories(), relations.skills());
        if (taxonomyProblem != null) {
            return QuestionOutcome.error(index, taxonomyProblem);
        }
        InterviewScenario scenario = resolveScenarioEntity(question, dryRun);
        String stepOrderProblem = stepOrderProblem(question, scenario, challenge.getId());
        if (stepOrderProblem != null) {
            return QuestionOutcome.error(index, stepOrderProblem);
        }
        if (scenario == null && question.type() == ChallengeType.ARCHITECTURE && dryRun) {
            state.addWarning(index, question.scenario(),
                    "Le scénario « " + question.scenario() + " » serait créé.");
        }
        Integer previousStepOrder = challenge.getStepOrder();
        if (!dryRun) {
            applyImport(challenge, question, relations, scenario, contentHash);
            challengeRepository.save(challenge);
        }
        return QuestionOutcome.updated(index, scenarioClaimTitle(question), previousStepOrder, question.stepOrder());
    }

    private QuestionOutcome createNew(
            ImportedQuestion question,
            int index,
            String contentHash,
            ContentStatus status,
            boolean dryRun,
            ImportState state) {
        Relations relations = resolveRelations(question);
        if (relations.error() != null) {
            return QuestionOutcome.error(index, relations.error());
        }
        String taxonomyProblem = ValidatedStatusValidator.violationMessage(
                status, relations.categories(), relations.skills());
        if (taxonomyProblem != null) {
            return QuestionOutcome.error(index, taxonomyProblem);
        }
        InterviewScenario scenario = resolveScenarioEntity(question, dryRun);
        String stepOrderProblem = stepOrderProblem(question, scenario, null);
        if (stepOrderProblem != null) {
            return QuestionOutcome.error(index, stepOrderProblem);
        }
        if (scenario == null && question.type() == ChallengeType.ARCHITECTURE && dryRun) {
            state.addWarning(index, question.scenario(),
                    "Le scénario « " + question.scenario() + " » serait créé.");
        }
        if (!dryRun) {
            Challenge challenge = new Challenge();
            challenge.setExternalId(question.externalId());
            challenge.setStatus(status);
            challenge.setActive(true);
            applyImport(challenge, question, relations, scenario, contentHash);
            challengeRepository.save(challenge);
        }
        return QuestionOutcome.created(index, scenarioClaimTitle(question), question.stepOrder());
    }

    private InterviewScenario resolveScenarioEntity(ImportedQuestion question, boolean dryRun) {
        if (question.type() != ChallengeType.ARCHITECTURE) {
            return null;
        }
        Optional<InterviewScenario> found = interviewScenarioRepository.findByTitle(question.scenario());
        if (found.isPresent()) {
            return found.get();
        }
        if (dryRun) {
            return null;
        }
        InterviewScenario scenario = new InterviewScenario();
        scenario.setTitle(question.scenario());
        scenario.setMode(ChallengeType.ARCHITECTURE);
        scenario.setActive(true);
        return interviewScenarioRepository.save(scenario);
    }

    private String stepOrderProblem(ImportedQuestion question, InterviewScenario scenario, Long challengeId) {
        if (question.type() != ChallengeType.ARCHITECTURE || scenario == null) {
            return null;
        }
        boolean taken = challengeId == null
                ? challengeRepository.existsByScenarioIdAndStepOrder(scenario.getId(), question.stepOrder())
                : challengeRepository.existsByScenarioIdAndStepOrderAndIdNot(scenario.getId(), question.stepOrder(), challengeId);
        if (taken) {
            return "L'ordre d'étape " + question.stepOrder()
                    + " est déjà pris dans le scénario « " + scenario.getTitle() + " ».";
        }
        return null;
    }

    private String scenarioClaimTitle(ImportedQuestion question) {
        return question.type() == ChallengeType.ARCHITECTURE ? question.scenario() : null;
    }

    private Relations resolveRelations(ImportedQuestion question) {
        Set<String> categoryNames = question.categories() == null ? Set.of() : question.categories();
        Set<String> skillNames = question.skills() == null ? Set.of() : question.skills();
        Set<String> profileCodes = question.profiles() == null ? Set.of() : question.profiles();

        Set<Category> categories = categoryNames.isEmpty()
                ? Set.of()
                : categoryRepository.findByNameIn(categoryNames);
        if (categories.size() != categoryNames.size()) {
            return Relations.error("Catégorie(s) inconnue(s) : "
                    + missingValues(categoryNames, categories.stream().map(Category::getName).collect(Collectors.toSet())));
        }

        Set<Skill> skills = skillNames.isEmpty() ? Set.of() : skillRepository.findByNameIn(skillNames);
        if (skills.size() != skillNames.size()) {
            return Relations.error("Compétence(s) inconnue(s) : "
                    + missingValues(skillNames, skills.stream().map(Skill::getName).collect(Collectors.toSet())));
        }

        Set<Profile> profiles = profileCodes.isEmpty() ? Set.of() : profileRepository.findByCodeIn(profileCodes);
        if (profiles.size() != profileCodes.size()) {
            return Relations.error("Profil(s) inconnu(s) : "
                    + missingValues(profileCodes, profiles.stream().map(Profile::getCode).collect(Collectors.toSet())));
        }
        List<String> inactive = profiles.stream()
                .filter(profile -> !profile.isActive())
                .map(Profile::getCode)
                .sorted()
                .toList();
        if (!inactive.isEmpty()) {
            return Relations.error("Profil(s) inactif(s) : " + String.join(", ", inactive));
        }
        return new Relations(categories, skills, profiles, null);
    }

    private String missingValues(Set<String> expected, Set<String> found) {
        return expected.stream()
                .filter(value -> !found.contains(value))
                .sorted()
                .collect(Collectors.joining(", "));
    }

    private void applyImport(
            Challenge challenge,
            ImportedQuestion question,
            Relations relations,
            InterviewScenario scenario,
            String contentHash) {
        challenge.setTitle(question.title());
        challenge.setType(question.type());
        challenge.setDifficulty(question.difficulty());
        challenge.setSelectionType(question.selectionType());
        challenge.setContext(question.context());
        challenge.setQuestion(question.question());
        challenge.setCodeSnippet(question.codeSnippet());
        challenge.setCodeLanguage(question.codeLanguage());
        challenge.setExplanation(question.explanation());
        challenge.setRevealedInformation(question.revealedInformation());
        challenge.setTradeoff(question.tradeoff());
        challenge.setEstimatedTimeSeconds(question.estimatedTimeSeconds());
        challenge.setPoints(question.points() == null ? DEFAULT_POINTS : question.points());
        challenge.setScenario(scenario);
        challenge.setStepOrder(question.type() == ChallengeType.ARCHITECTURE ? question.stepOrder() : null);
        challenge.setContentHash(contentHash);

        challenge.getCategories().clear();
        challenge.getCategories().addAll(relations.categories());
        challenge.getSkills().clear();
        challenge.getSkills().addAll(relations.skills());
        challenge.getProfiles().clear();
        challenge.getProfiles().addAll(relations.profiles());

        challenge.getOptions().clear();
        if (question.options() != null) {
            for (ImportedOption option : question.options()) {
                challenge.getOptions().add(toChallengeOption(challenge, option));
            }
        }
    }

    private Challenge toTransientChallenge(ImportedQuestion question) {
        Challenge challenge = new Challenge();
        challenge.setType(question.type());
        challenge.setContext(question.context());
        challenge.setQuestion(question.question());
        challenge.setCodeSnippet(question.codeSnippet());
        if (question.type() == ChallengeType.ARCHITECTURE && !isBlank(question.scenario())) {
            InterviewScenario scenario = new InterviewScenario();
            scenario.setTitle(question.scenario());
            challenge.setScenario(scenario);
        }
        if (question.options() != null) {
            for (ImportedOption option : question.options()) {
                challenge.getOptions().add(toChallengeOption(challenge, option));
            }
        }
        return challenge;
    }

    private ChallengeOption toChallengeOption(Challenge challenge, ImportedOption option) {
        ChallengeOption entity = new ChallengeOption();
        entity.setChallenge(challenge);
        entity.setContent(option.content());
        entity.setCorrect(option.correct());
        entity.setSeverity(option.severity());
        entity.setExplanation(option.explanation());
        entity.setDisplayOrder(option.displayOrder());
        return entity;
    }

    private void addContiguityWarnings(List<QuestionOutcome> outcomes, boolean dryRun, ImportState state) {
        Map<String, List<QuestionOutcome>> byScenario = outcomes.stream()
                .filter(outcome -> outcome.scenarioTitle() != null
                        && outcome.type() != OutcomeType.ERROR
                        && outcome.type() != OutcomeType.DUPLICATE)
                .collect(Collectors.groupingBy(QuestionOutcome::scenarioTitle));
        byScenario.forEach((scenarioTitle, scenarioOutcomes) -> {
            List<Integer> orders = new ArrayList<>(loadStepOrders(scenarioTitle));
            if (dryRun) {
                scenarioOutcomes.forEach(outcome -> {
                    if (outcome.previousStepOrder() != null) {
                        orders.remove(outcome.previousStepOrder());
                    }
                    if (outcome.newStepOrder() != null) {
                        orders.add(outcome.newStepOrder());
                    }
                });
            }
            List<Integer> missing = missingStepOrders(orders);
            if (!missing.isEmpty()) {
                int firstIndex = scenarioOutcomes.stream()
                        .mapToInt(QuestionOutcome::index)
                        .min()
                        .orElse(0);
                state.addWarning(firstIndex, scenarioTitle,
                        "Les ordres d'étape du scénario « " + scenarioTitle
                                + " » ne sont pas contigus ; positions manquantes : " + missing + ".");
            }
        });
    }

    private List<Integer> loadStepOrders(String scenarioTitle) {
        return interviewScenarioRepository.findByTitle(scenarioTitle)
                .map(scenario -> challengeRepository.findByScenarioIdOrderByStepOrderAsc(scenario.getId()).stream()
                        .map(Challenge::getStepOrder)
                        .filter(Objects::nonNull)
                        .toList())
                .orElse(List.of());
    }

    private List<Integer> missingStepOrders(List<Integer> orders) {
        List<Integer> distinctOrders = orders.stream().distinct().sorted().toList();
        List<Integer> missing = new ArrayList<>();
        int expected = FIRST_STEP_ORDER;
        for (Integer order : distinctOrders) {
            while (expected < order) {
                missing.add(expected++);
            }
            expected = order + 1;
        }
        return missing;
    }

    private String labelOf(ImportedQuestion question) {
        return isBlank(question.externalId()) ? question.title() : question.externalId();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private enum OutcomeType {
        CREATED,
        UPDATED,
        DUPLICATE,
        ERROR
    }

    private record QuestionOutcome(
            int index,
            OutcomeType type,
            String reason,
            Long existingId,
            String existingTitle,
            String scenarioTitle,
            Integer previousStepOrder,
            Integer newStepOrder) {

        static QuestionOutcome created(int index, String scenarioTitle, Integer newStepOrder) {
            return new QuestionOutcome(index, OutcomeType.CREATED, null, null, null, scenarioTitle, null, newStepOrder);
        }

        static QuestionOutcome updated(
                int index,
                String scenarioTitle,
                Integer previousStepOrder,
                Integer newStepOrder) {
            return new QuestionOutcome(index, OutcomeType.UPDATED, null, null, null, scenarioTitle, previousStepOrder, newStepOrder);
        }

        static QuestionOutcome duplicate(int index, Long existingId, String existingTitle) {
            return new QuestionOutcome(index, OutcomeType.DUPLICATE, null, existingId, existingTitle, null, null, null);
        }

        static QuestionOutcome error(int index, String reason) {
            return new QuestionOutcome(index, OutcomeType.ERROR, reason, null, null, null, null, null);
        }
    }

    private record Relations(
            Set<Category> categories,
            Set<Skill> skills,
            Set<Profile> profiles,
            String error) {

        static Relations error(String reason) {
            return new Relations(Set.of(), Set.of(), Set.of(), reason);
        }
    }

    private static class ImportState {

        private final boolean dryRun;
        private int plannedCreated;
        private int plannedUpdated;
        private final List<DuplicateEntry> duplicates = new ArrayList<>();
        private final List<ImportError> errors = new ArrayList<>();
        private final List<ImportWarning> warnings = new ArrayList<>();

        private ImportState(boolean dryRun) {
            this.dryRun = dryRun;
        }

        private void record(QuestionOutcome outcome, String label) {
            switch (outcome.type()) {
                case CREATED -> plannedCreated++;
                case UPDATED -> plannedUpdated++;
                case DUPLICATE -> duplicates.add(
                        new DuplicateEntry(outcome.index(), label, outcome.existingId(), outcome.existingTitle()));
                case ERROR -> errors.add(new ImportError(outcome.index(), label, outcome.reason()));
            }
        }

        private void addError(int index, String label, String reason) {
            errors.add(new ImportError(index, label, reason));
        }

        private void addWarning(int index, String label, String message) {
            warnings.add(new ImportWarning(index, label, message));
        }

        private ChallengeImportReport toReport() {
            int executedCreated = dryRun ? 0 : plannedCreated;
            int executedUpdated = dryRun ? 0 : plannedUpdated;
            return new ChallengeImportReport(
                    dryRun,
                    new PlannedCounts(plannedCreated, plannedUpdated),
                    new ExecutedCounts(executedCreated, executedUpdated),
                    List.copyOf(duplicates),
                    List.copyOf(errors),
                    List.copyOf(warnings));
        }
    }
}
