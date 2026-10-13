package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.SelectionType;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Set;

@Service
public class ScoringService {

    public int calculateScore(Challenge challenge, Set<ChallengeOption> selectedOptions) {
        if (challenge.getSelectionType() != SelectionType.MULTIPLE_CHOICE) {
            return selectedOptions.stream().anyMatch(ChallengeOption::isCorrect)
                    ? challenge.getPoints()
                    : 0;
        }

        long correctCount = challenge.getOptions().stream()
                .filter(ChallengeOption::isCorrect)
                .count();
        if (correctCount == 0) {
            return 0;
        }

        long selectedCorrectCount = selectedOptions.stream()
                .filter(ChallengeOption::isCorrect)
                .count();
        long selectedIncorrectCount = selectedOptions.stream()
                .filter(option -> !option.isCorrect())
                .count();
        double pointsPerCorrectOption = (double) challenge.getPoints() / correctCount;
        double score = (selectedCorrectCount - (0.5 * selectedIncorrectCount))
                * pointsPerCorrectOption;

        return (int) Math.max(0, Math.round(score));
    }

    /**
     * Raisonnement séquentiel : score partiel = points × (positions correctes / total).
     * L'ordre attendu est porté par displayOrder des options en base — jamais par le DTO.
     */
    public int calculateSequenceScore(Challenge challenge, List<Long> orderedOptionIds) {
        List<Long> expectedOrder = challenge.getOptions().stream()
                .sorted(Comparator.comparingInt(ChallengeOption::getDisplayOrder))
                .map(ChallengeOption::getId)
                .toList();
        if (expectedOrder.size() != orderedOptionIds.size()) {
            return 0;
        }
        long correctPositions = 0;
        for (int i = 0; i < expectedOrder.size(); i++) {
            if (expectedOrder.get(i).equals(orderedOptionIds.get(i))) {
                correctPositions++;
            }
        }
        return (int) Math.round(challenge.getPoints() * ((double) correctPositions / expectedOrder.size()));
    }
}
