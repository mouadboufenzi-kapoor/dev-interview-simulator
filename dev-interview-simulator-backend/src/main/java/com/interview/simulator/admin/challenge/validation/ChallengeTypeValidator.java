package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedOption;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.challenge.entity.SelectionType;

import java.util.ArrayList;
import java.util.List;

public interface ChallengeTypeValidator {

    List<String> validate(ImportedQuestion question);

    default List<String> selectionTypeProblems(ImportedQuestion question, SelectionType expected) {
        if (question.selectionType() != expected) {
            return List.of("Le type " + question.type() + " nécessite selectionType=" + expected + ".");
        }
        return List.of();
    }

    default List<String> selectionProblems(ImportedQuestion question) {
        List<ImportedOption> options = question.options() == null ? List.of() : question.options();
        long correctCount = options.stream().filter(ImportedOption::correct).count();
        if (question.selectionType() == SelectionType.SINGLE_CHOICE && correctCount != 1) {
            return List.of("Un contenu à sélection unique doit avoir exactement une bonne réponse.");
        }
        if (question.selectionType() == SelectionType.MULTIPLE_CHOICE && correctCount < 1) {
            return List.of("Un contenu à sélection multiple doit avoir au moins une bonne réponse.");
        }
        return List.of();
    }

    default List<String> optionCountProblems(ImportedQuestion question, int min, int max) {
        int count = question.options() == null ? 0 : question.options().size();
        if (count < min || count > max) {
            return List.of(min == max
                    ? "Le type " + question.type() + " nécessite exactement " + min + " options ; " + count + " reçue(s)."
                    : "Le type " + question.type() + " nécessite entre " + min + " et " + max + " options ; "
                            + count + " reçue(s).");
        }
        return List.of();
    }

    default List<String> scenarioForbiddenProblems(ImportedQuestion question) {
        List<String> problems = new ArrayList<>();
        if (!isBlank(question.scenario()) || question.stepOrder() != null) {
            problems.add("Seul un contenu de type ARCHITECTURE peut porter un scénario et un ordre d'étape.");
        }
        return problems;
    }

    static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
