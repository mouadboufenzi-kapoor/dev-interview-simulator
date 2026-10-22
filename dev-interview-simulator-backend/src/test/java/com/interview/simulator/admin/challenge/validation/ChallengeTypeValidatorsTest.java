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

        assertTrue(qcmValidator.validate(twoCorrect).stream()
                .anyMatch(problem -> problem.contains("exactement une bonne réponse")));
        assertTrue(qcmValidator.validate(oneCorrect).contains("Le type SITUATIONAL_QCM nécessite exactement 4 options ; 2 reçue(s)."));
    }

    @Test
    void selectionMultipleExigeAuMoinsUneBonneReponse() {
        ImportedQuestion noneCorrect = question(ChallengeType.PROBLEM_SOLVING, SelectionType.MULTIPLE_CHOICE,
                List.of(option("A", false, 0), option("B", false, 1)));
        ImportedQuestion oneCorrect = question(ChallengeType.PROBLEM_SOLVING, SelectionType.MULTIPLE_CHOICE,
                List.of(option("A", true, 0), option("B", false, 1)));

        assertTrue(problemSolvingValidator.validate(noneCorrect).stream()
                .anyMatch(problem -> problem.contains("bonne réponse")));
        assertTrue(problemSolvingValidator.validate(oneCorrect).stream()
                .anyMatch(problem -> problem.contains("4 options")));
    }

    @Test
    void codeReviewSuitLesReglesDeSelectionEtRefuseLeScenario() {
        ImportedQuestion withScenario = questionWithScenario(ChallengeType.CODE_REVIEW, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0)), "Un scénario", 1);

        List<String> problems = codeReviewValidator.validate(withScenario);
        assertTrue(problems.stream().anyMatch(problem -> problem.contains("ARCHITECTURE")));
    }

    @Test
    void architectureExigeScenarioEtStepOrderValide() {
        ImportedQuestion missingEverything = question(ChallengeType.ARCHITECTURE, SelectionType.SINGLE_CHOICE,
                List.of(option("A", true, 0), option("B", false, 1),
                        option("C", false, 2), option("D", false, 3)));
        ImportedQuestion zeroStepOrder = questionWithScenario(ChallengeType.ARCHITECTURE, SelectionType.SINGLE_CHOICE,
                architectureOptions(), "Scénario", 0);
        ImportedQuestion complete = questionWithScenario(ChallengeType.ARCHITECTURE, SelectionType.SINGLE_CHOICE,
                architectureOptions(), "Scénario", 1);

        assertTrue(architectureValidator.validate(missingEverything).stream()
                .anyMatch(problem -> problem.contains("scénario")));
        assertTrue(architectureValidator.validate(zeroStepOrder).stream()
                .anyMatch(problem -> problem.contains("ordre d'étape")));
        assertTrue(architectureValidator.validate(complete).stream()
                .noneMatch(problem -> problem.contains("scénario") || problem.contains("ordre d'étape")));
        assertTrue(architectureValidator.validate(questionWithScenario(ChallengeType.ARCHITECTURE,
                SelectionType.SINGLE_CHOICE, List.of(option("A", true, 0), option("B", false, 1)),
                "Scénario", 1)).stream()
                .anyMatch(problem -> problem.contains("exactement 4 options")));
    }

    @Test
    void sequentielExigeEtapesCompletesEtPositionsDeZeroANMoinsUn() {
        ImportedQuestion singleStep = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape", true, 0)));
        ImportedQuestion incorrectStep = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape 1", true, 0), option("Étape 2", false, 1),
                        option("Étape 3", true, 2), option("Étape 4", true, 3), option("Étape 5", true, 4)));
        ImportedQuestion wrongPositions = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape 1", true, 1), option("Étape 2", true, 2),
                        option("Étape 3", true, 3), option("Étape 4", true, 4), option("Étape 5", true, 5)));
        ImportedQuestion valid = question(ChallengeType.SEQUENTIAL_REASONING, SelectionType.SINGLE_CHOICE,
                List.of(option("Étape 1", true, 0), option("Étape 2", true, 1),
                        option("Étape 3", true, 2), option("Étape 4", true, 3), option("Étape 5", true, 4)));

        assertEquals(1, sequentialReasoningValidator.validate(singleStep).size());
        assertTrue(sequentialReasoningValidator.validate(singleStep).get(0).contains("exactement 5 étapes"));
        assertTrue(sequentialReasoningValidator.validate(incorrectStep).stream()
                .anyMatch(problem -> problem.contains("Toutes les étapes")));
        assertTrue(sequentialReasoningValidator.validate(wrongPositions).stream()
                .anyMatch(problem -> problem.contains("positions des étapes")));
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

    private List<ImportedOption> architectureOptions() {
        return List.of(option("A", true, 0), option("B", false, 1),
                option("C", false, 2), option("D", false, 3));
    }

    private ImportedOption option(String content, boolean correct, int displayOrder) {
        return new ImportedOption(content, correct, null, null, displayOrder);
    }
}
