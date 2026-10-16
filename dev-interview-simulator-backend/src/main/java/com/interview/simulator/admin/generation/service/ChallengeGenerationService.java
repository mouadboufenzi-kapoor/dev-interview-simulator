package com.interview.simulator.admin.generation.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.admin.challenge.service.ChallengeImportService;
import com.interview.simulator.admin.generation.dto.ChallengeGenerationRequest;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ChallengeGenerationService {

    private static final String JSON_ONLY_INSTRUCTION =
            "Réponds UNIQUEMENT avec un objet JSON de forme {\"questions\": [...]} : "
                    + "ni texte avant ou après, ni balises markdown, ni commentaire.";
    private static final String SCHEMA_INSTRUCTION =
            "Chaque question respecte ce schéma exact : {\"title\": string, \"type\": string, "
                    + "\"difficulty\": string, \"selectionType\": \"SINGLE_CHOICE\" ou \"MULTIPLE_CHOICE\", "
                    + "\"context\": string|null, \"question\": string, \"codeSnippet\": string|null, "
                    + "\"codeLanguage\": string|null, \"explanation\": string, \"revealedInformation\": string|null, "
                    + "\"tradeoff\": string|null, \"estimatedTimeSeconds\": int, \"points\": int, "
                    + "\"scenario\": string|null, \"stepOrder\": int|null, \"options\": "
                    + "[{\"content\": string, \"correct\": bool, \"severity\": string|null, "
                    + "\"explanation\": string|null, \"displayOrder\": int}]}. "
                    + "N'inclus JAMAIS les champs externalId, categories, skills ni profiles : le serveur les injecte. "
                    + "Ne mets un scenario et un stepOrder que si le type est ARCHITECTURE.";
    private static final String LANGUAGE_INSTRUCTION = "Rédige tout en français, ton professionnel, sans emojis.";

    private final GeminiGenerationClient geminiGenerationClient;
    private final ChallengeImportService challengeImportService;
    private final ChallengeIdentityService challengeIdentityService;
    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;
    private final ProfileRepository profileRepository;
    private final ObjectMapper objectMapper;

    public ChallengeGenerationService(
            GeminiGenerationClient geminiGenerationClient,
            ChallengeImportService challengeImportService,
            ChallengeIdentityService challengeIdentityService,
            CategoryRepository categoryRepository,
            SkillRepository skillRepository,
            ProfileRepository profileRepository,
            ObjectMapper objectMapper) {
        this.geminiGenerationClient = geminiGenerationClient;
        this.challengeImportService = challengeImportService;
        this.challengeIdentityService = challengeIdentityService;
        this.categoryRepository = categoryRepository;
        this.skillRepository = skillRepository;
        this.profileRepository = profileRepository;
        this.objectMapper = objectMapper;
    }

    public ChallengeImportReport generate(ChallengeGenerationRequest request) {
        if (!geminiGenerationClient.isConfigured()) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                    "La génération automatique n'est pas configurée : renseignez GEMINI_API_KEY ou activez app.generation.enabled.");
        }
        Relations relations = resolveRelations(request);
        String prompt = buildPrompt(request, relations);
        List<ImportedQuestion> questions = bind(parseQuestions(prompt, request.count()), request, relations);
        return challengeImportService.importQuestions(questions, ContentStatus.DRAFT, false);
    }

    private Relations resolveRelations(ChallengeGenerationRequest request) {
        Set<Long> categoryIds = request.categoryIds() == null ? Set.of() : request.categoryIds();
        Set<Long> skillIds = request.skillIds() == null ? Set.of() : request.skillIds();
        Set<Long> profileIds = request.profileIds() == null ? Set.of() : request.profileIds();

        Set<Category> categories = categoryIds.isEmpty()
                ? Set.of()
                : categoryRepository.findAllById(categoryIds).stream().collect(Collectors.toSet());
        if (categories.size() != categoryIds.size()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Catégorie(s) introuvable(s) : " + missingIds(categoryIds, categories.stream().map(Category::getId).collect(Collectors.toSet())));
        }
        Set<Skill> skills = skillIds.isEmpty()
                ? Set.of()
                : skillRepository.findAllById(skillIds).stream().collect(Collectors.toSet());
        if (skills.size() != skillIds.size()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Compétence(s) introuvable(s) : " + missingIds(skillIds, skills.stream().map(Skill::getId).collect(Collectors.toSet())));
        }
        Set<Profile> profiles = profileIds.isEmpty()
                ? Set.of()
                : profileRepository.findAllById(profileIds).stream().collect(Collectors.toSet());
        if (profiles.size() != profileIds.size()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Profil(s) introuvable(s) : " + missingIds(profileIds, profiles.stream().map(Profile::getId).collect(Collectors.toSet())));
        }
        List<String> inactive = profiles.stream()
                .filter(profile -> !profile.isActive())
                .map(Profile::getCode)
                .sorted()
                .toList();
        if (!inactive.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Profil(s) inactif(s) : " + String.join(", ", inactive));
        }
        return new Relations(
                categories.stream().map(Category::getName).collect(Collectors.toCollection(LinkedHashSet::new)),
                skills.stream().map(Skill::getName).collect(Collectors.toCollection(LinkedHashSet::new)),
                profiles.stream().map(Profile::getCode).collect(Collectors.toCollection(LinkedHashSet::new)));
    }

    private String missingIds(Set<Long> requested, Set<Long> found) {
        return requested.stream()
                .filter(id -> !found.contains(id))
                .map(String::valueOf)
                .sorted()
                .collect(Collectors.joining(", "));
    }

    private String buildPrompt(ChallengeGenerationRequest request, Relations relations) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Tu conçois des questions d'entretien technique pour une plateforme de préparation aux entretiens.\n");
        prompt.append("Génère exactement ").append(request.count())
                .append(" questions de type ").append(request.type())
                .append(" de niveau ").append(request.difficulty()).append(".\n");
        appendTopics(prompt, relations);
        prompt.append(typeRules(request.type()));
        prompt.append("Chaque question doit exploiter un angle ou un piège différent des autres.\n");
        prompt.append(LANGUAGE_INSTRUCTION).append('\n');
        if (request.instructions() != null && !request.instructions().isBlank()) {
            prompt.append("Consigne complémentaire de l'administrateur à respecter : ")
                    .append(request.instructions().trim()).append('\n');
        }
        prompt.append(JSON_ONLY_INSTRUCTION).append('\n');
        prompt.append(SCHEMA_INSTRUCTION);
        return prompt.toString();
    }

    private void appendTopics(StringBuilder prompt, Relations relations) {
        if (!relations.categoryNames().isEmpty()) {
            prompt.append("Catégories techniques : ").append(String.join(", ", relations.categoryNames())).append(".\n");
        }
        if (!relations.skillNames().isEmpty()) {
            prompt.append("Compétences ciblées : ").append(String.join(", ", relations.skillNames())).append(".\n");
        }
        if (!relations.profileCodes().isEmpty()) {
            prompt.append("Profils destinataires : ").append(String.join(", ", relations.profileCodes())).append(".\n");
        }
    }

    private String typeRules(ChallengeType type) {
        return switch (type) {
            case SITUATIONAL_QCM -> """
                    Règles du type SITUATIONAL_QCM : selectionType vaut SINGLE_CHOICE ; exactement 4 options \
                    dont exactement une avec correct=true ; severity=null partout ; le contexte décrit une \
                    situation professionnelle réaliste.\n""";
            case PROBLEM_SOLVING -> """
                    Règles du type PROBLEM_SOLVING : selectionType vaut SINGLE_CHOICE ; exactement 4 options \
                    dont exactement une avec correct=true ; severity=null partout ; la question présente un \
                    problème concret à résoudre.\n""";
            case CODE_REVIEW -> """
                    Règles du type CODE_REVIEW : selectionType vaut MULTIPLE_CHOICE ; codeSnippet obligatoire \
                    (extrait de code Java ou TypeScript de 5 à 20 lignes contenant des défauts réels) et \
                    codeLanguage correspondant ; de 4 à 6 options dont au moins deux avec correct=true ; \
                    chaque option porte une severity parmi BUG, PERFORMANCE, SECURITY, CODE_QUALITY, \
                    ARCHITECTURE, MAINTAINABILITY, TESTING, DATABASE.\n""";
            case ARCHITECTURE -> """
                    Règles du type ARCHITECTURE : les questions forment les étapes d'un même scénario ; \
                    chaque question porte le même champ scenario (titre du scénario) et un stepOrder unique \
                    et consécutif commençant à 1 ; selectionType vaut SINGLE_CHOICE ; exactement 2 options \
                    dont exactement une avec correct=true ; revealedInformation apporte un repère concret et \
                    tradeoff un compromis assumé, tous deux obligatoires.\n""";
            case SEQUENTIAL_REASONING -> """
                    Règles du type SEQUENTIAL_REASONING : chaque question présente exactement 5 étapes dans \
                    options, toutes avec correct=true et severity=null ; displayOrder couvre exactement 0 à 4 \
                    et reflète l'ordre attendu de la démarche ; scenario=null et stepOrder=null ; \
                    selectionType vaut SINGLE_CHOICE ; l'explication de chaque étape justifie sa position.\n""";
        };
    }

    private List<ImportedQuestion> parseQuestions(String prompt, int count) {
        String answer = geminiGenerationClient.generateText(prompt);
        ChallengeImportRequest importRequest;
        try {
            importRequest = objectMapper.readValue(answer, ChallengeImportRequest.class);
        } catch (JsonProcessingException e) {
            throw new ApiException(HttpStatus.BAD_GATEWAY,
                    "La réponse du fournisseur de génération n'est pas un JSON valide : aucune question n'a été importée.");
        }
        List<ImportedQuestion> questions = importRequest.questions();
        if (questions == null || questions.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_GATEWAY,
                    "La réponse du fournisseur de génération ne contient aucune question.");
        }
        return questions.size() > count ? questions.subList(0, count) : questions;
    }

    private List<ImportedQuestion> bind(List<ImportedQuestion> questions, ChallengeGenerationRequest request, Relations relations) {
        return questions.stream()
                .map(question -> bindOne(question, request, relations))
                .toList();
    }

    private ImportedQuestion bindOne(ImportedQuestion question, ChallengeGenerationRequest request, Relations relations) {
        return new ImportedQuestion(
                challengeIdentityService.generateExternalId(),
                question.title(),
                request.type(),
                request.difficulty(),
                question.selectionType(),
                question.context(),
                question.question(),
                question.codeSnippet(),
                question.codeLanguage(),
                question.explanation(),
                question.revealedInformation(),
                question.tradeoff(),
                question.estimatedTimeSeconds(),
                question.points(),
                relations.categoryNames(),
                relations.skillNames(),
                relations.profileCodes(),
                question.scenario(),
                question.stepOrder(),
                question.options());
    }

    private record Relations(
            Set<String> categoryNames,
            Set<String> skillNames,
            Set<String> profileCodes) {
    }
}
