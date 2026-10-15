package com.interview.simulator.simulation.repository;

import com.interview.simulator.simulation.entity.SimulationChallenge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SimulationChallengeRepository extends JpaRepository<SimulationChallenge, Long> {
}