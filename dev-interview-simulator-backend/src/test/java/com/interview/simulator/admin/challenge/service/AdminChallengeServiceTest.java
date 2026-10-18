package com.interview.simulator.admin.challenge.service;

import com.interview.simulator.admin.challenge.dto.AdminChallengeOptionRequest;
import com.interview.simulator.admin.challenge.dto.AdminChallengeRequest;
import com.interview.simulator.admin.challenge.dto.AdminChallengeResponse;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.SelectionType;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AdminChallengeServiceTest {

    @Mock
    private ChallengeRepository challengeRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private SkillRepository skillRepository;

    @Mock
    private ProfileRepository profileRepository;

    @Mock
    private InterviewScenarioRepository interviewScenarioRepository;

    @Mock
    private ChallengeIdentityService challengeIdentityService;

    @Mock
    private TransactionTemplate transactionTemplate;

    @InjectMocks
    private AdminChallengeService adminChallengeService;

    @Test
    void create_ShouldThrowConflictWhenContentHashAlreadyExists() {
        Challenge existing = challengeWithId(42L, "Question existante");
        when(challengeIdentityService.contentHash(any(Challenge.class))).thenReturn("hash-partage");
        when(challengeRepository.findByContentHash("hash-partage")).thenReturn(List.of(existing));

        ApiException exception = assertThrows(ApiException.class,
                () -> adminChallengeService.create(request()));

        assertEquals(HttpStatus.CONFLICT, exception.getStatus());
        assertTrue(exception.getMessage().contains("42"));
        assertTrue(exception.getMessage().contains("Question existante"));
        verify(challengeRepository, never()).save(any(Challenge.class));
    }

    @Test
    void update_ShouldSucceedWhenContentHashBelongsToItself() {
        Challenge existing = challengeWithId(7L, "Question modifiée");
        when(challengeRepository.findById(7L)).thenReturn(Optional.of(existing));
        when(challengeIdentityService.contentHash(any(Challenge.class))).thenReturn("hash-de-soi");
        when(challengeRepository.findByContentHash("hash-de-soi")).thenReturn(List.of(existing));
        when(challengeRepository.save(existing)).thenReturn(existing);

        AdminChallengeResponse response = adminChallengeService.update(7L, request());

        assertNotNull(response);
        assertEquals(7L, response.id());
        assertEquals("hash-de-soi", existing.getContentHash());
        verify(challengeRepository, times(1)).save(existing);
    }

    @Test
    void update_ShouldThrowConflictWhenContentHashBelongsToAnotherChallenge() {
        Challenge existing = challengeWithId(7L, "Question modifiée");
        Challenge other = challengeWithId(42L, "Autre question");
        when(challengeRepository.findById(7L)).thenReturn(Optional.of(existing));
        when(challengeIdentityService.contentHash(any(Challenge.class))).thenReturn("hash-dun-autre");
        when(challengeRepository.findByContentHash("hash-dun-autre")).thenReturn(List.of(other));

        ApiException exception = assertThrows(ApiException.class,
                () -> adminChallengeService.update(7L, request()));

        assertEquals(HttpStatus.CONFLICT, exception.getStatus());
        assertTrue(exception.getMessage().contains("42"));
        verify(challengeRepository, never()).save(any(Challenge.class));
    }

    @Test
    void changeStatus_FromDraftWithoutSkill_ToValidated_ShouldThrowBadRequest() {
        Challenge existing = challengeWithId(5L, "Brouillon sans compétence");
        existing.getCategories().add(new Category("Java", "description"));
        when(challengeRepository.findById(5L)).thenReturn(Optional.of(existing));

        ApiException exception = assertThrows(ApiException.class,
                () -> adminChallengeService.changeStatus(5L, ContentStatus.VALIDATED));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatus());
        assertTrue(exception.getMessage().contains("compétence"));
        assertTrue(exception.getMessage().contains("VALIDATED"));
        assertEquals(ContentStatus.DRAFT, existing.getStatus());
        verify(challengeRepository, never()).save(any(Challenge.class));
    }

    @Test
    void changeStatus_ToValidatedWithCategoryAndSkill_ShouldSucceed() {
        Challenge existing = challengeWithId(6L, "Brouillon complet");
        existing.getCategories().add(new Category("Java", "description"));
        existing.getSkills().add(new Skill("Problem Solving", "description"));
        when(challengeRepository.findById(6L)).thenReturn(Optional.of(existing));
        when(challengeRepository.save(existing)).thenReturn(existing);

        AdminChallengeResponse response = adminChallengeService.changeStatus(6L, ContentStatus.VALIDATED);

        assertEquals(ContentStatus.VALIDATED, response.status());
        verify(challengeRepository, times(1)).save(existing);
    }

    @Test
    void update_ValidatedQuestion_RemovingAllCategoriesAndSkills_ShouldThrowAndNotSave() {
        Challenge existing = challengeWithId(8L, "Question VALIDATED complète");
        existing.setStatus(ContentStatus.VALIDATED);
        existing.getCategories().add(new Category("Java", "description"));
        existing.getSkills().add(new Skill("Problem Solving", "description"));
        when(challengeRepository.findById(8L)).thenReturn(Optional.of(existing));
        when(challengeIdentityService.contentHash(any(Challenge.class))).thenReturn("hash-apres-retrait");
        when(challengeRepository.findByContentHash("hash-apres-retrait")).thenReturn(List.of());

        ApiException exception = assertThrows(ApiException.class,
                () -> adminChallengeService.update(8L, request()));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatus());
        assertTrue(exception.getMessage().contains("catégorie"));
        assertTrue(exception.getMessage().contains("compétence"));
        verify(challengeRepository, never()).save(any(Challenge.class));
    }

    @Test
    void create_DraftWithoutCategoryAndSkill_ShouldSucceed() {
        when(challengeIdentityService.contentHash(any(Challenge.class))).thenReturn("hash-brouillon");
        when(challengeRepository.findByContentHash("hash-brouillon")).thenReturn(List.of());
        when(challengeRepository.save(any(Challenge.class))).thenAnswer(invocation -> invocation.getArgument(0));

        AdminChallengeResponse response = adminChallengeService.create(request());

        assertEquals(ContentStatus.DRAFT, response.status());
        verify(challengeRepository, times(1)).save(any(Challenge.class));
    }

    private Challenge challengeWithId(Long id, String title) {
        Challenge challenge = new Challenge();
        ReflectionTestUtils.setField(challenge, "id", id);
        challenge.setTitle(title);
        challenge.setType(ChallengeType.SITUATIONAL_QCM);
        challenge.setDifficulty(DifficultyLevel.JUNIOR);
        challenge.setSelectionType(SelectionType.SINGLE_CHOICE);
        challenge.setQuestion("Question ?");
        challenge.setStatus(ContentStatus.DRAFT);
        return challenge;
    }

    private AdminChallengeRequest request() {
        AdminChallengeOptionRequest correct = new AdminChallengeOptionRequest(
                null, "Bonne réponse", true, null, null, 0);
        AdminChallengeOptionRequest wrong = new AdminChallengeOptionRequest(
                null, "Mauvaise réponse", false, null, null, 1);
        return new AdminChallengeRequest(
                "Titre importé",
                ChallengeType.SITUATIONAL_QCM,
                DifficultyLevel.JUNIOR,
                SelectionType.SINGLE_CHOICE,
                "Contexte",
                "Question ?",
                null,
                null,
                null,
                null,
                null,
                null,
                "Explication",
                90,
                10,
                Set.of(),
                Set.of(),
                Set.of(),
                List.of(correct, wrong));
    }
}
