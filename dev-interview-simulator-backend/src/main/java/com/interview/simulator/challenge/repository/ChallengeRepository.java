package com.interview.simulator.challenge.repository;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.profile.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

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