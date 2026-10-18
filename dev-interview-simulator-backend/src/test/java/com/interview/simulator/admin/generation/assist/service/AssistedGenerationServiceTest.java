package com.interview.simulator.admin.generation.assist.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.challenge.repository.InterviewScenarioRepository;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.admin.challenge.service.ChallengeImportService;
import com.interview.simulator.admin.challenge.validation.ArchitectureValidator;
import com.interview.simulator.admin.challenge.validation.ChallengeTypeValidatorRegistry;
import com.interview.simulator.admin.challenge.validation.CodeReviewValidator;
import com.interview.simulator.admin.challenge.validation.ProblemSolvingValidator;
import com.interview.simulator.admin.challenge.validation.SequentialReasoningValidator;
import com.interview.simulator.admin.challenge.validation.SituationalQcmValidator;
import com.interview.simulator.admin.generation.assist.dto.AssistedAnalysisResponse;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.repository.ChallengeRepository;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AssistedGenerationServiceTest {

    private final AssistedPromptService promptService = mock(AssistedPromptService.class);
    private final ChallengeIdentityService identityService = mock(ChallengeIdentityService.class);
    private final ChallengeRepository challengeRepository = mock(ChallengeRepository.class);
    private final CategoryRepository categoryRepository = mock(CategoryRepository.class);
    private final SkillRepository skillRepository = mock(SkillRepository.class);
    private final ProfileRepository profileRepository = mock(ProfileRepository.class);
    private final InterviewScenarioRepository scenarioRepository = mock(InterviewScenarioRepository.class);
    private final TransactionTemplate transactionTemplate = mock(TransactionTemplate.class);
    private final jakarta.validation.Validator beanValidator = mock(jakarta.validation.Validator.class);

    @BeforeEach
    void stubsCommunes() {
        when(identityService.generateExternalId()).thenReturn("ext-1");
        when(identityService.contentHash(any())).thenReturn("hash");
        when(transactionTemplate.execute(any())).thenAnswer(invocation -> {
            TransactionCallback<Object> callback = invocation.getArgument(0);
            return callback.doInTransaction(null);
        });
        when(beanValidator.validate(any())).thenReturn(Set.of());
        when(challengeRepository.findByExternalId(any())).thenReturn(Optional.empty());
        when(challengeRepository.findByContentHash(any())).thenReturn(List.of());
    }

    @Test
    void typeInconnu_ListeLesValeursAutorisees() {
        String json = "{\"questions\":[{\"type\":\"TOTO\"}]}";

        ApiException exception = assertThrows(ApiException.class, () -> parseOnlyService().analyze(json));

        String message = exception.getMessage();
        assertTrue(message.startsWith("Question #0 : "), message);
        assertTrue(message.contains("champ « type »"), message);
        assertTrue(message.contains("« TOTO »"), message);
        assertTrue(message.contains(
                "Valeurs autorisées : SITUATIONAL_QCM, PROBLEM_SOLVING, CODE_REVIEW, ARCHITECTURE, SEQUENTIAL_REASONING"),
                message);
        assertSansInterne(message);
    }

    @Test
    void difficulteInconnue_PointeLaQuestionConcernee() {
        String json = """
                {"questions":[
                  {"type":"SITUATIONAL_QCM","difficulty":"JUNIOR"},
                  {"type":"SITUATIONAL_QCM","difficulty":"SENIOR"}
                ]}""";

        ApiException exception = assertThrows(ApiException.class, () -> parseOnlyService().analyze(json));

        String message = exception.getMessage();
        assertTrue(message.startsWith("Question #1 : "), message);
        assertTrue(message.contains("champ « difficulty »"), message);
        assertTrue(message.contains("« SENIOR »"), message);
        assertTrue(message.contains("Valeurs autorisées : JUNIOR, INTERMEDIATE, ADVANCED"), message);
        assertSansInterne(message);
    }

    @Test
    void severiteInconnue_ListeLesSeveritesAutorisees() {
        String json = """
                {"questions":[
                  {"type":"SITUATIONAL_QCM",
                   "options":[{"content":"ok","severity":"CRITIQUE"}]}
                ]}""";

        ApiException exception = assertThrows(ApiException.class, () -> parseOnlyService().analyze(json));

        String message = exception.getMessage();
        assertTrue(message.startsWith("Question #0 : "), message);
        assertTrue(message.contains("champ « severity »"), message);
        assertTrue(message.contains("« CRITIQUE »"), message);
        assertTrue(message.contains(
                "Valeurs autorisées : BUG, PERFORMANCE, SECURITY, CODE_QUALITY, ARCHITECTURE, MAINTAINABILITY, TESTING, DATABASE"),
                message);
        assertSansInterne(message);
    }

    @Test
    void champInconnu_CiteLeChampSansDetailsInternes() {
        String json = "{\"questions\":[{\"title\":\"T\",\"champInconnu\":1}]}";

        ApiException exception = assertThrows(ApiException.class, () -> parseOnlyService().analyze(json));

        String message = exception.getMessage();
        assertTrue(message.startsWith("Question #0 : "), message);
        assertTrue(message.contains("champ « champInconnu » inconnu"), message);
        assertTrue(message.contains("Champs autorisés :"), message);
        assertSansInterne(message);
    }

    @Test
    void champInconnuARacine_RefuseEtListeLesChampsAutorises() {
        String json = "{\"questions\":[],\"extra\":1}";

        ApiException exception = assertThrows(ApiException.class, () -> parseOnlyService().analyze(json));

        String message = exception.getMessage();
        assertTrue(message.contains("à la racine : extra"), message);
        assertTrue(message.contains("Champs autorisés : questions"), message);
        assertSansInterne(message);
    }

    @Test
    void jsonSyntaxiquementInvalide_MessageLisible() {
        String json = "{\"questions\":[";

        ApiException exception = assertThrows(ApiException.class, () -> parseOnlyService().analyze(json));

        String message = exception.getMessage();
        assertTrue(message.startsWith("JSON invalide"), message);
        assertTrue(message.contains("ligne"), message);
        assertSansInterne(message);
    }

    @Test
    void listeQuestionsVide_MessageExplicite() {
        String json = "{\"questions\":[]}";

        ApiException exception = assertThrows(ApiException.class, () -> parseOnlyService().analyze(json));

        assertEquals("La liste « questions » est obligatoire.", exception.getMessage());
    }

    @Test
    void categorieInconnue_RapportAnalyseExpliqueLaRefus() {
        when(categoryRepository.findByNameIn(any())).thenReturn(Set.of());
        when(categoryRepository.findAll()).thenReturn(List.of(
                new Category("Java", null),
                new Category("SQL", null)));
        String json = questionJson("""
                "categories":["Inconnu"]""");

        AssistedAnalysisResponse response = service(importService()).analyze(json);

        assertEquals(1, response.errors());
        AssistedAnalysisResponse.QuestionPreview preview = response.questions().get(0);
        assertEquals("ERROR", preview.status());
        assertEquals("Question #0 : Catégorie(s) inconnue(s) : Inconnu. Valeurs autorisées : Java, SQL.",
                preview.reason());
    }

    @Test
    void competenceInconnue_RapportAnalyseExpliqueLaRefus() {
        when(categoryRepository.findByNameIn(any())).thenReturn(Set.of(new Category("Java", null)));
        when(skillRepository.findByNameIn(any())).thenReturn(Set.of());
        when(skillRepository.findAll()).thenReturn(List.of(new Skill("Tests unitaires", null)));
        String json = questionJson("""
                "categories":["Java"],"skills":["CapaciteInconnue"]""");

        AssistedAnalysisResponse response = service(importService()).analyze(json);

        assertEquals(
                "Question #0 : Compétence(s) inconnue(s) : CapaciteInconnue. Valeurs autorisées : Tests unitaires.",
                response.questions().get(0).reason());
    }

    @Test
    void profilInconnu_OuInactif_RapportAnalyseExpliqueLaRefus() {
        when(categoryRepository.findByNameIn(any())).thenReturn(Set.of(new Category("Java", null)));
        when(skillRepository.findByNameIn(any())).thenReturn(Set.of(new Skill("Tests unitaires", null)));
        when(profileRepository.findByCodeIn(any())).thenReturn(Set.of());
        when(profileRepository.findAll()).thenReturn(List.of(new Profile("DEV", "Développeur", null)));
        String json = questionJson("""
                "categories":["Java"],"skills":["Tests unitaires"],"profiles":["NOPE"]""");

        AssistedAnalysisResponse response = service(importService()).analyze(json);

        assertEquals(
                "Question #0 : Profil(s) inconnu(s) : NOPE. Valeurs autorisées : DEV.",
                response.questions().get(0).reason());
    }

    @Test
    void echappementInvalide_SupprimeLeBackslashSansCasserLaChaine() {
        when(categoryRepository.findByNameIn(any())).thenReturn(Set.of(new Category("Java", null)));
        when(skillRepository.findByNameIn(any())).thenReturn(Set.of(new Skill("Tests unitaires", null)));
        when(profileRepository.findByCodeIn(any())).thenReturn(Set.of(new Profile("DEV", "Développeur", null)));
        String json = questionJson("""
                "codeSnippet":"if (a \\@ b) {\\n  c();\\n}","codeLanguage":"java",
                "categories":["Java"],"skills":["Tests unitaires"],"profiles":["DEV"]""");

        AssistedAnalysisResponse response = service(importService()).analyze(json);

        AssistedAnalysisResponse.QuestionPreview preview = response.questions().get(0);
        assertEquals("VALID", preview.status(), preview.reason());
        assertEquals("Java", preview.categories().get(0));
    }

    @Test
    void guillemetInterneNonEchappe_EchappeEtAnalyse() {
        when(categoryRepository.findByNameIn(any())).thenReturn(Set.of(new Category("Java", null)));
        when(skillRepository.findByNameIn(any())).thenReturn(Set.of(new Skill("Tests unitaires", null)));
        when(profileRepository.findByCodeIn(any())).thenReturn(Set.of(new Profile("DEV", "Développeur", null)));
        String json = """
                {"questions":[{"title":"Le dev écrit "TODO" partout","type":"SITUATIONAL_QCM",
                "difficulty":"JUNIOR","selectionType":"SINGLE_CHOICE","question":"Question ?",
                "estimatedTimeSeconds":60,"points":5,"categories":["Java"],
                "skills":["Tests unitaires"],"profiles":["DEV"],
                "options":[{"content":"ok","correct":true,"displayOrder":0}]}]}""";

        AssistedAnalysisResponse response = service(importService()).analyze(json);

        AssistedAnalysisResponse.QuestionPreview preview = response.questions().get(0);
        assertEquals("VALID", preview.status(), preview.reason());
        assertEquals("Le dev écrit \"TODO\" partout", preview.title());
    }

    @Test
    void importJson_StatutValidated_TransmisAuPipeline() {
        ChallengeImportService importService = mock(ChallengeImportService.class);
        String json = questionJson("\"categories\":[\"Java\"]");

        service(importService).importJson(json, ContentStatus.VALIDATED);

        verify(importService).importQuestions(anyList(), eq(ContentStatus.VALIDATED), eq(false));
    }

    @Test
    void importJson_SansStatut_TombeEnDRAFT() {
        ChallengeImportService importService = mock(ChallengeImportService.class);
        String json = questionJson("\"categories\":[\"Java\"]");

        service(importService).importJson(json, null);

        verify(importService).importQuestions(anyList(), eq(ContentStatus.DRAFT), eq(false));
    }

    @Test
    void importJson_StatutInterdit_Refuse() {
        String json = questionJson("\"categories\":[\"Java\"]");

        ApiException exception = assertThrows(ApiException.class,
                () -> parseOnlyService().importJson(json, ContentStatus.ARCHIVED));

        assertEquals("Le statut doit être DRAFT ou VALIDATED.", exception.getMessage());
    }

    private void assertSansInterne(String message) {
        assertFalse(message.contains("com.interview"), message);
        assertFalse(message.contains("com.fasterxml"), message);
    }

    private String questionJson(String extraFields) {
        return "{\"questions\":[{\"title\":\"Question\",\"type\":\"SITUATIONAL_QCM\","
                + "\"difficulty\":\"JUNIOR\",\"selectionType\":\"SINGLE_CHOICE\","
                + "\"question\":\"Question ?\",\"estimatedTimeSeconds\":60,\"points\":5,"
                + extraFields + ","
                + "\"options\":[{\"content\":\"ok\",\"correct\":true,\"displayOrder\":0}]}]}";
    }

    private AssistedGenerationService parseOnlyService() {
        return service(mock(ChallengeImportService.class));
    }

    private AssistedGenerationService service(ChallengeImportService importService) {
        return new AssistedGenerationService(promptService, importService, identityService, 20);
    }

    private ChallengeImportService importService() {
        ChallengeTypeValidatorRegistry registry = new ChallengeTypeValidatorRegistry(
                new SituationalQcmValidator(),
                new ProblemSolvingValidator(),
                new CodeReviewValidator(),
                new ArchitectureValidator(),
                new SequentialReasoningValidator());
        return new ChallengeImportService(
                challengeRepository,
                categoryRepository,
                skillRepository,
                profileRepository,
                scenarioRepository,
                registry,
                identityService,
                transactionTemplate,
                new ObjectMapper(),
                beanValidator);
    }
}
