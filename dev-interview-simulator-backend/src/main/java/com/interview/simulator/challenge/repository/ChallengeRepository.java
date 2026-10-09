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

import java.util.List;
import java.util.Set;

@Repository
public interface ChallengeRepository extends JpaRepository<Challenge, Long> {

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
}