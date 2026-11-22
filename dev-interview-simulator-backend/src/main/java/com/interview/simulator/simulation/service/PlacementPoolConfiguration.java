package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;

@Component
public class PlacementPoolConfiguration {

    private static final String JAVA = "Java";
    private static final String SPRING_BOOT = "Spring Boot";

    private static final Set<String> JAVA_CATEGORIES = Set.of(JAVA);
    private static final Set<String> SPRING_BOOT_CATEGORIES = Set.of(SPRING_BOOT);
    private static final Set<String> JAVA_OR_SPRING_BOOT_CATEGORIES = Set.of(JAVA, SPRING_BOOT);

    public static final Set<String> ALLOWED_CATEGORIES = JAVA_OR_SPRING_BOOT_CATEGORIES;

    public record PlacementPosition(
            DifficultyLevel difficulty,
            ChallengeType type,
            Set<String> categories) {}

    public static final List<PlacementPosition> POSITIONS = List.of(
        new PlacementPosition(
            DifficultyLevel.JUNIOR, ChallengeType.SITUATIONAL_QCM, JAVA_CATEGORIES),
        new PlacementPosition(
            DifficultyLevel.JUNIOR, ChallengeType.SITUATIONAL_QCM, SPRING_BOOT_CATEGORIES),
        new PlacementPosition(
            DifficultyLevel.INTERMEDIATE, ChallengeType.SITUATIONAL_QCM, JAVA_CATEGORIES),
        new PlacementPosition(
            DifficultyLevel.INTERMEDIATE, ChallengeType.CODE_REVIEW, SPRING_BOOT_CATEGORIES),
        new PlacementPosition(
            DifficultyLevel.INTERMEDIATE, ChallengeType.SITUATIONAL_QCM, JAVA_OR_SPRING_BOOT_CATEGORIES),
        new PlacementPosition(
            DifficultyLevel.ADVANCED, ChallengeType.SITUATIONAL_QCM, JAVA_OR_SPRING_BOOT_CATEGORIES)
    );
}
