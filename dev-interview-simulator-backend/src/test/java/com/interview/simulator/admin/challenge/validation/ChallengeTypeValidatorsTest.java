package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedOption;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.SelectionType;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ChallengeTypeValidatorsTest {

    private final SituationalQcmValidator qcmValidator = new SituationalQcmValidator();
    private final ProblemSolvingValidator problemSolvingValidator = new ProblemSolvingValidator();
    private final CodeReviewValidator codeReviewValidator = new CodeReviewValidator();
    private final ArchitectureValidator architectureValidator = new ArchitectureValidator();
    private final SequentialReasoningValidator sequentialReasoningValidator = new SequentialReasoningValidator();

    @Test
    void qcmSelectionUniqueExigeExactementUneBonneReponse() {
        ImportedQuestion twoCorrect = question(ChallengeType.SITUATIONAL_QCM, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0), option("B", true, 1)));
        ImportedQuestion oneCorrect = question(ChallengeType.SITUATIONAL_QCM, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0), option("B", false, 1)));

        assertEquals(1, qcmValidator.validate(twoCorrect).size());
        assertTrue(qcmValidator.validate(twoCorrect).get(0).contains("exactement une bonne réponse"));
        assertTrue(qcmValidator.validate(oneCorrect).isEmpty());
    }

    @Test
    void selectionMultipleExigeAuMoinsUneBonneReponse() {
        ImportedQuestion noneCorrect = question(ChallengeType.PROBLEM_SOLVING, SelectionType.MULTIPLE_CHOICE,
                List.of(option("A", false, 0), option("B", false, 1)));
        ImportedQuestion oneCorrect = question(ChallengeType.PROBLEM_SOLVING, SelectionType.MULTIPLE_CHOICE,
                List.of(option("A", true, 0), option("B", false, 1)));

        assertEquals(1, problemSolvingValidator.validate(noneCorrect).size());
        assertTrue(problemSolvingValidator.validate(oneCorrect).isEmpty());
    }

    @Test
    void codeReviewSuitLesReglesDeSelectionEtRefuseLeScenario() {
        ImportedQuestion withScenario = questionWithScenario(ChallengeType.CODE_REVIEW, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0)), "Un scénario", 1);

        List<String> problems = codeReviewValidator.validate(withScenario);
        assertEquals(1, problems.size());
        assertTrue(problems.get(0).contains("ARCHITECTURE"));
    }

    @Test
    void architectureExigeScenarioEtStepOrderValide() {
        ImportedQuestion missingEverything = question(ChallengeType.ARCHITECTURE, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0)));
        ImportedQuestion zeroStepOrder = questionWithScenario(ChallengeType.ARCHITECTURE, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0)), "Scénario", 0);
        ImportedQuestion complete = questionWithScenario(ChallengeType.ARCHITECTURE, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0)), "Scénario", 1);

        assertEquals(2, architectureValidator.validate(missingEverything).size());
        assertEquals(1, architectureValidator.validate(zeroStepOrder).size());
        assertTrue(architectureValidator.validate(complete).isEmpty());
    }

    @Test
    void sequentielExigeEtapesCompletesEtPositionsDeZeroANMoinsUn() {
        ImportedQuestion singleStep = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape", true, 0)));
        ImportedQuestion incorrectStep = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape 1", true, 0), option("Étape 2", false, 1)));
        ImportedQuestion wrongPositions = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape 1", true, 1), option("Étape 2", true, 2)));
        ImportedQuestion valid = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape 1", true, 0), option("Étape 2", true, 1)));

        assertEquals(1, sequentialReasoningValidator.validate(singleStep).size());
        assertTrue(sequentialReasoningValidator.validate(singleStep).get(0).contains("au moins 2 étapes"));
        assertEquals(1, sequentialReasoningValidator.validate(incorrectStep).size());
        assertEquals(1, sequentialReasoningValidator.validate(wrongPositions).size());
        assertTrue(sequentialReasoningValidator.validate(valid).isEmpty());
    }

    private ImportedQuestion question(
            ChallengeType type,
            SelectionType selectionType,
            List<ImportedOption> options) {
        return new ImportedQuestion(
                "ext-1", "Titre", type, DifficultyLevel.JUNIOR, selectionType,
                "Contexte", "Question ?", null, null, null, null, null, null, null,
                null, null, null, null, null, options);
    }

    private ImportedQuestion questionWithScenario(
            ChallengeType type,
            SelectionType selectionType,
            List<ImportedOption> options,
            String scenario,
            Integer stepOrder) {
        return new ImportedQuestion(
                "ext-1", "Titre", type, DifficultyLevel.JUNIOR, selectionType,
                "Contexte", "Question ?", null, null, null, null, null, null, null,
                null, null, null, scenario, stepOrder, options);
    }

    private ImportedOption option(String content, boolean correct, int displayOrder) {
        return new ImportedOption(content, correct, null, null, displayOrder);
    }
}
