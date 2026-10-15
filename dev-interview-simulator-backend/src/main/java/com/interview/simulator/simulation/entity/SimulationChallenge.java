package com.interview.simulator.simulation.entity;

import com.interview.simulator.challenge.entity.Challenge;
import jakarta.persistence.*;
import java.util.Objects;

@Entity
@Table(name = "simulation_challenges")
public class SimulationChallenge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "simulation_id", nullable = false)
    private Simulation simulation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "challenge_id", nullable = false)
    private Challenge challenge;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @OneToOne(mappedBy = "simulationChallenge", cascade = CascadeType.ALL, orphanRemoval = true)
    private SimulationAnswer answer;

    public SimulationChallenge() {
    }

    public Long getId() { return id; }
    public Simulation getSimulation() { return simulation; }
    public void setSimulation(Simulation simulation) { this.simulation = simulation; }
    public Challenge getChallenge() { return challenge; }
    public void setChallenge(Challenge challenge) { this.challenge = challenge; }
    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
    public SimulationAnswer getAnswer() { return answer; }
    public void setAnswer(SimulationAnswer answer) { this.answer = answer; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SimulationChallenge that = (SimulationChallenge) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}