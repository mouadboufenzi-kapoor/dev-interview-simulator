package com.interview.simulator.admin.challenge.service;

import com.interview.simulator.admin.challenge.dto.*;
import com.interview.simulator.admin.challenge.dto.BackfillIdentityReport.ChallengeReference;
import com.interview.simulator.admin.challenge.dto.BackfillIdentityReport.DuplicateGroup;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.*;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.exception.ResourceNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class AdminChallengeService {

    private static final int BACKFILL_PAGE_SIZE = 100;

    private final ChallengeRepository challengeRepository;
    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;
    private final ProfileRepository profileRepository;
    private final InterviewScenarioRepository interviewScenarioRepository;
    private final ChallengeIdentityService challengeIdentityService;
    private final TransactionTemplate transactionTemplate;

    public AdminChallengeService(
            ChallengeRepository challengeRepository,
            CategoryRepository categoryRepository,
            SkillRepository skillRepository,
            ProfileRepository profileRepository,
            InterviewScenarioRepository interviewScenarioRepository,
            ChallengeIdentityService challengeIdentityService,
            TransactionTemplate transactionTemplate) {
        this.challengeRepository = challengeRepository;
        this.categoryRepository = categoryRepository;
        this.skillRepository = skillRepository;
        this.profileRepository = profileRepository;
        this.interviewScenarioRepository = interviewScenarioRepository;
        this.challengeIdentityService = challengeIdentityService;
        this.transactionTemplate = transactionTemplate;
    }

    @Transactional(readOnly = true)
    public Page<AdminChallengeResponse> search(
            String search,
            ContentStatus status,
            ChallengeType type,
            DifficultyLevel difficulty,
            Long profileId,
            Pageable pageable) {
        String normalizedSearch = search == null ? "" : search.trim();
        return challengeRepository.searchForAdmin(
                normalizedSearch,
                status,
                type,
                difficulty,
                profileId,
                pageable
        ).map(this::toResponse);
    }

    @Transactional(readOnly = true)
    public AdminChallengeResponse get(Long id) {
        return toResponse(findChallenge(id));
    }

    @Transactional
    public AdminChallengeResponse create(AdminChallengeRequest request) {
        Challenge challenge = new Challenge();
        apply(challenge, request);
        challenge.setStatus(ContentStatus.DRAFT);
        return toResponse(challengeRepository.save(challenge));
    }

    @Transactional
    public AdminChallengeResponse update(Long id, AdminChallengeRequest request) {
        Challenge challenge = findChallenge(id);
        apply(challenge, request);
        return toResponse(challengeRepository.save(challenge));
    }

    @Transactional
    public AdminChallengeResponse changeStatus(Long id, ContentStatus status) {
        Challenge challenge = findChallenge(id);
        challenge.setStatus(status);
        challenge.setActive(status != ContentStatus.ARCHIVED);
        return toResponse(challengeRepository.save(challenge));
    }

    public BackfillIdentityReport backfillIdentity() {
        int processed = 0;
        int pageProcessed;
        do {
            pageProcessed = fillIdentityMissingPage();
            processed += pageProcessed;
        } while (pageProcessed > 0);
        return new BackfillIdentityReport(processed, findDuplicateGroups());
    }

    private int fillIdentityMissingPage() {
        Integer processed = transactionTemplate.execute(status -> {
            List<Long> pageIds = challengeRepository.findIdsMissingIdentity(PageRequest.of(0, BACKFILL_PAGE_SIZE));
            if (pageIds.isEmpty()) {
                return 0;
            }
            List<Challenge> challenges = challengeRepository.findAllByIdWithDetails(pageIds);
            challenges.forEach(this::applyLegacyIdentity);
            challengeRepository.saveAll(challenges);
            return challenges.size();
        });
        return processed == null ? 0 : processed;
    }

    private void applyLegacyIdentity(Challenge challenge) {
        if (challenge.getExternalId() == null) {
            challenge.setExternalId(challengeIdentityService.legacyExternalId(challenge.getId()));
        }
        if (challenge.getContentHash() == null) {
            challenge.setContentHash(challengeIdentityService.contentHash(challenge));
        }
    }

    private List<DuplicateGroup> findDuplicateGroups() {
        return challengeRepository.findDuplicatedContentHashes().stream()
                .map(contentHash -> new DuplicateGroup(
                        contentHash,
                        challengeRepository.findIdTitleByContentHash(contentHash).stream()
                                .map(view -> new ChallengeReference(view.getId(), view.getTitle()))
                                .toList()))
                .toList();
    }

    private void apply(Challenge challenge, AdminChallengeRequest request) {
        challenge.setTitle(request.title());
        challenge.setType(request.type());
        challenge.setDifficulty(request.difficulty());
        challenge.setSelectionType(request.selectionType());
        challenge.setContext(request.context());
        challenge.setQuestion(request.question());
        challenge.setCodeSnippet(request.codeSnippet());
        challenge.setCodeLanguage(request.codeLanguage());
        challenge.setRevealedInformation(request.revealedInformation());
        challenge.setTradeoff(request.tradeoff());
        applyScenario(challenge, request);
        challenge.setExplanation(request.explanation());
        challenge.setEstimatedTimeSeconds(request.estimatedTimeSeconds());
        challenge.setPoints(request.points() == null ? 10 : request.points());

        challenge.getCategories().clear();
        challenge.getCategories().addAll(resolve(
                request.categoryIds(),
                categoryRepository::findAllById,
                Category::getId,
                "Catégorie"
        ));

        challenge.getSkills().clear();
        challenge.getSkills().addAll(resolve(
                request.skillIds(),
                skillRepository::findAllById,
                Skill::getId,
                "Compétence"
        ));

        Set<Profile> profiles = resolve(
                request.profileIds(),
                profileRepository::findAllById,
                Profile::getId,
                "Profil"
        );
        if (profiles.stream().anyMatch(profile -> !profile.isActive())) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Un profil inactif ne peut pas être associé à un contenu.");
        }
        challenge.getProfiles().clear();
        challenge.getProfiles().addAll(profiles);

        challenge.getOptions().clear();
        if (request.options() != null) {
            for (AdminChallengeOptionRequest optionRequest : request.options()) {
                ChallengeOption option = new ChallengeOption();
                option.setChallenge(challenge);
                option.setContent(optionRequest.content());
                option.setCorrect(optionRequest.correct());
                option.setSeverity(optionRequest.severity());
                option.setExplanation(optionRequest.explanation());
                option.setDisplayOrder(optionRequest.displayOrder());
                challenge.getOptions().add(option);
            }
        }

        // Raisonnement séquentiel : chaque option est une étape — minimum 2,
        // et toutes les étapes font partie de la réponse (is_correct = true).
        if (challenge.getType() == ChallengeType.SEQUENTIAL_REASONING) {
            if (challenge.getOptions().size() < 2) {
                throw new ApiException(HttpStatus.BAD_REQUEST,
                        "Un défi de raisonnement séquentiel nécessite au moins 2 étapes.");
            }
            challenge.getOptions().forEach(option -> option.setCorrect(true));
        }

        // Cohérence scoring : un contenu à sélection unique doit avoir
        // exactement une bonne réponse, sinon le verdict « correct » et les
        // points pleins divergent (cf. ScoringService.isExactSelection).
        // Le séquentiel est exclu : toutes ses étapes sont correctes par définition.
        if (challenge.getType() != ChallengeType.SEQUENTIAL_REASONING
                && challenge.getSelectionType() == SelectionType.SINGLE_CHOICE
                && !challenge.getOptions().isEmpty()) {
            long singleCorrectCount = challenge.getOptions().stream()
                    .filter(ChallengeOption::isCorrect)
                    .count();
            if (singleCorrectCount != 1) {
                throw new ApiException(HttpStatus.BAD_REQUEST,
                        "Un contenu à sélection unique doit avoir exactement une bonne réponse.");
            }
        }

        if (challenge.getExternalId() == null) {
            challenge.setExternalId(challengeIdentityService.generateExternalId());
        }
        challenge.setContentHash(challengeIdentityService.contentHash(challenge));
    }

    private void applyScenario(Challenge challenge, AdminChallengeRequest request) {
        if (request.type() != ChallengeType.ARCHITECTURE) {
            challenge.setScenario(null);
            challenge.setStepOrder(null);
            return;
        }
        if (request.stepOrder() != null && request.stepOrder() < 1) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "L'ordre d'étape doit être supérieur à 0.");
        }
        InterviewScenario scenario = null;
        if (request.scenarioId() != null) {
            scenario = interviewScenarioRepository.findById(request.scenarioId())
                    .orElseThrow(() -> new ResourceNotFoundException("Scénario introuvable."));
        }
        if (scenario != null && request.stepOrder() != null
                && challengeRepository.existsByScenarioIdAndStepOrderAndIdNot(
                        scenario.getId(), request.stepOrder(), challenge.getId())) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Une étape utilise déjà cet ordre dans ce scénario.");
        }
        challenge.setScenario(scenario);
        challenge.setStepOrder(request.stepOrder());
    }

    private <T> Set<T> resolve(
            Set<Long> ids,
            Function<Iterable<Long>, Iterable<T>> finder,
            Function<T, Long> idExtractor,
            String label) {
        if (ids == null || ids.isEmpty()) {
            return new HashSet<>();
        }
        List<T> found = new ArrayList<>();
        finder.apply(ids).forEach(found::add);
        Set<Long> foundIds = found.stream().map(idExtractor).collect(Collectors.toSet());
        Set<Long> missing = ids.stream()
                .filter(id -> !foundIds.contains(id))
                .collect(Collectors.toSet());
        if (!missing.isEmpty()) {
            throw new ResourceNotFoundException(label + "(s) introuvable(s): " + missing);
        }
        return new HashSet<>(found);
    }

    private Challenge findChallenge(Long id) {
        return challengeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Contenu introuvable."));
    }

    private AdminChallengeResponse toResponse(Challenge challenge) {
        return new AdminChallengeResponse(
                challenge.getId(),
                challenge.getTitle(),
                challenge.getType(),
                challenge.getDifficulty(),
                challenge.getSelectionType(),
                challenge.getContext(),
                challenge.getQuestion(),
                challenge.getCodeSnippet(),
                challenge.getCodeLanguage(),
                challenge.getRevealedInformation(),
                challenge.getTradeoff(),
                challenge.getScenario() != null ? challenge.getScenario().getId() : null,
                challenge.getStepOrder(),
                challenge.getExplanation(),
                challenge.getEstimatedTimeSeconds(),
                challenge.getPoints(),
                challenge.getStatus(),
                challenge.isActive(),
                challenge.getCategories().stream().map(Category::getId).collect(Collectors.toSet()),
                challenge.getSkills().stream().map(Skill::getId).collect(Collectors.toSet()),
                challenge.getProfiles().stream().map(Profile::getId).collect(Collectors.toSet()),
                challenge.getOptions().stream()
                        .map(option -> new AdminChallengeOptionResponse(
                                option.getId(),
                                option.getContent(),
                                option.isCorrect(),
                                option.getSeverity(),
                                option.getExplanation(),
                                option.getDisplayOrder()
                        ))
                        .toList(),
                challenge.getCreatedAt(),
                challenge.getUpdatedAt()
        );
    }
}
