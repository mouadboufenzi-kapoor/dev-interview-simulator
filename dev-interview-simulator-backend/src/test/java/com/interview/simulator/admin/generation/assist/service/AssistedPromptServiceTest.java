package com.interview.simulator.admin.generation.assist.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.admin.challenge.validation.ArchitectureValidator;
import com.interview.simulator.admin.challenge.validation.ChallengeTypeValidatorRegistry;
import com.interview.simulator.admin.challenge.validation.CodeReviewValidator;
import com.interview.simulator.admin.challenge.validation.ProblemSolvingValidator;
import com.interview.simulator.admin.challenge.validation.SequentialReasoningValidator;
import com.interview.simulator.admin.challenge.validation.SituationalQcmValidator;
import com.interview.simulator.admin.generation.assist.dto.AssistedPromptRequest;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class AssistedPromptServiceTest {

    private static final String EXAMPLE_MARKER = "Exemple de JSON complet et valide pour ce type";

    private final CategoryRepository categoryRepository = mock(CategoryRepository.class);
    private final SkillRepository skillRepository = mock(SkillRepository.class);
    private final ProfileRepository profileRepository = mock(ProfileRepository.class);
    private final AssistedPromptService service =
            new AssistedPromptService(categoryRepository, skillRepository, profileRepository);
    private final ChallengeTypeValidatorRegistry registry = new ChallengeTypeValidatorRegistry(
            new SituationalQcmValidator(),
            new ProblemSolvingValidator(),
            new CodeReviewValidator(),
            new ArchitectureValidator(),
            new SequentialReasoningValidator());

    @BeforeEach
    void stubsCatalogue() {
        Category java = category(1L, "Java");
        Category react = category(2L, "React");
        Skill tests = skill(3L, "Tests unitaires", "Conception de tests : stratégie, cas limites, mocking, TDD");
        Profile dev = profile(4L, "DEV");
        when(categoryRepository.findAllById(any())).thenReturn(List.of(java, react));
        when(skillRepository.findAllById(any())).thenReturn(List.of(tests));
        when(profileRepository.findAllById(any())).thenReturn(List.of(dev));
    }

    @Test
    void prompt_PlaceLesReglesScenarioStepOrderParType() {
        List<ChallengeType> typesSansScenario = List.of(
                ChallengeType.SITUATIONAL_QCM,
                ChallengeType.PROBLEM_SOLVING,
                ChallengeType.CODE_REVIEW,
                ChallengeType.SEQUENTIAL_REASONING);
        for (ChallengeType type : typesSansScenario) {
            String prompt = service.buildPrompt(request(type));
            assertTrue(prompt.contains("scenario=null et stepOrder=null"),
                    "règle null absente pour " + type);
            assertFalse(prompt.contains("scenario et stepOrder sont obligatoires"),
                    "règle obligatoire inattendue pour " + type);
        }
        String architecture = service.buildPrompt(request(ChallengeType.ARCHITECTURE));
        assertTrue(architecture.contains("scenario et stepOrder sont obligatoires"));
        assertFalse(architecture.contains("scenario=null et stepOrder=null"));
    }

    @Test
    void prompt_ContientLesListesEtLesDefinitionsDeTaxonomie() {
        String prompt = service.buildPrompt(request(ChallengeType.SITUATIONAL_QCM));

        assertTrue(prompt.contains("Catégories techniques autorisées (noms exacts) : Java, React."));
        assertTrue(prompt.contains("Compétences autorisées (nom exact — description)"));
        assertTrue(prompt.contains("- Tests unitaires — Conception de tests : stratégie, cas limites, mocking, TDD"));
        assertTrue(prompt.contains("Profils destinataires (codes exacts) : DEV."));
        assertTrue(prompt.contains("Une catégorie = le sujet technique de la question"));
        assertTrue(prompt.contains("une compétence = la capacité que la question évalue"));
        assertTrue(prompt.contains("au moins une catégorie et au moins une compétence"));
        assertTrue(prompt.contains("choisies UNIQUEMENT parmi les listes autorisées"));
    }

    @Test
    void prompt_DemandeUniquementDuJsonSansMarkdown() {
        String prompt = service.buildPrompt(request(ChallengeType.CODE_REVIEW));

        assertTrue(prompt.contains("Réponds UNIQUEMENT avec un objet JSON"));
        assertTrue(prompt.contains("Envoie uniquement le JSON final, sans Markdown ni texte d'introduction"));
        assertFalse(prompt.contains("```"));
    }

    @Test
    void prompt_ExempleCompletParseEtValide_PourChaqueType() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        for (ChallengeType type : ChallengeType.values()) {
            String prompt = service.buildPrompt(request(type));
            String example = extractExample(prompt);
            ChallengeImportRequest parsed = mapper.readValue(example, ChallengeImportRequest.class);

            assertEquals(1, parsed.questions().size(), "exemple incomplet pour " + type);
            ImportedQuestion question = parsed.questions().get(0);
            assertEquals(type, question.type());
            assertEquals(DifficultyLevel.INTERMEDIATE, question.difficulty());
            assertNull(question.externalId());
            assertTrue(question.categories().containsAll(List.of("Java", "React")));
            assertTrue(question.skills().contains("Tests unitaires"));
            assertTrue(question.profiles().contains("DEV"));
            assertTrue(registry.get(type).validate(question).isEmpty(),
                    "exemple invalide pour " + type + " : " + registry.get(type).validate(question));

            if (type == ChallengeType.ARCHITECTURE) {
                assertNotNull(question.scenario());
                assertEquals(1, question.stepOrder());
                assertNotNull(question.revealedInformation());
                assertNotNull(question.tradeoff());
            } else {
                assertNull(question.scenario());
                assertNull(question.stepOrder());
            }
            if (type == ChallengeType.CODE_REVIEW) {
                assertNotNull(question.codeSnippet());
                assertEquals("java", question.codeLanguage());
            } else {
                assertNull(question.codeSnippet());
            }
        }
    }

    @Test
    void prompt_DecritChaqueCompetanceEtMetLaRegleFundamentals_QuandSelectionne() {
        Skill tests = skill(3L, "Tests unitaires", "Conception de tests : stratégie, cas limites, mocking, TDD");
        Skill fundamentals = skill(6L, "Fundamentals", "Maîtrise des concepts de base et de la théorie");
        when(skillRepository.findAllById(any())).thenReturn(List.of(tests, fundamentals));
        AssistedPromptRequest request = new AssistedPromptRequest(
                Set.of(4L), Set.of(1L, 2L), Set.of(3L, 6L),
                DifficultyLevel.INTERMEDIATE, ChallengeType.SITUATIONAL_QCM, 5, null);

        String prompt = service.buildPrompt(request);

        assertTrue(prompt.contains("Compétences autorisées (nom exact — description)"));
        assertTrue(prompt.contains("- Fundamentals — Maîtrise des concepts de base et de la théorie"));
        assertTrue(prompt.contains("- Tests unitaires — Conception de tests : stratégie, cas limites, mocking, TDD"));
        assertTrue(prompt.contains(
                "Règle Fundamentals : question de connaissance ou de théorie sans scénario à diagnostiquer"));
        assertTrue(prompt.contains(
                "dès qu'une situation est à résoudre, choisir une autre compétence."));
    }

    @Test
    void prompt_RegleFundamentalsAbsente_SansLeSkillFundamentals() {
        String prompt = service.buildPrompt(request(ChallengeType.SITUATIONAL_QCM));

        assertFalse(prompt.contains("Règle Fundamentals"));
    }

    @Test
    void prompt_SansDescription_DecrireUniquementLeNom() {
        Skill fundamentals = skill(3L, "Fundamentals", null);
        when(skillRepository.findAllById(any())).thenReturn(List.of(fundamentals));

        String prompt = service.buildPrompt(request(ChallengeType.SITUATIONAL_QCM));

        assertTrue(prompt.contains("- Fundamentals\n"));
        assertFalse(prompt.contains("Fundamentals —"));
    }

    private String extractExample(String prompt) {
        int marker = prompt.indexOf(EXAMPLE_MARKER);
        assertTrue(marker >= 0, "exemple absent du prompt");
        int start = prompt.indexOf('{', marker);
        int end = prompt.indexOf("Envoie uniquement le JSON final", start);
        assertTrue(start >= 0 && end > start, "extraction de l'exemple impossible");
        return prompt.substring(start, end).trim();
    }

    private AssistedPromptRequest request(ChallengeType type) {
        return new AssistedPromptRequest(
                Set.of(4L),
                Set.of(1L, 2L),
                Set.of(3L),
                DifficultyLevel.INTERMEDIATE,
                type,
                5,
                null);
    }

    private Category category(Long id, String name) {
        Category category = mock(Category.class);
        when(category.getId()).thenReturn(id);
        when(category.getName()).thenReturn(name);
        return category;
    }

    private Skill skill(Long id, String name, String description) {
        Skill skill = mock(Skill.class);
        when(skill.getId()).thenReturn(id);
        when(skill.getName()).thenReturn(name);
        when(skill.getDescription()).thenReturn(description);
        return skill;
    }

    private Profile profile(Long id, String code) {
        Profile profile = mock(Profile.class);
        when(profile.getId()).thenReturn(id);
        when(profile.getCode()).thenReturn(code);
        when(profile.isActive()).thenReturn(true);
        return profile;
    }
}
