package com.interview.simulator.challenge.repository;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.profile.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
public interface ChallengeRepository extends JpaRepository<Challenge, Long> {

    boolean existsByScenarioIdAndStepOrderAndIdNot(Long scenarioId, Integer stepOrder, Long id);

    boolean existsByScenarioIdAndStepOrder(Long scenarioId, Integer stepOrder);

    Optional<Challenge> findByExternalId(String externalId);

    List<Challenge> findByContentHash(String contentHash);

    long countByStatus(ContentStatus status);

    long countByType(ChallengeType type);

    @Query("""
        SELECT p.id, p.name, c.difficulty, c.type, cat.id, cat.name, COUNT(DISTINCT c.id)
        FROM Challenge c JOIN c.categories cat JOIN c.profiles p
        WHERE c.active = true AND c.status = :status AND p.active = true
          AND (:profileId IS NULL OR p.id = :profileId)
          AND (:difficulty IS NULL OR c.difficulty = :difficulty)
          AND (:type IS NULL OR c.type = :type)
          AND (SIZE(p.allowedTypes) = 0 OR c.type MEMBER OF p.allowedTypes)
          AND c.type <> com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
        GROUP BY p.id, p.name, c.difficulty, c.type, cat.id, cat.name
    """)
    List<Object[]> countCoverageByCategory(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("type") ChallengeType type,
            @Param("status") ContentStatus status);

    @Query("""
        SELECT p.id, p.name, c.difficulty, c.type, skill.id, skill.name, COUNT(DISTINCT c.id)
        FROM Challenge c JOIN c.skills skill JOIN c.profiles p
        WHERE c.active = true AND c.status = :status AND p.active = true
          AND (:profileId IS NULL OR p.id = :profileId)
          AND (:difficulty IS NULL OR c.difficulty = :difficulty)
          AND (:type IS NULL OR c.type = :type)
          AND (SIZE(p.allowedTypes) = 0 OR c.type MEMBER OF p.allowedTypes)
          AND c.type <> com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
        GROUP BY p.id, p.name, c.difficulty, c.type, skill.id, skill.name
    """)
    List<Object[]> countCoverageBySkill(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("type") ChallengeType type,
            @Param("status") ContentStatus status);

    @Query("""
        SELECT p.id, p.name, c.difficulty, c.type, cat.id, cat.name, COUNT(DISTINCT sc.id)
        FROM InterviewScenario sc JOIN Challenge c ON c.scenario = sc
             JOIN c.categories cat JOIN c.profiles p
        WHERE c.active = true AND c.status = :status AND p.active = true
          AND c.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND (SIZE(p.allowedTypes) = 0 OR c.type MEMBER OF p.allowedTypes)
          AND sc.active = true AND sc.mode = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND (:profileId IS NULL OR p.id = :profileId)
          AND (:difficulty IS NULL OR c.difficulty = :difficulty)
          AND EXISTS (SELECT 1 FROM Challenge step JOIN step.profiles stepProfile
              WHERE step.scenario = sc AND step.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
                AND step.active = true AND step.status = :status AND step.difficulty = c.difficulty
                AND stepProfile.id = p.id)
        GROUP BY p.id, p.name, c.difficulty, c.type, cat.id, cat.name
    """)
    List<Object[]> countArchitectureCoverageByCategory(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("status") ContentStatus status);

    @Query("""
        SELECT p.id, p.name, c.difficulty, c.type, skill.id, skill.name, COUNT(DISTINCT sc.id)
        FROM InterviewScenario sc JOIN Challenge c ON c.scenario = sc
             JOIN c.skills skill JOIN c.profiles p
        WHERE c.active = true AND c.status = :status AND p.active = true
          AND c.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND (SIZE(p.allowedTypes) = 0 OR c.type MEMBER OF p.allowedTypes)
          AND sc.active = true AND sc.mode = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND (:profileId IS NULL OR p.id = :profileId)
          AND (:difficulty IS NULL OR c.difficulty = :difficulty)
          AND EXISTS (SELECT 1 FROM Challenge step JOIN step.profiles stepProfile
              WHERE step.scenario = sc AND step.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
                AND step.active = true AND step.status = :status AND step.difficulty = c.difficulty
                AND stepProfile.id = p.id)
        GROUP BY p.id, p.name, c.difficulty, c.type, skill.id, skill.name
    """)
    List<Object[]> countArchitectureCoverageBySkill(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("status") ContentStatus status);

