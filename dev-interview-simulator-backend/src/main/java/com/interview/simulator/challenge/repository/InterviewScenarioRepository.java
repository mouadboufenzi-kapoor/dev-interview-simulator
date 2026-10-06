package com.interview.simulator.challenge.repository;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.InterviewScenario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface InterviewScenarioRepository extends JpaRepository<InterviewScenario, Long> {

    Optional<InterviewScenario> findFirstByModeAndActiveTrue(ChallengeType mode);
}
