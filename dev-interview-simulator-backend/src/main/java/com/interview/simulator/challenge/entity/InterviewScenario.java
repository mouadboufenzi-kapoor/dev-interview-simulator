package com.interview.simulator.challenge.entity;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "interview_scenarios")
public class InterviewScenario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private ChallengeType mode = ChallengeType.ARCHITECTURE;

    @Column(nullable = false)
    private boolean active = true;

    @OneToMany(mappedBy = "scenario")
    @OrderBy("stepOrder ASC")
    private List<Challenge> challenges = new ArrayList<>();

    public Long getId() { return id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public ChallengeType getMode() { return mode; }
    public void setMode(ChallengeType mode) { this.mode = mode; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public List<Challenge> getChallenges() { return challenges; }
}
