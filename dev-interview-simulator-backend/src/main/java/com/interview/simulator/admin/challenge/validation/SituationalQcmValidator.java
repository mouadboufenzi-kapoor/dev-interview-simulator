package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.challenge.entity.SelectionType;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class SituationalQcmValidator implements ChallengeTypeValidator {

    @Override
    public List<String> validate(ImportedQuestion question) {
        List<String> problems = new ArrayList<>(selectionTypeProblems(question, SelectionType.SINGLE_CHOICE));
        problems.addAll(selectionProblems(question));
        problems.addAll(optionCountProblems(question, 4, 4));
        problems.addAll(scenarioForbiddenProblems(question));
        return problems;
    }
}
