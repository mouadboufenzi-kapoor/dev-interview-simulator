package com.interview.simulator.admin.profile.service;

import com.interview.simulator.admin.profile.dto.AdminProfileRequest;
import com.interview.simulator.admin.profile.dto.AdminProfileResponse;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.exception.ResourceNotFoundException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class AdminProfileService {

    private final ProfileRepository profileRepository;

    public AdminProfileService(ProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    @Transactional(readOnly = true)
    public List<AdminProfileResponse> getAllProfiles() {
        return profileRepository.findAllByOrderByNameAsc().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public AdminProfileResponse create(AdminProfileRequest request) {
        checkUniqueness(request.code(), request.name(), null);
        Profile profile = new Profile(request.code().trim(), request.name().trim(), request.description());
        profile.setActive(request.active() == null || request.active());
        profile.setAllowedTypes(normalizeAllowedTypes(request.allowedTypes()));
        return toResponse(profileRepository.save(profile));
    }

    @Transactional
    public AdminProfileResponse update(Long id, AdminProfileRequest request) {
        Profile profile = findProfile(id);
        checkUniqueness(request.code(), request.name(), id);
        profile.setCode(request.code().trim());
        profile.setName(request.name().trim());
        profile.setDescription(request.description());
        if (request.active() != null) {
            profile.setActive(request.active());
        }
        profile.setAllowedTypes(normalizeAllowedTypes(request.allowedTypes()));
        return toResponse(profileRepository.save(profile));
    }

    @Transactional
    public AdminProfileResponse setActive(Long id, boolean active) {
        Profile profile = findProfile(id);
        profile.setActive(active);
        return toResponse(profileRepository.save(profile));
    }

    private Set<ChallengeType> normalizeAllowedTypes(Set<ChallengeType> allowedTypes) {
        return allowedTypes == null ? new HashSet<>() : new HashSet<>(allowedTypes);
    }

    private void checkUniqueness(String code, String name, Long id) {
        boolean codeTaken = id == null
                ? profileRepository.existsByCode(code.trim())
                : profileRepository.existsByCodeAndIdNot(code.trim(), id);
        if (codeTaken) {
            throw new ApiException(HttpStatus.CONFLICT, "Un profil avec ce code existe déjà.");
        }
        boolean nameTaken = id == null
                ? profileRepository.existsByName(name.trim())
                : profileRepository.existsByNameAndIdNot(name.trim(), id);
        if (nameTaken) {
            throw new ApiException(HttpStatus.CONFLICT, "Un profil avec ce nom existe déjà.");
        }
    }

    private Profile findProfile(Long id) {
        return profileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Profil introuvable."));
    }

    private AdminProfileResponse toResponse(Profile profile) {
        return new AdminProfileResponse(
                profile.getId(),
                profile.getCode(),
                profile.getName(),
                profile.getDescription(),
                profile.isActive(),
                profile.getAllowedTypes()
        );
    }
}