    @Query(value = """
        SELECT DISTINCT c FROM Challenge c JOIN c.categories cat JOIN c.profiles p
        WHERE c.active = true AND c.status = :status AND c.type = :type
          AND c.difficulty = :difficulty AND p.id = :profileId AND p.active = true AND cat.id = :taxonomyId
          AND (SIZE(p.allowedTypes) = 0 OR c.type MEMBER OF p.allowedTypes)
        """)
    Page<Challenge> findCoverageChallengesByCategory(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("type") ChallengeType type,
            @Param("status") ContentStatus status,
            @Param("taxonomyId") Long taxonomyId,
            Pageable pageable);

    @Query(value = """
        SELECT DISTINCT c FROM Challenge c JOIN c.skills skill JOIN c.profiles p
        WHERE c.active = true AND c.status = :status AND c.type = :type
          AND c.difficulty = :difficulty AND p.id = :profileId AND p.active = true AND skill.id = :taxonomyId
          AND (SIZE(p.allowedTypes) = 0 OR c.type MEMBER OF p.allowedTypes)
        """)
    Page<Challenge> findCoverageChallengesBySkill(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("type") ChallengeType type,
            @Param("status") ContentStatus status,
            @Param("taxonomyId") Long taxonomyId,
            Pageable pageable);

    List<Challenge> findByScenarioIdOrderByStepOrderAsc(Long scenarioId);

    long countByScenarioId(Long scenarioId);

    @Query("""
        SELECT c FROM Challenge c
        WHERE (
            LOWER(c.title) LIKE LOWER(CONCAT('%', :search, '%'))
            OR LOWER(c.question) LIKE LOWER(CONCAT('%', :search, '%')))
        AND (:status IS NULL OR c.status = :status)
        AND (:type IS NULL OR c.type = :type)
        AND (:difficulty IS NULL OR c.difficulty = :difficulty)
        AND (:profileId IS NULL OR EXISTS (
            SELECT 1 FROM Challenge c2 JOIN c2.profiles p2
            WHERE c2 = c AND p2.id = :profileId))
        ORDER BY c.updatedAt DESC
    """)
    Page<Challenge> searchForAdmin(
        @Param("search") String search,
        @Param("status") ContentStatus status,
        @Param("type") ChallengeType type,
        @Param("difficulty") DifficultyLevel difficulty,
        @Param("profileId") Long profileId,
        Pageable pageable
    );

    @Query("""
        SELECT DISTINCT c FROM Challenge c
        LEFT JOIN c.categories cat
        LEFT JOIN c.skills s
        LEFT JOIN c.profiles p
        WHERE c.active = true
        AND c.type = :type
        AND c.status = :status
        AND (:difficulty IS NULL OR c.difficulty = :difficulty)
        AND (:profile IS NULL OR p = :profile)
        AND (:categoryIds IS NULL OR cat.id IN :categoryIds)
        AND (:skillIds IS NULL OR s.id IN :skillIds)
    """)
    List<Challenge> findMatchingChallenges(
        @Param("type") ChallengeType type,
        @Param("difficulty") DifficultyLevel difficulty,
        @Param("profile") Profile profile,
        @Param("status") ContentStatus status,
        @Param("categoryIds") Set<Long> categoryIds,
        @Param("skillIds") Set<Long> skillIds
    );

    @Query("""
        SELECT c FROM Challenge c
        LEFT JOIN c.profiles p
        WHERE c.active = true
          AND c.type = :type
          AND c.status = :status
          AND (:difficulty IS NULL OR c.difficulty = :difficulty)
          AND (:profile IS NULL OR p = :profile)
          AND c.scenario = :scenario
        ORDER BY c.stepOrder ASC
    """)
    List<Challenge> findScenarioChallenges(
        @Param("type") ChallengeType type,
        @Param("difficulty") DifficultyLevel difficulty,
        @Param("profile") Profile profile,
        @Param("status") ContentStatus status,
        @Param("scenario") InterviewScenario scenario
    );


