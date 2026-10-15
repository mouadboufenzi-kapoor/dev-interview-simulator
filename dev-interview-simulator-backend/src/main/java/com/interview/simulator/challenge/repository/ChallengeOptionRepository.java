package com.interview.simulator.challenge.repository;

import com.interview.simulator.challenge.entity.ChallengeOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChallengeOptionRepository extends JpaRepository<ChallengeOption, Long> {
}