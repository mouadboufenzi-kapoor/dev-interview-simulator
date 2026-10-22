package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedOption;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.challenge.entity.SelectionType;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.IntStream;

@Component
public class SequentialReasoningValidator implements ChallengeTypeValidator {

    private static final int REQUIRED_STEPS = 5;
    private static final int FIRST_STEP_ORDER = 0;

    @Override
    public List<String> validate(ImportedQuestion question) {
        List<String> problems = new ArrayList<>(selectionTypeProblems(question, SelectionType.SINGLE_CHOICE));
        problems.addAll(scenarioForbiddenProblems(question));
        List<ImportedOption> options = question.options() == null ? List.of() : question.options();
        if (options.size() != REQUIRED_STEPS) {
            problems.add("Un défi de raisonnement séquentiel doit contenir exactement "
                    + REQUIRED_STEPS + " étapes.");
            return problems;
        }
        if (options.stream().anyMatch(option -> !option.correct())) {
            problems.add("Toutes les étapes d'un raisonnement séquentiel doivent être correctes.");
        }
        List<Integer> orders = options.stream()
                .map(ImportedOption::displayOrder)
                .sorted()
                .toList();
        List<Integer> expected = IntStream.range(FIRST_STEP_ORDER, options.size()).boxed().toList();
        if (!orders.equals(expected)) {
            problems.add("Les positions des étapes doivent couvrir exactement "
                    + FIRST_STEP_ORDER + " à " + (options.size() - 1) + ".");
        }
        return problems;
    }
}
