package com.interview.simulator.admin.challenge.service;

import com.interview.simulator.admin.challenge.dto.*;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.*;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import com.interview.simulator.exception.ResourceNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class AdminChallengeService {

    private final ChallengeRepository challengeRepository;
    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;
    private final ProfileRepository profileRepository;

    public AdminChallengeService(
            ChallengeRepository challengeRepository,
            CategoryRepository categoryRepository,
            SkillRepository skillRepository,
            ProfileRepository profileRepository) {
        this.challengeRepository = challengeRepository;
        this.categoryRepository = categoryRepository;
        this.skillRepository = skillRepository;
        this.profileRepository = profileRepository;
    }

    @Transactional(readOnly = true)
    public Page<AdminChallengeResponse> search(
            String search,
            ContentStatus status,
            ChallengeType type,
            DifficultyLevel difficulty,
            Pageable pageable) {
        String normalizedSearch = search == null || search.isBlank() ? null : search.trim();
        return challengeRepository.searchForAdmin(
                normalizedSearch,
                status,
                type,
                difficulty,
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

        challenge.getProfiles().clear();
        challenge.getProfiles().addAll(resolve(
                request.profileIds(),
                profileRepository::findAllById,
                Profile::getId,
                "Profil"
        ));

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
