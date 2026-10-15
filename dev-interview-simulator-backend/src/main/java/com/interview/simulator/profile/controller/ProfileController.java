package com.interview.simulator.profile.controller;

import com.interview.simulator.profile.dto.ProfileResponse;
import com.interview.simulator.profile.service.ProfileService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @GetMapping
    public List<ProfileResponse> getActiveProfiles() {
        return profileService.getActiveProfiles();
    }
}
