package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class ArchitectureValidator implements ChallengeTypeValidator {

    private static final int MIN_STEP_ORDER = 1;

    @Override
    public List<String> validate(ImportedQuestion question) {
        List<String> problems = new ArrayList<>(selectionTypeProblems(question,
                com.interview.simulator.challenge.entity.SelectionType.SINGLE_CHOICE));
        problems.addAll(optionCountProblems(question, 4, 4));
        if (question.options() != null && question.options().stream()
                .filter(com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedOption::correct)
                .count() != 1) {
            problems.add("Une étape ARCHITECTURE doit avoir exactement une bonne réponse.");
        }
        problems.addAll(selectionProblems(question));
        if (question.revealedInformation() == null || question.revealedInformation().isBlank()) {
            problems.add("Un contenu ARCHITECTURE doit inclure un repère concret dans revealedInformation.");
        }
        if (question.tradeoff() == null || question.tradeoff().isBlank()) {
            problems.add("Un contenu ARCHITECTURE doit inclure un compromis dans tradeoff.");
        }
        if (ChallengeTypeValidator.isBlank(question.scenario())) {
            problems.add("Un contenu ARCHITECTURE doit référencer un scénario par son titre.");
        }
        if (question.stepOrder() == null || question.stepOrder() < MIN_STEP_ORDER) {
            problems.add("Un contenu ARCHITECTURE doit avoir un ordre d'étape supérieur ou égal à "
                    + MIN_STEP_ORDER + ".");
        }
        return problems;
    }
}
