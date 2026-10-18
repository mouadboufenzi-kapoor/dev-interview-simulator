package com.interview.simulator.challenge.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.InterviewScenario;
import com.interview.simulator.challenge.entity.SelectionType;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ChallengeIdentityServiceTest {

    private final ChallengeIdentityService service = new ChallengeIdentityService();

    @Test
    void hashStableEtHexMinuscule() {
        Challenge challenge = challenge(ChallengeType.SITUATIONAL_QCM);
        challenge.getOptions().add(option("Réponse A", true, 0));

        String first = service.contentHash(challenge);
        String second = service.contentHash(challenge);

        assertEquals(first, second);
        assertTrue(first.matches("[0-9a-f]{64}"));
    }

    @Test
    void qcmHashInsensibleALOrdreDesOptions() {
        Challenge first = challenge(ChallengeType.SITUATIONAL_QCM);
        first.getOptions().add(option("Réponse A", false, 0));
        first.getOptions().add(option("Réponse B", true, 1));

        Challenge second = challenge(ChallengeType.SITUATIONAL_QCM);
        second.getOptions().add(option("Réponse B", true, 0));
        second.getOptions().add(option("Réponse A", false, 1));

        assertEquals(service.contentHash(first), service.contentHash(second));
    }

    @Test
    void sequentielHashSensibleALOrdreDesEtapes() {
        Challenge first = challenge(ChallengeType.SEQUENTIAL_REASONING);
        first.getOptions().add(option("Étape 1", true, 1));
        first.getOptions().add(option("Étape 2", true, 2));

        Challenge second = challenge(ChallengeType.SEQUENTIAL_REASONING);
        second.getOptions().add(option("Étape 1", true, 2));
        second.getOptions().add(option("Étape 2", true, 1));

        assertNotEquals(service.contentHash(first), service.contentHash(second));
    }

    @Test
    void hashInsensibleALaCasseEtAuxEspacesRepetes() {
        Challenge first = challenge(ChallengeType.SITUATIONAL_QCM);
        first.setContext("Un  contexte\navec\t espaces");
        first.setQuestion("Comment faire ?");

        Challenge second = challenge(ChallengeType.SITUATIONAL_QCM);
        second.setContext("un contexte avec espaces");
        second.setQuestion("COMMENT   FAIRE ?");

        assertEquals(service.contentHash(first), service.contentHash(second));
    }

    @Test
    void titreDuScenarioModifieLeHashPourArchitectureSeulement() {
        Challenge architectureSansScenario = challenge(ChallengeType.ARCHITECTURE);
        Challenge architectureScenarioA = challenge(ChallengeType.ARCHITECTURE);
        architectureScenarioA.setScenario(scenario("Scénario A"));
        Challenge architectureScenarioB = challenge(ChallengeType.ARCHITECTURE);
        architectureScenarioB.setScenario(scenario("Scénario B"));

        assertNotEquals(
                service.contentHash(architectureSansScenario),
                service.contentHash(architectureScenarioA));
        assertNotEquals(
                service.contentHash(architectureScenarioA),
                service.contentHash(architectureScenarioB));

        Challenge qcmSansScenario = challenge(ChallengeType.SITUATIONAL_QCM);
        Challenge qcmAvecScenario = challenge(ChallengeType.SITUATIONAL_QCM);
        qcmAvecScenario.setScenario(scenario("Scénario A"));

        assertEquals(service.contentHash(qcmSansScenario), service.contentHash(qcmAvecScenario));
    }

    private Challenge challenge(ChallengeType type) {
        Challenge challenge = new Challenge();
        challenge.setTitle("Titre de la question");
        challenge.setType(type);
        challenge.setDifficulty(DifficultyLevel.JUNIOR);
        challenge.setSelectionType(SelectionType.SINGLE_CHOICE);
        challenge.setContext("Contexte de la question");
        challenge.setQuestion("Question posée ?");
        challenge.setExplanation("Explication de la réponse");
        challenge.setPoints(10);
        return challenge;
    }

    private ChallengeOption option(String content, boolean correct, int displayOrder) {
        ChallengeOption option = new ChallengeOption();
        option.setContent(content);
        option.setCorrect(correct);
        option.setDisplayOrder(displayOrder);
        return option;
    }

    private InterviewScenario scenario(String title) {
        InterviewScenario scenario = new InterviewScenario();
        scenario.setTitle(title);
        return scenario;
    }
}
