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

    /**
     * Sélection exacte : toutes les options choisies sont correctes ET leur
     * nombre correspond au nombre de bonnes réponses. C'est LE critère unique
     * du verdict « correct » — le score en découle pour garantir l'invariants
     * « points pleins ⇔ réponse correcte » (aucun écran ne peut contredire les
     * réponses données).
     */
    public boolean isExactSelection(Challenge challenge, Set<ChallengeOption> selectedOptions) {
        if (selectedOptions.isEmpty()) {
            return false;
        }
        long correctCount = challenge.getOptions().stream()
                .filter(ChallengeOption::isCorrect)
                .count();
        return selectedOptions.stream().allMatch(ChallengeOption::isCorrect)
                && selectedOptions.size() == correctCount;
    }

    public int calculateScore(Challenge challenge, Set<ChallengeOption> selectedOptions) {
        boolean exact = isExactSelection(challenge, selectedOptions);

        // Sélection unique (QCM, Code Review, Architecture…) : points pleins si
        // et seulement si la sélection est exacte, sinon 0. (Ancienne règle
        // « anyMatch » : donnait des points pleins à une réponse marquée
        // incorrecte dès qu'une question SINGLE avait plusieurs bonnes réponses.)
        if (challenge.getSelectionType() != SelectionType.MULTIPLE_CHOICE) {
            return exact ? challenge.getPoints() : 0;
        }

        long correctCount = challenge.getOptions().stream()
                .filter(ChallengeOption::isCorrect)
                .count();
        if (correctCount == 0) {
            return 0;
        }
        if (exact) {
            return challenge.getPoints();
        }

        // Crédit partiel MULTIPLE : (bons − 0,5 × faux) × points/bons, plancher 0.
        // Jamais de points pleins sans sélection exacte (bornage à points − 1)
        // pour que « score = maximum » implique toujours « réponse correcte ».
        long selectedCorrectCount = selectedOptions.stream()
                .filter(ChallengeOption::isCorrect)
                .count();
        long selectedIncorrectCount = selectedOptions.stream()
                .filter(option -> !option.isCorrect())
                .count();
        double pointsPerCorrectOption = (double) challenge.getPoints() / correctCount;
        double score = (selectedCorrectCount - (0.5 * selectedIncorrectCount))
                * pointsPerCorrectOption;

        int rounded = (int) Math.max(0, Math.round(score));
        return Math.min(rounded, Math.max(challenge.getPoints() - 1, 0));
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
