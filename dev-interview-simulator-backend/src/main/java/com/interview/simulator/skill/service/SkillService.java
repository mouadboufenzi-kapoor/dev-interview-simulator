package com.interview.simulator.skill.service;

import com.interview.simulator.skill.dto.SkillResponse;
import com.interview.simulator.skill.repository.SkillRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SkillService {

    private final SkillRepository skillRepository;

    public SkillService(SkillRepository skillRepository) {
        this.skillRepository = skillRepository;
    }

    public List<SkillResponse> getAllSkills() {
        return skillRepository.findAll().stream()
                .map(s -> new SkillResponse(s.getId(), s.getName(), s.getDescription()))
                .toList();
    }
}