package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.exception.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class ChallengeTypeValidatorRegistry {

    private final Map<ChallengeType, ChallengeTypeValidator> validators;

    public ChallengeTypeValidatorRegistry(
            SituationalQcmValidator situationalQcmValidator,
            ProblemSolvingValidator problemSolvingValidator,
            CodeReviewValidator codeReviewValidator,
            ArchitectureValidator architectureValidator,
            SequentialReasoningValidator sequentialReasoningValidator) {
        this.validators = Map.ofEntries(
                Map.entry(ChallengeType.SITUATIONAL_QCM, situationalQcmValidator),
                Map.entry(ChallengeType.PROBLEM_SOLVING, problemSolvingValidator),
                Map.entry(ChallengeType.CODE_REVIEW, codeReviewValidator),
                Map.entry(ChallengeType.ARCHITECTURE, architectureValidator),
                Map.entry(ChallengeType.SEQUENTIAL_REASONING, sequentialReasoningValidator));
    }

    public ChallengeTypeValidator get(ChallengeType type) {
        ChallengeTypeValidator validator = validators.get(type);
        if (validator == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Type de challenge inconnu : " + type);
        }
        return validator;
    }
}
