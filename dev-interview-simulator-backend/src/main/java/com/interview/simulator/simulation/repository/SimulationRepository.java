package com.interview.simulator.simulation.repository;

import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.entity.SimulationStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SimulationRepository extends JpaRepository<Simulation, Long> {

    long countByStatus(SimulationStatus status);

    @Query(value = """
        SELECT COUNT(s.id), COUNT(CASE WHEN s.status = 'COMPLETED' THEN 1 END)
        FROM simulations s
        WHERE s.user_id = :userId
        """, nativeQuery = true)
    Object[] findUserSimulationCounts(@Param("userId") Long userId);

    @Query(value = """
        SELECT COUNT(a.id), COUNT(CASE WHEN a.is_correct THEN 1 END)
        FROM simulations s
        JOIN simulation_challenges sc ON sc.simulation_id = s.id
        JOIN simulation_answers a ON a.simulation_challenge_id = sc.id
        WHERE s.user_id = :userId
        """, nativeQuery = true)
    Object[] findUserAnswerCounts(@Param("userId") Long userId);

    @Query(value = """
        SELECT c.type, COUNT(a.id), COUNT(CASE WHEN a.is_correct THEN 1 END)
        FROM simulations s
        JOIN simulation_challenges sc ON sc.simulation_id = s.id
        JOIN challenges c ON c.id = sc.challenge_id
        JOIN simulation_answers a ON a.simulation_challenge_id = sc.id
        WHERE s.user_id = :userId
        GROUP BY c.type
        """, nativeQuery = true)
    List<Object[]> findUserTypeStats(@Param("userId") Long userId);

    @Query(value = """
        SELECT cat.id, cat.name, COUNT(a.id), COUNT(CASE WHEN a.is_correct THEN 1 END)
        FROM simulations s
        JOIN simulation_challenges sc ON sc.simulation_id = s.id
        JOIN challenges c ON c.id = sc.challenge_id
        JOIN simulation_answers a ON a.simulation_challenge_id = sc.id
        JOIN challenge_categories cc ON cc.challenge_id = c.id
        JOIN categories cat ON cat.id = cc.category_id
        WHERE s.user_id = :userId
        GROUP BY cat.id, cat.name
        """, nativeQuery = true)
    List<Object[]> findUserCategoryStats(@Param("userId") Long userId);

    @Query(value = """
        SELECT skill.id, skill.name, COUNT(a.id), COUNT(CASE WHEN a.is_correct THEN 1 END)
        FROM simulations s
        JOIN simulation_challenges sc ON sc.simulation_id = s.id
        JOIN challenges c ON c.id = sc.challenge_id
        JOIN simulation_answers a ON a.simulation_challenge_id = sc.id
        JOIN challenge_skills cs ON cs.challenge_id = c.id
        JOIN skills skill ON skill.id = cs.skill_id
        WHERE s.user_id = :userId
        GROUP BY skill.id, skill.name
        """, nativeQuery = true)
    List<Object[]> findUserSkillStats(@Param("userId") Long userId);

    @Query(value = """
        SELECT AVG(CASE WHEN session.total_questions = 0 THEN 0.0
                        ELSE session.correct_answers * 100.0 / session.total_questions END),
               MAX(CASE WHEN session.total_questions = 0 THEN 0.0
                        ELSE session.correct_answers * 100.0 / session.total_questions END)
        FROM (
            SELECT s.id, COUNT(sc.id) AS total_questions,
                   COUNT(CASE WHEN a.is_correct THEN 1 END) AS correct_answers
            FROM simulations s
            LEFT JOIN simulation_challenges sc ON sc.simulation_id = s.id
            LEFT JOIN simulation_answers a ON a.simulation_challenge_id = sc.id
            WHERE s.user_id = :userId AND s.status = 'COMPLETED'
            GROUP BY s.id
        ) session
        """, nativeQuery = true)
    Object[] findCompletedSimulationRateSummary(@Param("userId") Long userId);

    @Query(value = """
        SELECT COUNT(a.id), COUNT(CASE WHEN a.is_correct THEN 1 END)
        FROM simulations s
        LEFT JOIN simulation_challenges sc ON sc.simulation_id = s.id
        LEFT JOIN simulation_answers a ON a.simulation_challenge_id = sc.id
        WHERE s.user_id = :userId AND s.status = 'COMPLETED'
        GROUP BY s.id, s.started_at
        ORDER BY s.started_at DESC, s.id DESC
        LIMIT 6
        """, nativeQuery = true)
    List<Object[]> findRecentCompletedSimulationRates(@Param("userId") Long userId);

    @Query(value = """
        SELECT s.id, s.mode, s.difficulty, COUNT(sc.id),
               COUNT(CASE WHEN a.is_correct THEN 1 END), COALESCE(s.total_score, 0),
               s.status, s.started_at
        FROM simulations s
        LEFT JOIN simulation_challenges sc ON sc.simulation_id = s.id
        LEFT JOIN simulation_answers a ON a.simulation_challenge_id = sc.id
        WHERE s.user_id = :userId
        GROUP BY s.id, s.mode, s.difficulty, s.total_score, s.status, s.started_at
        ORDER BY s.started_at DESC, s.id DESC
        """, countQuery = "SELECT COUNT(*) FROM simulations WHERE user_id = :userId", nativeQuery = true)
    Page<Object[]> findRecentSimulationsByUserId(@Param("userId") Long userId, Pageable pageable);
}
