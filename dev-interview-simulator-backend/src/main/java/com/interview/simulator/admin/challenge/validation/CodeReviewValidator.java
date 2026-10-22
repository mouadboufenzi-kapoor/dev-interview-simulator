package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.challenge.entity.OptionSeverity;
import com.interview.simulator.challenge.entity.SelectionType;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class CodeReviewValidator implements ChallengeTypeValidator {

    @Override
    public List<String> validate(ImportedQuestion question) {
        List<String> problems = new ArrayList<>(selectionTypeProblems(question, SelectionType.MULTIPLE_CHOICE));
        problems.addAll(selectionProblems(question));
        problems.addAll(optionCountProblems(question, 4, 6));
        if (question.codeSnippet() == null || question.codeSnippet().isBlank()) {
            problems.add("Un contenu CODE_REVIEW doit inclure un extrait de code.");
        }
        if (!"java".equalsIgnoreCase(question.codeLanguage())
                && !"typescript".equalsIgnoreCase(question.codeLanguage())) {
            problems.add("Le langage d'un extrait CODE_REVIEW doit être java ou typescript.");
        }
        if (question.codeSnippet() != null) {
            long lines = question.codeSnippet().lines().count();
            if (lines < 5 || lines > 20) {
                problems.add("Un extrait CODE_REVIEW doit contenir entre 5 et 20 lignes.");
            }
        }
        long correctCount = question.options() == null ? 0
                : question.options().stream().filter(option -> option.correct()).count();
        if (correctCount < 2) {
            problems.add("Un CODE_REVIEW doit comporter au moins deux constats corrects.");
        }
        if (question.options() != null && question.options().stream()
                .anyMatch(option -> option.severity() == null)) {
            problems.add("Chaque option CODE_REVIEW doit préciser une sévérité autorisée.");
        }
        problems.addAll(scenarioForbiddenProblems(question));
        return problems;
    }
}
