package com.interview.simulator.profile.entity;

import com.interview.simulator.challenge.entity.ChallengeType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Table(name = "profiles")
public class Profile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false, unique = true, length = 50)
    private String code;

    @NotBlank
    @Column(nullable = false, unique = true)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private boolean active = true;

    /**
     * Types de challenges autorisés pour ce profil.
     * Vide = aucun type restreint (tous les types sont autorisés, comportement historique).
     */
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "profile_challenge_types", joinColumns = @JoinColumn(name = "profile_id"))
    @Enumerated(EnumType.STRING)
    @Column(name = "challenge_type", nullable = false, length = 30)
    private Set<ChallengeType> allowedTypes = new HashSet<>();

    public Profile() {
    }

    public Profile(String code, String name, String description) {
        this.code = code;
        this.name = name;
        this.description = description;
    }

    public Long getId() { return id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Set<ChallengeType> getAllowedTypes() { return allowedTypes; }
    public void setAllowedTypes(Set<ChallengeType> allowedTypes) { this.allowedTypes = allowedTypes; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Profile profile = (Profile) o;
        return Objects.equals(id, profile.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
