package com.interview.simulator.challenge.entity;

import com.interview.simulator.category.entity.Category;
import com.interview.simulator.skill.entity.Skill;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "challenges")
public class Challenge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(nullable = false)
    private String title;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChallengeType type;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DifficultyLevel difficulty;

    @Enumerated(EnumType.STRING)
    @Column(name = "selection_type", nullable = false, length = 20)
    private SelectionType selectionType = SelectionType.SINGLE_CHOICE;

    @Column(columnDefinition = "TEXT")
    private String context;

    @NotBlank
    @Column(nullable = false, columnDefinition = "TEXT")
    private String question;

    @Lob
    @Column(name = "code_snippet", columnDefinition = "TEXT")
    private String codeSnippet;

    @Column(name = "code_language", length = 30)
    private String codeLanguage;

    @Column(columnDefinition = "TEXT")
    private String explanation;

    @Column(name = "estimated_time_seconds")
    private Integer estimatedTimeSeconds;

    @Column(nullable = false)
    private boolean active = true;

    @Column(nullable = false)
    private Integer points = 10;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "challenge", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ChallengeOption> options = new ArrayList<>();

    @ManyToMany
    @JoinTable(
        name = "challenge_categories",
        joinColumns = @JoinColumn(name = "challenge_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    private Set<Category> categories = new HashSet<>();

    @ManyToMany
    @JoinTable(
        name = "challenge_skills",
        joinColumns = @JoinColumn(name = "challenge_id"),
        inverseJoinColumns = @JoinColumn(name = "skill_id")
    )
    private Set<Skill> skills = new HashSet<>();

    public Challenge() {
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public ChallengeType getType() { return type; }
    public void setType(ChallengeType type) { this.type = type; }
    public DifficultyLevel getDifficulty() { return difficulty; }
    public void setDifficulty(DifficultyLevel difficulty) { this.difficulty = difficulty; }
    public SelectionType getSelectionType() { return selectionType; }
    public void setSelectionType(SelectionType selectionType) { this.selectionType = selectionType; }
    public String getContext() { return context; }
    public void setContext(String context) { this.context = context; }
    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }
    public String getCodeSnippet() { return codeSnippet; }
    public void setCodeSnippet(String codeSnippet) { this.codeSnippet = codeSnippet; }
    public String getCodeLanguage() { return codeLanguage; }
    public void setCodeLanguage(String codeLanguage) { this.codeLanguage = codeLanguage; }
    public String getExplanation() { return explanation; }
    public void setExplanation(String explanation) { this.explanation = explanation; }
    public Integer getEstimatedTimeSeconds() { return estimatedTimeSeconds; }
    public void setEstimatedTimeSeconds(Integer estimatedTimeSeconds) { this.estimatedTimeSeconds = estimatedTimeSeconds; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public List<ChallengeOption> getOptions() { return options; }
    public Set<Category> getCategories() { return categories; }
    public Set<Skill> getSkills() { return skills; }
    public Integer getPoints() { 
        return points; 
    }
    public void setPoints(Integer points) { 
        this.points = points; 
    }
}