package com.interview.simulator.skill.repository;

import com.interview.simulator.skill.entity.Skill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Set;

@Repository
public interface SkillRepository extends JpaRepository<Skill, Long> {

    Set<Skill> findByNameIn(Set<String> names);
}