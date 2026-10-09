package com.interview.simulator.profile.service;

import com.interview.simulator.profile.dto.ProfileResponse;
import com.interview.simulator.profile.repository.ProfileRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProfileService {

    private final ProfileRepository profileRepository;

    public ProfileService(ProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    public List<ProfileResponse> getActiveProfiles() {
        return profileRepository.findByActiveTrueOrderByNameAsc().stream()
                .map(profile -> new ProfileResponse(
                        profile.getId(),
                        profile.getCode(),
                        profile.getName(),
                        profile.getDescription()
                ))
                .toList();
    }
}
