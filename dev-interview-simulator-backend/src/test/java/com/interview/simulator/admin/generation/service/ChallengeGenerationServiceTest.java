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
import com.interview.simulator.admin.generation.provider.OpenRouterGenerationProvider;
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
                generationProviderRegistry,
                2);
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
    void generate_ShouldReturnClearServiceUnavailableForUnconfiguredOpenRouter() {
        OpenRouterGenerationProvider openRouter = mock(OpenRouterGenerationProvider.class);
        when(openRouter.isConfigured()).thenReturn(false);
        when(generationProviderRegistry.resolve("openrouter", null))
                .thenReturn(new GenerationProviderRegistry.Resolved(openRouter, null));

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(new ChallengeGenerationRequest(
                        Set.of(3L), Set.of(1L), Set.of(2L), DifficultyLevel.JUNIOR,
                        ChallengeType.SITUATIONAL_QCM, 1, null, null, "openrouter", null)));

        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, exception.getStatus());
        assertTrue(exception.getMessage().contains("OPENROUTER_API_KEY"));
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
    void generate_ShouldKeepFirstRequestedQuestionsAndWarnWhenTooMany() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString())).thenReturn(answerWithQuestions(3));
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report(2, 0));

        ChallengeImportReport result = challengeGenerationService.generate(request(2, null, null, null));

        verify(challengeImportService).importQuestions(questionsCaptor.capture(), eq(ContentStatus.DRAFT), eq(false));
        assertEquals(2, questionsCaptor.getValue().size());
        assertTrue(result.warnings().stream().anyMatch(warning ->
                warning.message().contains("3 questions") && warning.message().contains("2 réellement créées")));
        verify(geminiGenerationClient).generateText(anyString());
    }

    @Test
    void generate_ShouldImportFewerQuestionsAndReportRequestedAndCreatedCounts() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString())).thenReturn(answerWithQuestions(4));
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report(4, 0));

        ChallengeImportReport result = challengeGenerationService.generate(request(5, null, null, null));

        verify(geminiGenerationClient).generateText(anyString());
        verify(challengeImportService).importQuestions(questionsCaptor.capture(), eq(ContentStatus.DRAFT), eq(false));
        assertEquals(4, questionsCaptor.getValue().size());
        assertTrue(result.warnings().stream().anyMatch(warning ->
                warning.message().contains("5 demandées") && warning.message().contains("4 réellement créées")));
    }

    @Test
    void generate_ShouldRetryMalformedJsonThenImportValidQuestions() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString())).thenReturn("{tronqué", VALID_ANSWER);
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report());

        challengeGenerationService.generate(request(1, null, null, null));

        verify(geminiGenerationClient, org.mockito.Mockito.times(2)).generateText(anyString());
        verify(challengeImportService).importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false));
    }

    @Test
    void generate_ShouldRetryWhenEveryQuestionIsInvalidAndFailAfterConfiguredAttempts() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString())).thenReturn(VALID_ANSWER);
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report(0, 1), report(0, 1), report(0, 1));

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(1, null, null, null)));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        assertTrue(exception.getMessage().contains("aucune question exploitable"));
        verify(geminiGenerationClient, org.mockito.Mockito.times(3)).generateText(anyString());
        verify(challengeImportService, org.mockito.Mockito.times(3))
                .importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false));
    }

    @Test
    void generate_ShouldRejectMalformedProviderJsonWithoutImporting() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        stubDefaultTaxonomy();
        when(geminiGenerationClient.generateText(anyString()))
                .thenReturn("{tronqué", "{tronqué", "{tronqué");

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(request(2, null, null, null)));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        verify(geminiGenerationClient, org.mockito.Mockito.times(3)).generateText(anyString());
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

        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.VALIDATED), eq(false)))
                .thenReturn(report);
        challengeGenerationService.generate(request(1, Set.of(1L), Set.of(2L), Set.of(3L), ContentStatus.VALIDATED));
        verify(challengeImportService).importQuestions(anyList(), eq(ContentStatus.VALIDATED), eq(false));
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
        assertTrue(prompt.contains("Compétences autorisées (recopie dans « skills » le ou les noms pertinents exactement comme écrits avant « — » ; n'inclus pas leur description) :"));
        assertTrue(prompt.contains("- Fundamentals — Maîtrise des concepts de base et de la théorie"));
        assertTrue(prompt.contains("- Tests unitaires — Conception de tests : stratégie, cas limites, mocking, TDD"));
        assertTrue(prompt.contains("Recopie chaque nom autorisé à l'identique, caractère par caractère"));
        assertTrue(prompt.contains("n'inclus pas leur description"));
        assertTrue(prompt.contains(
                "Règle Fundamentals : question de connaissance ou de théorie sans scénario à diagnostiquer"));
    }

    @Test
    void generate_ForceLaTaxonomieSelectionneeQuandUnSeulNomEstChoisi() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        when(categoryRepository.findAllById(Set.of(1L)))
                .thenReturn(List.of(new Category("Java", null)));
        when(skillRepository.findAllById(Set.of(2L)))
                .thenReturn(List.of(new Skill("Spring", null)));
        when(profileRepository.findAllById(Set.of(3L)))
                .thenReturn(List.of(new Profile("DEVELOPER", "Développeur", null)));
        when(geminiGenerationClient.generateText(anyString())).thenReturn(
                VALID_ANSWER.replace("Java", "JavaScript").replace("Spring", "React"));
        when(challengeIdentityService.generateExternalId()).thenReturn("admin-généré");
        when(challengeImportService.importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false)))
                .thenReturn(report());

        ChallengeImportReport result = challengeGenerationService.generate(
                request(1, Set.of(1L), Set.of(2L), Set.of(3L)));

        verify(challengeImportService).importQuestions(questionsCaptor.capture(), eq(ContentStatus.DRAFT), eq(false));
        assertEquals(Set.of("Java"), questionsCaptor.getValue().get(0).categories());
        assertEquals(Set.of("Spring"), questionsCaptor.getValue().get(0).skills());
        assertTrue(result.warnings().stream().anyMatch(warning ->
                warning.message().contains("catégorie et compétence") && warning.message().contains("remplacée(s)")));
        verify(geminiGenerationClient).generateText(anyString());
    }

    @Test
    void generate_ConserveLaValidationQuandPlusieursTaxonomiesSontSelectionnees() {
        when(geminiGenerationClient.isConfigured()).thenReturn(true);
        Category java = mock(Category.class);
        when(java.getName()).thenReturn("Java");
        Category sql = mock(Category.class);
        when(sql.getName()).thenReturn("SQL");
        when(categoryRepository.findAllById(Set.of(1L, 4L))).thenReturn(List.of(java, sql));

        Skill spring = mock(Skill.class);
        when(spring.getName()).thenReturn("Spring");
        when(spring.getDescription()).thenReturn(null);
        Skill hibernate = mock(Skill.class);
        when(hibernate.getName()).thenReturn("Hibernate");
        when(hibernate.getDescription()).thenReturn(null);
        when(skillRepository.findAllById(Set.of(2L, 5L))).thenReturn(List.of(spring, hibernate));
        when(profileRepository.findAllById(Set.of(3L)))
                .thenReturn(List.of(new Profile("DEVELOPER", "Développeur", null)));
        when(geminiGenerationClient.generateText(anyString())).thenReturn(
                "{\"questions\":[{\"categories\":[\"Python\"],\"skills\":[\"Spring\"]}]}");

        ApiException exception = assertThrows(ApiException.class,
                () -> challengeGenerationService.generate(
                        request(1, Set.of(1L, 4L), Set.of(2L, 5L), Set.of(3L))));

        assertEquals(HttpStatus.BAD_GATEWAY, exception.getStatus());
        verify(challengeImportService, never())
                .importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false));
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
        return request(count, categoryIds, skillIds, profileIds, null);
    }

    private ChallengeGenerationRequest request(
            int count,
            Set<Long> categoryIds,
            Set<Long> skillIds,
            Set<Long> profileIds,
            ContentStatus status) {
        return new ChallengeGenerationRequest(
                profileIds == null ? Set.of(3L) : profileIds,
                categoryIds == null ? Set.of(1L) : categoryIds,
                skillIds == null ? Set.of(2L) : skillIds,
                DifficultyLevel.JUNIOR, ChallengeType.SITUATIONAL_QCM, count, null, status, null, null);
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

    private String answerWithQuestions(int count) {
        String question = VALID_ANSWER.substring(VALID_ANSWER.indexOf('[') + 1, VALID_ANSWER.lastIndexOf(']')).trim();
        return "{\"questions\":[" + String.join(",", java.util.Collections.nCopies(count, question)) + "]}";
    }

    private ChallengeImportReport report() {
        return report(1, 0);
    }

    private ChallengeImportReport report(int createdCount, int errorCount) {
        List<ChallengeImportReport.ImportError> errors = java.util.stream.IntStream.range(0, errorCount)
                .mapToObj(index -> new ChallengeImportReport.ImportError(index, "T" + index, "Invalide"))
                .toList();
        return new ChallengeImportReport(
                false,
                new PlannedCounts(createdCount, 0),
                new ExecutedCounts(createdCount, 0),
                List.of(), errors, List.of());
    }
}
