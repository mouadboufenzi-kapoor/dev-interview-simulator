package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.SelectionType;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ScoringServiceTest {

    private final ScoringService scoringService = new ScoringService();

    @Test
    void shouldAwardFullScoreWhenAllCorrectOptionsAreSelected() {
        Challenge challenge = challengeWithOptions(20);
        Set<ChallengeOption> selected = selected(
                challenge.getOptions().get(0),
                challenge.getOptions().get(1));

        assertEquals(20, scoringService.calculateScore(challenge, selected));
    }

    @Test
    void shouldApplyPenaltyForIncorrectSelection() {
        Challenge challenge = challengeWithOptions(20);
        Set<ChallengeOption> selected = selected(
                challenge.getOptions().get(0),
                challenge.getOptions().get(2));

        assertEquals(5, scoringService.calculateScore(challenge, selected));
    }

    @Test
    void shouldClampNegativeScoreToZero() {
        Challenge challenge = challengeWithOptions(20);
        Set<ChallengeOption> selected = selected(
                challenge.getOptions().get(2),
                challenge.getOptions().get(3));

        assertEquals(0, scoringService.calculateScore(challenge, selected));
    }

    private Challenge challengeWithOptions(int points) {
        Challenge challenge = new Challenge();
        challenge.setSelectionType(SelectionType.MULTIPLE_CHOICE);
        challenge.setPoints(points);

        challenge.getOptions().add(option(true));
        challenge.getOptions().add(option(true));
        challenge.getOptions().add(option(false));
        challenge.getOptions().add(option(false));
        return challenge;
    }

    private ChallengeOption option(boolean correct) {
        ChallengeOption option = new ChallengeOption();
        option.setCorrect(correct);
        return option;
    }

    private Set<ChallengeOption> selected(ChallengeOption... options) {
        Set<ChallengeOption> selected = Collections.newSetFromMap(new IdentityHashMap<>());
        Collections.addAll(selected, options);
        return selected;
    }
}
