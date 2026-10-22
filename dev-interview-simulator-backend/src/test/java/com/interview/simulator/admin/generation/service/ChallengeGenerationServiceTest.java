package com.interview.simulator.admin.generation.service;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.ExecutedCounts;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.PlannedCounts;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.admin.challenge.service.ChallengeImportService;
import com.interview.simulator.admin.generation.dto.ChallengeGenerationRequest;
import com.interview.simulator.admin.generation.provider.GenerationProviderRegistry;
import com.interview.simulator.admin.generation.provider.LLMGenerationProvider;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChallengeGenerationServiceTest {

    private static final String VALID_ANSWER = """
            {"questions":[
              {"title":"T1","type":"SITUATIONAL_QCM","difficulty":"JUNIOR",
               "selectionType":"SINGLE_CHOICE","context":"Une situation de test.","question":"Q1 ?",
               "explanation":"e1","estimatedTimeSeconds":90,"points":10,
               "categories":["Java"],"skills":["Spring"],
               "options":[{"content":"a","correct":false,"displayOrder":0},
                          {"content":"b","correct":true,"displayOrder":1},
                          {"content":"c","correct":false,"displayOrder":2},
                          {"content":"d","correct":false,"displayOrder":3}]}
            ]}
            """;

    @Captor
    private ArgumentCaptor<List<ImportedQuestion>> questionsCaptor;

    @Captor
    private ArgumentCaptor<String> promptCaptor;

    @Mock
    private LLMGenerationProvider geminiGenerationClient;

    @Mock
    private GenerationProviderRegistry generationProviderRegistry;

    @Mock
    private ChallengeImportService challengeImportService;

    @Mock
    private ChallengeIdentityService challengeIdentityService;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private SkillRepository skillRepository;

    @Mock
    private ProfileRepository profileRepository;

    private ChallengeGenerationService challengeGenerationService;

    @BeforeEach
    void setUp() {
        ObjectMapper objectMapper = new ObjectMapper()
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        when(generationProviderRegistry.resolve(any(), any()))
                .thenReturn(new GenerationProviderRegistry.Resolved(geminiGenerationClient, null));
        challengeGenerationService = new ChallengeGenerationService(
                geminiGenerationClient,
                challengeImportService,
                challengeIdentityService,
                categoryRepository,
                skillRepository,
                profileRepository,
                objectMapper,
                generationProviderRegistry);
    }

    @Test
    void generate_ShouldFailWhenGenerationIsNotConfigured() {
        when(geminiGenerationClient.isConfigured()).thenReturn(false);

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(1, null, null, null)));

        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, exception.getStatus());
        verifyNoInteractions(challengeImportService, categoryRepository, skillRepository, profileRepository);
    }

    @Test
    void generate_ShouldRejectUnknownCategoryBeforeCallingProvider() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        when(categoryRepository.findAllById(Set.of(5L))).thenReturn(List.of());

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(1, Set.of(5L), null, null)));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatus());
        assertTrue(exception.getMessage().contains("5"));
        verify(geminiGenerationClient, never()).generateText(anyString());
    }

    @Test
    void generate_ShouldRejectInactiveProfileBeforeCallingProvider() {
        Profile inactive = new Profile("INACTIF", "Inactif", null);
        inactive.setActive(false);
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        when(profileRepository.findAllById(Set.of(3L))).thenReturn(List.of(inactive));

        when(categoryRepository.findAllById(Set.of(1L))).thenReturn(List.of(new Category("Java", null)));
        when(skillRepository.findAllById(Set.of(2L))).thenReturn(List.of(new Skill("Spring", null)));
        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(1, null, null, Set.of(3L))));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatus());
        assertTrue(exception.getMessage().contains("INACTIF"));
        verify(geminiGenerationClient, never()).generateText(anyString());
    }

    @Test
    void generate_ShouldRejectMissingCategoryOrSkillBeforeCallingProvider() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);

        when(skillRepository.findAllById(Set.of(2L))).thenReturn(List.of(new Skill("Spring", null)));
        when(profileRepository.findAllById(Set.of(3L)))
                .thenReturn(List.of(new Profile("DEVELOPER", "Développeur", null)));
        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(1, Set.of(), Set.of(2L), Set.of(3L))));

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatus());
        assertTrue(exception.getMessage().contains("catégorie"));
        verify(geminiGenerationClient, never()).generateText(anyString());
    }

    @Test
    void generate_ShouldRejectWrongQuestionCountWithoutImporting() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString())).thenReturn(VALID_ANSWER);

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(2, null, null, null)));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        assertTrue(exception.getMessage().contains("exactement 2 questions"));
        verifyNoInteractions(challengeImportService);
    }

    @Test
    void generate_ShouldRejectMalformedProviderJsonWithoutImporting() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString())).thenReturn("{tronqué");

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(2, null, null, null)));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        verifyNoInteractions(challengeImportService);
    }

    @Test
    void generate_ShouldDelegateToImportWithDraftAndServerSideIdentity() {
        Category category = new Category("Java", null);
        Skill skill = new Skill("Spring", null);
        Profile profile = new Profile("DEVELOPER", "Développeur", null);
        ChallengeImportReport report = report();
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        when(categoryRepository.findAllById(Set.of(1L))).thenReturn(List.of(category));
        when(skillRepository.findAllById(Set.of(2L))).thenReturn(List.of(skill));
        when(profileRepository.findAllById(Set.of(3L))).thenReturn(List.of(profile));
        when(geminiGenerationClient.generateText(anyString())).thenReturn(VALID_ANSWER);
        when(challengeIdentityService.generateExternalId()).thenReturn("admin-généré");
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report);

        ChallengeImportReport result = challengeGenerationService.generate(
                request(1, Set.of(1L), Set.of(2L), Set.of(3L)));

        assertSame(report, result);
        verify(challengeImportService).importQuestions(questionsCaptor.capture(), eq(ContentStatus.DRAFT), eq(false));
        List<ImportedQuestion> questions = questionsCaptor.getValue();
        assertEquals(1, questions.size());
        ImportedQuestion question = questions.get(0);
        assertEquals("admin-généré", question.externalId());
        assertEquals(ChallengeType.SITUATIONAL_QCM, question.type());
        assertEquals(DifficultyLevel.JUNIOR, question.difficulty());
        assertEquals(70, question.estimatedTimeSeconds());
        assertEquals(Set.of("Java"), question.categories());
        assertEquals(Set.of("Spring"), question.skills());
        assertEquals(Set.of("DEVELOPER"), question.profiles());
    }

    @Test
    void generate_DecritLesCompetancesEtAppliqueLaRegleFundamentals() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        when(categoryRepository.findAllById(Set.of(1L)))
                .thenReturn(List.of(new Category("Java", null)));
        Skill fundamentals = mockSkill("Fundamentals", "Maîtrise des concepts de base et de la théorie");
        Skill testsUnitaires = mockSkill("Tests unitaires", "Conception de tests : stratégie, cas limites, mocking, TDD");
        when(skillRepository.findAllById(Set.of(2L, 3L))).thenReturn(List.of(fundamentals, testsUnitaires));
        when(profileRepository.findAllById(Set.of(3L)))
                .thenReturn(List.of(new Profile("DEVELOPER", "Développeur", null)));
        when(geminiGenerationClient.generateText(anyString())).thenReturn(
                VALID_ANSWER.replace("Spring", "Tests unitaires"));
        when(challengeIdentityService.generateExternalId()).thenReturn("admin-généré");
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report());

        challengeGenerationService.generate(request(1, Set.of(1L), Set.of(2L, 3L), Set.of(3L)));

        verify(geminiGenerationClient).generateText(promptCaptor.capture());
        String prompt = promptCaptor.getValue();
        assertTrue(prompt.contains("Compétences autorisées (choisis les pertinentes et recopie les noms exacts dans « skills »)"));
        assertTrue(prompt.contains("- Fundamentals — Maîtrise des concepts de base et de la théorie"));
        assertTrue(prompt.contains("- Tests unitaires — Conception de tests : stratégie, cas limites, mocking, TDD"));
        assertTrue(prompt.contains(
                "Règle Fundamentals : question de connaissance ou de théorie sans scénario à diagnostiquer"));
    }

    @Test
    void generate_PasDeRegleFundamentals_SansLeSkillFundamentals() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        when(categoryRepository.findAllById(Set.of(1L)))
                .thenReturn(List.of(new Category("Java", null)));
        when(skillRepository.findAllById(Set.of(2L)))
                .thenReturn(List.of(new Skill("Spring", "Framework applicatif Java")));
        when(profileRepository.findAllById(Set.of(3L)))
                .thenReturn(List.of(new Profile("DEVELOPER", "Développeur", null)));
        when(geminiGenerationClient.generateText(anyString())).thenReturn(VALID_ANSWER);
        when(challengeIdentityService.generateExternalId()).thenReturn("admin-généré");
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report());

        challengeGenerationService.generate(request(1, null, Set.of(2L), null));

        verify(geminiGenerationClient).generateText(promptCaptor.capture());
        String prompt = promptCaptor.getValue();
        assertTrue(prompt.contains("- Spring — Framework applicatif Java"));
        assertFalse(prompt.contains("Règle Fundamentals"));
    }

    @Test
    void generate_ShouldPropagateProviderQuotaError() {
        ApiException quota = new ApiException(HttpStatus.TOO_MANY_REQUESTS, "Quota épuisé.");
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString())).thenThrow(quota);

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(2, null, null, null)));

        assertSame(quota, exception);
        verifyNoInteractions(challengeImportService);
    }

    private ChallengeGenerationRequest request(
            int count,
            Set<Long> categoryIds,
            Set<Long> skillIds,
            Set<Long> profileIds) {
        return new ChallengeGenerationRequest(
                profileIds == null ? Set.of(3L) : profileIds,
                categoryIds == null ? Set.of(1L) : categoryIds,
                skillIds == null ? Set.of(2L) : skillIds,
                DifficultyLevel.JUNIOR, ChallengeType.SITUATIONAL_QCM, count, null, null, null);
    }

    private void stubDefaultTaxonomy() {
        when(categoryRepository.findAllById(Set.of(1L)))
                .thenReturn(List.of(new Category("Java", null)));
        when(skillRepository.findAllById(Set.of(2L)))
                .thenReturn(List.of(new Skill("Spring", null)));
        when(profileRepository.findAllById(Set.of(3L)))
                .thenReturn(List.of(new Profile("DEVELOPER", "Développeur", null)));
    }

    private Skill mockSkill(String name, String description) {
        Skill skill = mock(Skill.class);
        when(skill.getName()).thenReturn(name);
        when(skill.getDescription()).thenReturn(description);
        return skill;
    }

    private ChallengeImportReport report() {
        return new ChallengeImportReport(
                false,
                new PlannedCounts(1, 0),
                new ExecutedCounts(1, 0),
                List.of(), List.of(), List.of());
    }
}