    @Query(value = """
        SELECT sc.id, sc.title, COUNT(DISTINCT step.id)
        FROM InterviewScenario sc JOIN Challenge c ON c.scenario = sc
             JOIN c.profiles p JOIN c.categories cat
             JOIN Challenge step ON step.scenario = sc JOIN step.profiles stepProfile
        WHERE c.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND c.active = true AND c.status = :status AND c.difficulty = :difficulty
          AND p.id = :profileId AND p.active = true AND sc.active = true AND cat.id = :taxonomyId
          AND sc.mode = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND step.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND step.active = true AND step.status = :status AND step.difficulty = :difficulty
          AND stepProfile.id = :profileId
        GROUP BY sc.id, sc.title
        ORDER BY sc.title, sc.id
        """,
        countQuery = """
        SELECT COUNT(DISTINCT sc.id) FROM InterviewScenario sc JOIN Challenge c ON c.scenario = sc
             JOIN c.profiles p JOIN c.categories cat
        WHERE c.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND c.active = true AND c.status = :status AND c.difficulty = :difficulty
          AND p.id = :profileId AND p.active = true AND sc.active = true AND cat.id = :taxonomyId
          AND sc.mode = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND EXISTS (SELECT 1 FROM Challenge step JOIN step.profiles stepProfile
              WHERE step.scenario = sc AND step.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
                AND step.active = true AND step.status = :status AND step.difficulty = :difficulty
                AND stepProfile.id = :profileId)
        """)
    Page<Object[]> findCoverageScenariosByCategory(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("status") ContentStatus status,
            @Param("taxonomyId") Long taxonomyId,
            Pageable pageable);

    @Query(value = """
        SELECT sc.id, sc.title, COUNT(DISTINCT step.id)
        FROM InterviewScenario sc JOIN Challenge c ON c.scenario = sc
             JOIN c.profiles p JOIN c.skills skill JOIN Challenge step ON step.scenario = sc
             JOIN step.profiles stepProfile
        WHERE c.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND c.active = true AND c.status = :status AND c.difficulty = :difficulty
          AND p.id = :profileId AND p.active = true AND sc.active = true AND skill.id = :taxonomyId
          AND sc.mode = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND step.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND step.active = true AND step.status = :status AND step.difficulty = :difficulty
          AND stepProfile.id = :profileId
        GROUP BY sc.id, sc.title
        ORDER BY sc.title, sc.id
        """,
        countQuery = """
        SELECT COUNT(DISTINCT sc.id) FROM InterviewScenario sc JOIN Challenge c ON c.scenario = sc
             JOIN c.profiles p JOIN c.skills skill
        WHERE c.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND c.active = true AND c.status = :status AND c.difficulty = :difficulty
          AND p.id = :profileId AND p.active = true AND sc.active = true AND skill.id = :taxonomyId
          AND sc.mode = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND EXISTS (SELECT 1 FROM Challenge step JOIN step.profiles stepProfile
              WHERE step.scenario = sc AND step.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
                AND step.active = true AND step.status = :status AND step.difficulty = :difficulty
                AND stepProfile.id = :profileId)
        """)
    Page<Object[]> findCoverageScenariosBySkill(
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("status") ContentStatus status,
            @Param("taxonomyId") Long taxonomyId,
            Pageable pageable);

    @Query("""
        SELECT c FROM Challenge c JOIN c.profiles p
        WHERE c.type = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND c.active = true AND c.status = :status AND c.difficulty = :difficulty
          AND p.id = :profileId AND p.active = true AND c.scenario.id = :scenarioId AND c.scenario.active = true
          AND c.scenario.mode = com.interview.simulator.challenge.entity.ChallengeType.ARCHITECTURE
          AND (SIZE(p.allowedTypes) = 0 OR c.type MEMBER OF p.allowedTypes)
        ORDER BY c.stepOrder ASC
        """)
    Page<Challenge> findCoverageScenarioSteps(
            @Param("scenarioId") Long scenarioId,
            @Param("profileId") Long profileId,
            @Param("difficulty") DifficultyLevel difficulty,
            @Param("status") ContentStatus status,
            Pageable pageable);

    @Query("""
        SELECT c.id FROM Challenge c
        WHERE c.externalId IS NULL OR c.contentHash IS NULL
        ORDER BY c.id
    """)
    List<Long> findIdsMissingIdentity(Pageable pageable);

    @Query("""
        SELECT DISTINCT c FROM Challenge c
        LEFT JOIN FETCH c.options
        LEFT JOIN FETCH c.scenario
        WHERE c.id IN :ids
    """)
    List<Challenge> findAllByIdWithDetails(@Param("ids") List<Long> ids);

    @Query("""
        SELECT c.contentHash FROM Challenge c
        WHERE c.contentHash IS NOT NULL
        GROUP BY c.contentHash
        HAVING COUNT(c) > 1
    """)
    List<String> findDuplicatedContentHashes();

    @Query("""
        SELECT c.id, c.title FROM Challenge c
        WHERE c.contentHash = :contentHash
        ORDER BY c.id
    """)
    List<ChallengeTitleView> findIdTitleByContentHash(@Param("contentHash") String contentHash);

    interface ChallengeTitleView {
        Long getId();
        String getTitle();
    }
}