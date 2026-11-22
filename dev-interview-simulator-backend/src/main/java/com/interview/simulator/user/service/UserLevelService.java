package com.interview.simulator.user.service;

import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.dto.UserLevelResponse;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * Niveau d'utilisateur stocké : il monte quand assez de questions d'un niveau
 * sont réussies, et ne baisse jamais.
 */
@Service
public class UserLevelService {

    private static final Logger LOGGER = LoggerFactory.getLogger(UserLevelService.class);

    /** Règle de montée de niveau, regroupée ici volontairement. */
    static final int WINDOW_SIZE = 20;
    static final int REQUIRED_SUCCESS_RATE = 75;

    private static final List<DifficultyLevel> LEVEL_ORDER =
            List.of(DifficultyLevel.JUNIOR, DifficultyLevel.INTERMEDIATE, DifficultyLevel.ADVANCED);

    private final SimulationRepository simulationRepository;
    private final UserRepository userRepository;
    private final UserResolver userResolver;

    public UserLevelService(SimulationRepository simulationRepository,
                            UserRepository userRepository,
                            UserResolver userResolver) {
        this.simulationRepository = simulationRepository;
        this.userRepository = userRepository;
        this.userResolver = userResolver;
    }

    /** Avancement vers le niveau suivant (null si le niveau le plus haut est atteint). */
    public record LevelProgress(
            DifficultyLevel currentLevel,
            DifficultyLevel nextLevel,
            int answeredCount,
            int successRatePercent
    ) {
    }

    /**
     * État d'avancement de l'utilisateur pour le niveau visé (le suivant tant
     * qu'il n'est pas Senior).
     */
    public LevelProgress describeProgress(User user) {
        DifficultyLevel currentLevel = storedLevel(user);
        DifficultyLevel nextLevel = nextLevelOf(currentLevel);
        List<Boolean> window = nextLevel == null
                ? List.of()
                : simulationRepository.findRecentAnswerCorrectness(
                        user.getId(), nextLevel.name(), WINDOW_SIZE);
        return new LevelProgress(currentLevel, nextLevel, window.size(), successRate(window));
    }

    /** État de progression de l'utilisateur connecté (endpoint /api/user/level). */
    @Transactional(readOnly = true)
    public UserLevelResponse getCurrentProgress() {
        User user = userResolver.currentAuthenticatedOrNull()
                .orElseThrow(() -> new ApiException(
                        HttpStatus.UNAUTHORIZED,
                        "Authentification requise pour consulter ton niveau."));
        LevelProgress progress = describeProgress(user);
        return new UserLevelResponse(
                progress.currentLevel().name(),
                progress.nextLevel() != null ? progress.nextLevel().name() : null,
                progress.answeredCount(),
                WINDOW_SIZE,
                progress.successRatePercent(),
                REQUIRED_SUCCESS_RATE);
    }

    /**
     * Met à jour le niveau stocké uniquement s'il monte. « Au mieux » : toute
     * erreur est journalisée et n'interrompt jamais l'appelant.
     */
    public void updateStoredLevel(User user) {
        if (user == null || user.getId() == null) {
            return;
        }
        try {
            Map<DifficultyLevel, List<Boolean>> windows = new EnumMap<>(DifficultyLevel.class);
            for (DifficultyLevel level : LEVEL_ORDER) {
                windows.put(level, simulationRepository.findRecentAnswerCorrectness(
                        user.getId(), level.name(), WINDOW_SIZE));
            }
            DifficultyLevel currentLevel = storedLevel(user);
            DifficultyLevel target = highestOf(currentLevel, levelFromWindows(windows));
            if (!target.equals(currentLevel)) {
                user.setLevel(target);
                userRepository.save(user);
            }
        } catch (RuntimeException exception) {
            LOGGER.warn("Mise à jour du niveau impossible pour l'utilisateur {}.", user.getId(), exception);
        }
    }

    /** Un niveau est validé avec une fenêtre pleine et au moins 75 % de réussite. */
    static boolean isLevelValidated(List<Boolean> recentAnswers) {
        if (recentAnswers == null || recentAnswers.size() < WINDOW_SIZE) {
            return false;
        }
        long correct = recentAnswers.stream().filter(Boolean.TRUE::equals).count();
        return correct * 100 >= (long) REQUIRED_SUCCESS_RATE * recentAnswers.size();
    }

    /**
     * Niveau atteint à partir des fenêtres de réponses : le suivant du plus haut
     * niveau validé, plafonné au dernier niveau ; JUNIOR si aucun n'est validé.
     * Un niveau supérieur validé rend les niveaux inférieurs validés.
     */
    static DifficultyLevel levelFromWindows(Map<DifficultyLevel, List<Boolean>> windows) {
        int highestValidated = -1;
        for (int index = 0; index < LEVEL_ORDER.size(); index++) {
            if (isLevelValidated(windows.get(LEVEL_ORDER.get(index)))) {
                highestValidated = index;
            }
        }
        if (highestValidated < 0) {
            return DifficultyLevel.JUNIOR;
        }
        return LEVEL_ORDER.get(Math.min(highestValidated + 1, LEVEL_ORDER.size() - 1));
    }

    /** Le niveau ne baisse jamais : on garde le plus haut des deux. */
    static DifficultyLevel highestOf(DifficultyLevel current, DifficultyLevel candidate) {
        return LEVEL_ORDER.indexOf(candidate) > LEVEL_ORDER.indexOf(current) ? candidate : current;
    }

    static DifficultyLevel nextLevelOf(DifficultyLevel level) {
        int index = LEVEL_ORDER.indexOf(level);
        return index < 0 || index + 1 >= LEVEL_ORDER.size() ? null : LEVEL_ORDER.get(index + 1);
    }

    static DifficultyLevel storedLevel(User user) {
        return user.getLevel() == null ? DifficultyLevel.JUNIOR : user.getLevel();
    }

    private static int successRate(List<Boolean> recentAnswers) {
        if (recentAnswers.isEmpty()) {
            return 0;
        }
        long correct = recentAnswers.stream().filter(Boolean.TRUE::equals).count();
        return (int) Math.round(correct * 100.0 / recentAnswers.size());
    }
}
