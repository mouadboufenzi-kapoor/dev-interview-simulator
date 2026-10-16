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
        List<String> problems = new ArrayList<>(selectionProblems(question));
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
