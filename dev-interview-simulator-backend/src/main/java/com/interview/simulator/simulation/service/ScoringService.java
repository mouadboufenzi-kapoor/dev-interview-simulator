package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.SelectionType;
import org.springframework.stereotype.Service;

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
}
