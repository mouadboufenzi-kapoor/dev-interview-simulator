package com.interview.simulator.simulation.repository;

import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.entity.SimulationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SimulationRepository extends JpaRepository<Simulation, Long> {

    long countByStatus(SimulationStatus status);

    @Query("""
        SELECT DISTINCT s FROM Simulation s
        LEFT JOIN FETCH s.simulationChallenges sc
        LEFT JOIN FETCH sc.challenge ch
        LEFT JOIN FETCH sc.answer
        WHERE s.user.id = :userId
        ORDER BY s.startedAt DESC
    """)
    List<Simulation> findAllByUserIdWithChallenges(@Param("userId") Long userId);
}