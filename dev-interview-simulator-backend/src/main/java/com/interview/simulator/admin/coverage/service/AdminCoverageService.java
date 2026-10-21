package com.interview.simulator.admin.coverage.service;

import com.interview.simulator.admin.coverage.dto.CoverageDetailPage;
import com.interview.simulator.admin.coverage.dto.CoverageOptionsResponse;
import com.interview.simulator.admin.coverage.dto.CoverageOptionsResponse.ProfileOption;
import com.interview.simulator.admin.coverage.dto.CoverageOptionsResponse.TaxonomyOption;
import com.interview.simulator.admin.coverage.dto.CoverageReport;
import com.interview.simulator.admin.coverage.dto.CoverageReport.CoverageCell;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.repository.SkillRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class AdminCoverageService {

    private static final ContentStatus AVAILABLE_STATUS = ContentStatus.VALIDATED;
    private static final int MAX_PAGE_SIZE = 100;

    private final ChallengeRepository challengeRepository;
    private final ProfileRepository profileRepository;
    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;
    private final InterviewScenarioRepository scenarioRepository;

    public AdminCoverageService(
            ChallengeRepository challengeRepository,
            ProfileRepository profileRepository,
            CategoryRepository categoryRepository,
            SkillRepository skillRepository,
            InterviewScenarioRepository scenarioRepository) {
        this.challengeRepository = challengeRepository;
        this.profileRepository = profileRepository;
        this.categoryRepository = categoryRepository;
        this.skillRepository = skillRepository;
        this.scenarioRepository = scenarioRepository;
    }

    @Transactional(readOnly = true)
    public CoverageOptionsResponse getOptions() {
        List<ProfileOption> profiles = profileRepository.findByActiveTrueOrderByNameAsc().stream()
                .map(profile -> new ProfileOption(
                        profile.getId(), profile.getCode(), profile.getName(), profile.getAllowedTypes()))
                .toList();
        List<TaxonomyOption> categories = categoryRepository.findAllByOrderByNameAsc().stream()
                .map(category -> new TaxonomyOption(category.getId(), category.getName()))
                .toList();
        List<TaxonomyOption> skills = skillRepository.findAllByOrderByNameAsc().stream()
                .map(skill -> new TaxonomyOption(skill.getId(), skill.getName()))
                .toList();
        return new CoverageOptionsResponse(profiles, List.of(ChallengeType.values()),
                List.of(DifficultyLevel.values()), categories, skills);
    }

    @Transactional(readOnly = true)
    public CoverageReport getCoverage(Long profileId, DifficultyLevel difficulty, ChallengeType type, String dimension) {
        validateDimension(dimension);
        if (profileId != null && profileRepository.findById(profileId).filter(Profile::isActive).isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Profil actif introuvable.");
        }
        if (profileId != null && type != null) {
            requireSupported(activeProfile(profileId), type, dimension);
        }

        List<Profile> profiles = profileRepository.findByActiveTrueOrderByNameAsc().stream()
                .filter(profile -> profileId == null || profile.getId().equals(profileId))
                .toList();
        List<DifficultyLevel> difficulties = difficulty == null
                ? List.of(DifficultyLevel.values()) : List.of(difficulty);
        List<ChallengeType> types = type == null ? List.of(ChallengeType.values()) : List.of(type);
        List<TaxonomyOption> taxonomy = "CATEGORY".equals(dimension)
                ? categoryRepository.findAllByOrderByNameAsc().stream()
                    .map(category -> new TaxonomyOption(category.getId(), category.getName())).toList()
                : skillRepository.findAllByOrderByNameAsc().stream()
                    .map(skill -> new TaxonomyOption(skill.getId(), skill.getName())).toList();
        Map<String, CoverageCell> cells = new LinkedHashMap<>();
        for (Profile profile : profiles) {
            for (DifficultyLevel level : difficulties) {
                for (ChallengeType candidate : types) {
                    if (!isTypeAllowed(profile, candidate)) continue;
                    for (TaxonomyOption option : taxonomy) {
                        String key = cellKey(profile.getId(), level, candidate, option.id());
                        cells.put(key, new CoverageCell(profile.getId(), profile.getName(), level,
                                candidate, option.id(), option.name(), 0));
                    }
                }
            }
        }

        List<Object[]> rows = new java.util.ArrayList<>();
        if (type == null || type == ChallengeType.ARCHITECTURE) {
            rows.addAll("CATEGORY".equals(dimension)
                    ? challengeRepository.countArchitectureCoverageByCategory(profileId, difficulty, AVAILABLE_STATUS)
                    : challengeRepository.countArchitectureCoverageBySkill(profileId, difficulty, AVAILABLE_STATUS));
        }
        if (type == null || type != ChallengeType.ARCHITECTURE) {
            rows.addAll("CATEGORY".equals(dimension)
                    ? challengeRepository.countCoverageByCategory(profileId, difficulty, type, AVAILABLE_STATUS)
                    : challengeRepository.countCoverageBySkill(profileId, difficulty, type, AVAILABLE_STATUS));
        }
        rows.forEach(row -> {
            Long rowProfileId = ((Number) row[0]).longValue();
            DifficultyLevel rowDifficulty = (DifficultyLevel) row[2];
            ChallengeType rowType = (ChallengeType) row[3];
            Long taxonomyId = ((Number) row[4]).longValue();
            String key = cellKey(rowProfileId, rowDifficulty, rowType, taxonomyId);
            CoverageCell current = cells.get(key);
            if (current != null) {
                cells.put(key, new CoverageCell(current.profileId(), current.profileName(),
                        current.difficulty(), current.type(), current.taxonomyId(), current.taxonomyName(),
                        ((Number) row[6]).longValue()));
            }
        });
        return new CoverageReport(cells.values().stream().toList());
    }

    @Transactional(readOnly = true)
    public CoverageDetailPage getDetails(
            Long profileId,
            DifficultyLevel difficulty,
            ChallengeType type,
            String dimension,
            Long taxonomyId,
            int page,
            int size) {
        Profile profile = activeProfile(profileId);
        requireSupported(profile, type, dimension);
        requireTaxonomyExists(dimension, taxonomyId);
        int safePage = Math.max(page, 0);
        int safeSize = Math.max(1, Math.min(size, MAX_PAGE_SIZE));

        if (type == ChallengeType.ARCHITECTURE) {
            if (!scenarioRepository.existsByModeAndActiveTrue(ChallengeType.ARCHITECTURE)) {
                return new CoverageDetailPage(List.of(), safePage, safeSize, 0, 0);
            }
            PageRequest pageable = PageRequest.of(safePage, safeSize);
            Page<Object[]> scenarios = "CATEGORY".equals(dimension)
                    ? challengeRepository.findCoverageScenariosByCategory(profileId, difficulty,
                            AVAILABLE_STATUS, taxonomyId, pageable)
                    : challengeRepository.findCoverageScenariosBySkill(profileId, difficulty,
                            AVAILABLE_STATUS, taxonomyId, pageable);
            List<CoverageDetailPage.ContentItem> items = scenarios.getContent().stream().map(row ->
                    new CoverageDetailPage.ContentItem(
                            (Long) row[0], (String) row[1], null, ChallengeType.ARCHITECTURE, difficulty,
                            null, (Long) row[0], (String) row[1], ((Number) row[2]).longValue()))
                    .toList();
            return new CoverageDetailPage(items, scenarios.getNumber(), scenarios.getSize(),
                    scenarios.getTotalElements(), scenarios.getTotalPages());
        }

        PageRequest pageable = PageRequest.of(safePage, safeSize, Sort.by(Sort.Direction.ASC, "title"));
        Page<Challenge> challenges = "CATEGORY".equals(dimension)
                ? challengeRepository.findCoverageChallengesByCategory(profileId, difficulty, type,
                        AVAILABLE_STATUS, taxonomyId, pageable)
                : challengeRepository.findCoverageChallengesBySkill(profileId, difficulty, type,
                        AVAILABLE_STATUS, taxonomyId, pageable);
        List<CoverageDetailPage.ContentItem> items = challenges.getContent().stream().map(challenge ->
                new CoverageDetailPage.ContentItem(challenge.getId(), challenge.getTitle(), challenge.getQuestion(), challenge.getType(),
                        challenge.getDifficulty(), challenge.getStepOrder(),
                        challenge.getScenario() == null ? null : challenge.getScenario().getId(),
                        challenge.getScenario() == null ? null : challenge.getScenario().getTitle(), 0))
                .toList();
        return new CoverageDetailPage(items, challenges.getNumber(), challenges.getSize(),
                challenges.getTotalElements(), challenges.getTotalPages());
    }

    @Transactional(readOnly = true)
    public CoverageDetailPage getScenarioSteps(Long profileId, DifficultyLevel difficulty, Long scenarioId,
                                               int page, int size) {
        Profile profile = activeProfile(profileId);
        requireSupported(profile, ChallengeType.ARCHITECTURE, "CATEGORY");
        if (scenarioRepository.findById(scenarioId)
                .filter(InterviewScenario::isActive)
                .filter(scenario -> scenario.getMode() == ChallengeType.ARCHITECTURE)
                .isEmpty()) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Scénario Architecture actif introuvable.");
        }
        Page<Challenge> steps = challengeRepository.findCoverageScenarioSteps(scenarioId, profileId,
                difficulty, AVAILABLE_STATUS, PageRequest.of(Math.max(page, 0),
                        Math.max(1, Math.min(size, MAX_PAGE_SIZE)), Sort.by(Sort.Direction.ASC, "stepOrder")));
        List<CoverageDetailPage.ContentItem> items = steps.getContent().stream().map(challenge ->
                new CoverageDetailPage.ContentItem(challenge.getId(), challenge.getTitle(), challenge.getQuestion(), challenge.getType(),
                        challenge.getDifficulty(), challenge.getStepOrder(), scenarioId,
                        challenge.getScenario().getTitle(), steps.getTotalElements()))
                .toList();
        return new CoverageDetailPage(items, steps.getNumber(), steps.getSize(),
                steps.getTotalElements(), steps.getTotalPages());
    }

    private Profile activeProfile(Long profileId) {
        return profileRepository.findById(profileId)
                .filter(Profile::isActive)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Profil actif introuvable."));
    }

    private void requireSupported(Profile profile, ChallengeType type, String dimension) {
        validateDimension(dimension);
        if (!isTypeAllowed(profile, type)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Ce type n'est pas autorisé pour le profil.");
        }
    }

    private boolean isTypeAllowed(Profile profile, ChallengeType type) {
        return profile.getAllowedTypes() == null || profile.getAllowedTypes().isEmpty()
                || profile.getAllowedTypes().contains(type);
    }

    private void validateDimension(String dimension) {
        if (!Set.of("CATEGORY", "SKILL").contains(dimension)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Dimension de taxonomie invalide.");
        }
    }

    private String cellKey(Long profileId, DifficultyLevel difficulty, ChallengeType type, Long taxonomyId) {
        return profileId + ":" + difficulty + ":" + type + ":" + taxonomyId;
    }

    private void requireTaxonomyExists(String dimension, Long id) {
        boolean exists = "CATEGORY".equals(dimension)
                ? categoryRepository.existsById(id)
                : "SKILL".equals(dimension) && skillRepository.existsById(id);
        if (!exists) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Élément de taxonomie introuvable.");
        }
    }
}
