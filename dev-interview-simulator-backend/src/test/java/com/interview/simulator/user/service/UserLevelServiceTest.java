package com.interview.simulator.user.service;

import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.dto.UserLevelResponse;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserLevelServiceTest {

    @Mock private SimulationRepository simulationRepository;
    @Mock private UserRepository userRepository;
    @Mock private UserResolver userResolver;

    @InjectMocks private UserLevelService userLevelService;

    // ---- isLevelValidated ----

    @Test
    void fewerThanTwentyJuniorAnswersKeepJunior() {
        assertFalse(UserLevelService.isLevelValidated(window(14, 19)));
        assertFalse(UserLevelService.isLevelValidated(List.of()));
        assertEquals(DifficultyLevel.JUNIOR,
                UserLevelService.levelFromWindows(Map.of(DifficultyLevel.JUNIOR, window(14, 19))));
    }

    @Test
    void exactlySeventyFivePercentValidates() {
        assertTrue(UserLevelService.isLevelValidated(window(15, 20)));
    }

    @Test
    void seventyPercentDoesNotValidate() {
        assertFalse(UserLevelService.isLevelValidated(window(14, 20)));
        assertFalse(UserLevelService.isLevelValidated(window(20, 27)));
    }

    @Test
    void validatedJuniorMovesUserToIntermediate() {
        assertEquals(DifficultyLevel.INTERMEDIATE,
                UserLevelService.levelFromWindows(Map.of(DifficultyLevel.JUNIOR, window(15, 20))));
    }

    @Test
    void validatedIntermediateWithoutJuniorCountsLowerAsValidated() {
        Map<DifficultyLevel, List<Boolean>> windows = new java.util.EnumMap<>(DifficultyLevel.class);
        windows.put(DifficultyLevel.INTERMEDIATE, window(15, 20));
        assertEquals(DifficultyLevel.ADVANCED, UserLevelService.levelFromWindows(windows));
    }

    @Test
    void levelNeverGoesDown() {
        assertEquals(DifficultyLevel.INTERMEDIATE,
                UserLevelService.highestOf(DifficultyLevel.INTERMEDIATE, DifficultyLevel.JUNIOR));
        assertEquals(DifficultyLevel.INTERMEDIATE,
                UserLevelService.highestOf(DifficultyLevel.INTERMEDIATE, DifficultyLevel.INTERMEDIATE));
        assertEquals(DifficultyLevel.ADVANCED,
                UserLevelService.highestOf(DifficultyLevel.INTERMEDIATE, DifficultyLevel.ADVANCED));
    }

    @Test
    void validatedSeniorCapsAtSenior() {
        Map<DifficultyLevel, List<Boolean>> windows = new java.util.EnumMap<>(DifficultyLevel.class);
        windows.put(DifficultyLevel.ADVANCED, window(15, 20));
        assertEquals(DifficultyLevel.ADVANCED, UserLevelService.levelFromWindows(windows));
        assertNull(UserLevelService.nextLevelOf(DifficultyLevel.ADVANCED));
    }

    // ---- highestOf / nextLevelOf via updateStoredLevel ----

    @Test
    void failingAtHigherLevelKeepsCurrentLevel() {
        User user = mock(User.class);
        when(user.getLevel()).thenReturn(DifficultyLevel.INTERMEDIATE);
        when(simulationRepository.findRecentAnswerCorrectness(8L, "JUNIOR", 20))
                .thenReturn(List.of());
        when(simulationRepository.findRecentAnswerCorrectness(8L, "INTERMEDIATE", 20))
                .thenReturn(List.of());
        when(simulationRepository.findRecentAnswerCorrectness(8L, "ADVANCED", 20))
                .thenReturn(window(4, 20));

        userLevelService.updateStoredLevel(user);

        verify(user, never()).setLevel(any());
        verify(userRepository, never()).save(any());
    }

    // ---- getCurrentProgress / endpoint ----

    @Test
    void progressReturnsExpectedFieldsForAuthenticatedUser() {
        // Use lenient stubbing to avoid Mockito strictness argument mismatch
        lenient().when(simulationRepository.findRecentAnswerCorrectness(any(Long.class), any(String.class), any(int.class)))
                .thenReturn(window(9, 12));
        User user = mock(User.class);
        when(user.getLevel()).thenReturn(DifficultyLevel.JUNIOR);
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user));

        UserLevelResponse response = userLevelService.getCurrentProgress();

        assertEquals("JUNIOR", response.currentLevel());
        assertEquals("INTERMEDIATE", response.nextLevel());
        assertEquals(12, response.answeredCount());
        assertEquals(20, response.windowSize());
        assertEquals(75, response.successRatePercent());
        assertEquals(75, response.requiredSuccessRate());
    }

    @Test
    void progressRejectsUnauthenticatedCaller() {
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.empty());

        ApiException exception = assertThrows(ApiException.class, () -> userLevelService.getCurrentProgress());

        assertEquals(HttpStatus.UNAUTHORIZED, exception.getStatus());
    }

    // ---- helpers ----

    private static List<Boolean> window(int correct, int total) {
        List<Boolean> answers = new ArrayList<>();
        for (int index = 0; index < total; index++) {
            answers.add(index < correct);
        }
        return answers;
    }
}