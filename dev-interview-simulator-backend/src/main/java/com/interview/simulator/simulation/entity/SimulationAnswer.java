package com.interview.simulator.simulation.entity;

import com.interview.simulator.challenge.entity.ChallengeOption;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "simulation_answers")
public class SimulationAnswer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "simulation_challenge_id", nullable = false, unique = true)
    private SimulationChallenge simulationChallenge;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "selected_option_id", nullable = false)
    private ChallengeOption selectedOption;

    @Column(name = "is_correct", nullable = false)
    private boolean isCorrect;

    @Column(nullable = false)
    private Integer score;

    @Column(name = "response_time_ms")
    private Long responseTimeMs;

    @Column(name = "answered_at", nullable = false, updatable = false)
    private LocalDateTime answeredAt;

    public SimulationAnswer() {
    }

    @PrePersist
    protected void onCreate() {
        this.answeredAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public SimulationChallenge getSimulationChallenge() { return simulationChallenge; }
    public void setSimulationChallenge(SimulationChallenge simulationChallenge) { this.simulationChallenge = simulationChallenge; }
    public ChallengeOption getSelectedOption() { return selectedOption; }
    public void setSelectedOption(ChallengeOption selectedOption) { this.selectedOption = selectedOption; }
    public boolean isCorrect() { return isCorrect; }
    public void setCorrect(boolean correct) { isCorrect = correct; }
    public Integer getScore() { return score; }
    public void setScore(Integer score) { this.score = score; }
    public Long getResponseTimeMs() { return responseTimeMs; }
    public void setResponseTimeMs(Long responseTimeMs) { this.responseTimeMs = responseTimeMs; }
    public LocalDateTime getAnsweredAt() { return answeredAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SimulationAnswer that = (SimulationAnswer) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}