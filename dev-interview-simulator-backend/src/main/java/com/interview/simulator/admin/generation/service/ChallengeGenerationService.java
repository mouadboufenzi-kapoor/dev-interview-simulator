package com.interview.simulator.admin.generation.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest;
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
import com.interview.simulator.challenge.service.ChallengeTimePolicy;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
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
                    + "\"categories\": [noms exacts autorisés], \"skills\": [noms exacts autorisés], "
                    + "\"scenario\": string|null, \"stepOrder\": int|null, \"options\": "
                    + "[{\"content\": string, \"correct\": bool, \"severity\": string|null, "
                    + "\"explanation\": string|null, \"displayOrder\": int}]}. "
                    + "Chaque question doit inclure categories et skills : choisis pour chacun au moins une valeur exacte parmi les listes autorisées. "
                    + "N'inclus JAMAIS les champs externalId ni profiles : le serveur attribue ces valeurs. "
                    + "Ne recopie que les catégories et compétences réellement pertinentes pour la question ; n'ajoute aucune valeur absente des listes. "
                    + "Ne mets un scenario et un stepOrder que si le type est ARCHITECTURE.";
    private static final String LANGUAGE_INSTRUCTION = "Rédige tout en français, ton professionnel, sans emojis.";
    private static final String FUNDAMENTALS_SKILL_NAME = "Fundamentals";
    private static final String FUNDAMENTALS_RULE =
            "Règle Fundamentals : question de connaissance ou de théorie sans scénario à diagnostiquer, "
                    + "optimiser ou concevoir ; dès qu'une situation est à résoudre, choisir une autre compétence.";

    private static final String MOBILE_FIRST_RULE = """
            Priorités éditoriales, par ordre d'importance : compréhension, contexte utile, réalisme, concision. \
            Les questions sont majoritairement lues sur un téléphone : phrases courtes, paragraphes courts, \
            une information par phrase lorsque c'est possible, formulations directes, peu de répétitions. \
            Évite les longs paragraphes, les introductions inutiles, les formulations très académiques et \
            les phrases qui empilent plusieurs notions techniques. \
            Ne cherche jamais à atteindre artificiellement une longueur minimale : si un contexte se \
            explique correctement en deux ou trois phrases, n'ajoute rien pour le rendre plus « complet ». \
            Chaque phrase doit avoir une fonction : si une information n'influence ni le raisonnement \
            attendu ni la réponse, supprime-la. \
            Une question difficile ne doit pas être longue ni compliquée à lire : la difficulté vient du \
            problème, du raisonnement nécessaire, des options, des compromis et des connaissances — jamais \
            d'un vocabulaire inutilement compliqué. Inversement, une question Junior ne devient pas plus \
            facile si on lui retire tout son contexte.\n""";
    private static final String TITLE_RULE = """
            Règle du titre : court et immédiatement compréhensible, il identifie le sujet ou le problème \
            principal. Évite les titres qui ressemblent à des titres de documentation ou de cours, du type \
            « Analyse et résolution d'un problème complexe concernant... ». Préfère des titres simples et \
            directs comme « Une requête PostgreSQL trop lente », « Corriger une transaction Spring », \
            « Un problème de concurrence » ou « Optimiser une requête SQL ». Le titre reste informatif : \
            ce n'est pas une deuxième mise en situation.\n""";
    private static final String CONTEXT_RULE = """
            Règle de la mise en situation (context) : elle donne suffisamment d'informations pour comprendre \
            le problème tout en restant compacte — ni une seule phrase trop pauvre, ni un long paragraphe, \
            ni un mini-article technique. En repère indicatif : Junior 2 à 4 phrases courtes, Intermediate \
            2 à 5 phrases, Advanced plus détaillé seulement si la complexité du scénario le justifie. Ces \
            longueurs ne sont pas des quotas : la compréhension, le contexte utile et le réalisme priment, \
            et aucun détail n'est ajouté artificiellement pour atteindre un nombre de phrases.\n""";
    private static final String QUESTION_RULE = """
            Règle de la question : directe, le candidat comprend rapidement ce qu'on attend de lui. Évite \
            les formulations inutilement complexes et tout jargon qu'il faudrait décoder avant de saisir \
            le problème. Une question teste idéalement une idée principale ou un raisonnement clairement \
            identifiable ; si plusieurs notions sont nécessaires, elles restent naturellement liées au \
            problème posé.\n""";
    private static final String OPTIONS_RULE = """
            Règles des options : chacune est compréhensible seule, concise, précise et formulée naturellement — jamais \
            un long paragraphe. Les propositions répondent directement à la question et restent indépendantes. \
            Pour une sélection unique, les distracteurs sont crédibles et représentent des erreurs ou compromis \
            plausibles, pas des réponses manifestement absurdes. Pour une sélection multiple, chaque bonne réponse \
            identifie un constat distinct et chaque mauvaise proposition reste plausible mais objectivement incorrecte. \
            Garde une longueur, un niveau de détail, une structure grammaticale et un ton comparables entre les options. \
            Ne rends jamais la bonne réponse reconnaissable parce qu'elle est plus longue, plus nuancée, plus précise, \
            mieux rédigée ou seule à contenir une justification. Évite les indices de forme (absolus comme « toujours » \
            ou « jamais », reprise littérale de l'énoncé, accord grammatical ou détail technique réservé à une option). \
            N'ajoute aucune information qui ne sert pas à départager les choix.\n""";
    private static final String FINAL_CHECK_RULE = """
            Avant de rendre chaque question, vérifie mentalement : le titre est-il court et compréhensible ; \
            la mise en situation contient-elle uniquement les informations utiles ; le problème est-il \
            compréhensible rapidement sur mobile ; le niveau de vocabulaire correspond-il à la difficulté \
            demandée ; y a-t-il du jargon inutile ; la question demande-t-elle clairement quelque chose \
            au candidat ; les options sont-elles assez courtes pour une lecture mobile ; la difficulté \
            vient-elle du raisonnement plutôt que d'une formulation inutilement compliquée ; ai-je ajouté \
            du texte uniquement pour remplir la réponse ? Si une formulation peut être plus claire sans \
            perdre le raisonnement ni le contexte, retiens la formulation la plus claire. \
            Ces règles de concision ne rendent jamais la question superficielle : elle reste ancrée dans \
            le profil, la catégorie et la difficulté demandés, teste une compétence réellement pertinente, \
            reste réaliste en entretien, propose une réponse correcte identifiable, des distracteurs \
            plausibles et une explication utile — et ne supprime jamais une information nécessaire pour \
            résoudre le problème.\n""";

    private final LLMGenerationProvider generationProvider;
    private final ChallengeImportService challengeImportService;
    private final ChallengeIdentityService challengeIdentityService;
    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;
    private final ProfileRepository profileRepository;
    private final ObjectMapper objectMapper;
    private final GenerationProviderRegistry generationProviderRegistry;

    public ChallengeGenerationService(
            LLMGenerationProvider generationProvider,
            ChallengeImportService challengeImportService,
            ChallengeIdentityService challengeIdentityService,
            CategoryRepository categoryRepository,
            SkillRepository skillRepository,
            ProfileRepository profileRepository,
            ObjectMapper objectMapper,
            GenerationProviderRegistry generationProviderRegistry) {
        this.generationProvider = generationProvider;
        this.challengeImportService = challengeImportService;
        this.challengeIdentityService = challengeIdentityService;
        this.categoryRepository = categoryRepository;
        this.skillRepository = skillRepository;
        this.profileRepository = profileRepository;
        this.objectMapper = objectMapper;
        this.generationProviderRegistry = generationProviderRegistry;
    }

    public ChallengeImportReport generate(ChallengeGenerationRequest request) {
        GenerationProviderRegistry.Resolved target = resolveTarget(request);
        if (!target.provider().isConfigured()) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                    "La génération automatique n'est pas configurée : renseignez la clé du fournisseur de génération actif ou activez app.generation.enabled.");
        }
        Relations relations = resolveRelations(request);
        requireGenerationTaxonomy(relations);
        String prompt = buildPrompt(request, relations);
        List<ImportedQuestion> questions = bind(parseQuestions(prompt, request.count(), target), request, relations);
        return challengeImportService.importQuestions(questions, ContentStatus.DRAFT, false);
    }

    /**
     * Fournisseur + modele valides depuis la requete admin. Sans fournisseur explicite,
     * on conserve le bean selectionne au demarrage (GENERATION_PROVIDER) : comportement
     * par defaut strictement identique au comportement actuel. Le choix explicite est
     * respecte tel quel, sans aucune basculement automatique vers un autre fournisseur.
     */
    private GenerationProviderRegistry.Resolved resolveTarget(ChallengeGenerationRequest request) {
        GenerationProviderRegistry.Resolved resolved =
                generationProviderRegistry.resolve(request.provider(), request.model());
        boolean explicitProvider = request.provider() != null && !request.provider().isBlank();
        return explicitProvider
                ? resolved
                : new GenerationProviderRegistry.Resolved(generationProvider, resolved.model());
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
                skillDescriptions(skills),
                profiles.stream().map(Profile::getCode).collect(Collectors.toCollection(LinkedHashSet::new)));
    }

    private void requireGenerationTaxonomy(Relations relations) {
        if (relations.categoryNames().isEmpty() || relations.skillNames().isEmpty()
                || relations.profileCodes().isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "La génération API exige au moins une catégorie, une compétence et un profil sélectionnés.");
        }
    }

    private Map<String, String> skillDescriptions(Set<Skill> skills) {
        return skills.stream()
                .sorted(Comparator.comparing(Skill::getName))
                .collect(Collectors.toMap(Skill::getName,
                        skill -> skill.getDescription() == null ? "" : skill.getDescription(),
                        (first, second) -> first,
                        LinkedHashMap::new));
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
        prompt.append("Chaque question évalue une compétence principale, dans un contexte réaliste et adapté au niveau ; "
                + "rédige une consigne sans ambiguïté, une réponse défendable et une explication factuelle.\n");
        prompt.append("Répartis les bonnes réponses entre les displayOrder disponibles ; ne place pas systématiquement la bonne réponse au même rang.\n");
        appendTopics(prompt, relations);
        prompt.append(typeRules(request.type()));
        prompt.append(ChallengeTimePolicy.promptRule(request.type()));
        prompt.append("Chaque question doit exploiter un angle ou un piège différent des autres.\n");
        prompt.append(editorialRules(request.difficulty()));
        prompt.append(LANGUAGE_INSTRUCTION).append('\n');
        if (request.instructions() != null && !request.instructions().isBlank()) {
            prompt.append("Consigne complémentaire de l'administrateur à respecter : ")
                    .append(request.instructions().trim()).append('\n');
        }
        prompt.append(FINAL_CHECK_RULE).append('\n');
        prompt.append(JSON_ONLY_INSTRUCTION).append('\n');
        prompt.append(SCHEMA_INSTRUCTION);
        return prompt.toString();
    }

    private void appendTopics(StringBuilder prompt, Relations relations) {
        if (!relations.categoryNames().isEmpty()) {
            prompt.append("Catégories autorisées (recopie les noms exacts pertinents dans « categories ») : ")
                    .append(String.join(", ", relations.categoryNames())).append(".\n");
        }
        if (!relations.skillNames().isEmpty()) {
            prompt.append("Compétences autorisées (choisis les pertinentes et recopie les noms exacts dans « skills ») :\n");
            relations.skillDescriptions().forEach((name, description) ->
                    prompt.append("- ").append(skillLine(name, description)).append('\n'));
            if (relations.skillNames().contains(FUNDAMENTALS_SKILL_NAME)) {
                prompt.append(FUNDAMENTALS_RULE).append('\n');
            }
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
                    et consécutif commençant à 1 ; selectionType vaut SINGLE_CHOICE ; exactement 4 options \
                    dont exactement une avec correct=true ; revealedInformation apporte un repère concret et \
                    tradeoff un compromis assumé, tous deux obligatoires.\n""";
            case SEQUENTIAL_REASONING -> """
                    Règles du type SEQUENTIAL_REASONING : chaque question présente exactement 5 étapes dans \
                    options, toutes avec correct=true et severity=null ; displayOrder couvre exactement 0 à 4 \
                    et reflète l'ordre attendu de la démarche ; scenario=null et stepOrder=null ; \
                    selectionType vaut SINGLE_CHOICE ; l'explication de chaque étape justifie sa position.\n""";
        };
    }

    private String editorialRules(DifficultyLevel difficulty) {
        return MOBILE_FIRST_RULE
                + TITLE_RULE
                + CONTEXT_RULE
                + QUESTION_RULE
                + OPTIONS_RULE
                + vocabularyRules(difficulty);
    }

    private String vocabularyRules(DifficultyLevel difficulty) {
        return switch (difficulty) {
            case JUNIOR -> """
                    Vocabulaire Junior : simple et professionnel — on teste les fondamentaux et le raisonnement, \
                    pas la capacité à décoder du jargon. Évite le jargon inutile ; lorsqu'un terme technique \
                    avancé est réellement nécessaire, explique-le brièvement dans le contexte ou utilise une \
                    formulation plus accessible. N'empile pas plusieurs termes spécialisés non expliqués dans \
                    une même phrase. Par exemple, au lieu de « Comment forcer l'optimiseur à intégrer le \
                    corps de la CTE dans la requête principale (inlining) afin d'appliquer le filtre au \
                    plus tôt ? », préfère « Une requête PostgreSQL utilise une CTE et devient lente sur de \
                    grands volumes ; le filtre semble appliqué trop tard. Quelle approche permet de réduire \
                    plus tôt le nombre de lignes traitées ? ».\n""";
            case INTERMEDIATE -> """
                    Vocabulaire Intermediate : le niveau professionnel attendu d'un développeur ayant déjà \
                    une expérience pratique. Le jargon technique est autorisé lorsqu'il est pertinent, mais \
                    n'empile pas plusieurs termes spécialisés dans une seule phrase sans utilité pour le \
                    raisonnement : le candidat doit comprendre la question sans avoir à décoder une \
                    formulation inutilement sophistiquée.\n""";
            case ADVANCED -> """
                    Vocabulaire Advanced : la précision technique est autorisée et peut faire partie de la \
                    difficulté ; les notions avancées sont bienvenues lorsqu'elles correspondent \
                    réellement au problème, et la question peut y être plus dense et plus précise. Même à \
                    ce niveau, évite le jargon décoratif et les phrases inutilement longues : chaque terme \
                    technique doit avoir une utilité dans le problème posé.\n""";
        };
    }

    private List<ImportedQuestion> parseQuestions(String prompt, int count, GenerationProviderRegistry.Resolved target) {
        String answer = target.model() == null
                ? target.provider().generateText(prompt)
                : target.provider().generateText(prompt, target.model());
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
        if (questions.size() != count) {
            throw new ApiException(HttpStatus.BAD_GATEWAY,
                    "Le fournisseur de génération devait produire exactement " + count
                            + " questions, mais en a retourné " + questions.size() + ". Aucune question n'a été importée.");
        }
        return questions;
    }

    private List<ImportedQuestion> bind(List<ImportedQuestion> questions, ChallengeGenerationRequest request, Relations relations) {
        return questions.stream()
                .map(question -> bindOne(question, request, relations))
                .toList();
    }

    private ImportedQuestion bindOne(ImportedQuestion question, ChallengeGenerationRequest request, Relations relations) {
        requireAllowedTaxonomy(question, relations);
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
                ChallengeTimePolicy.normalize(request.type(), question.estimatedTimeSeconds()),
                question.points(),
                question.categories(),
                question.skills(),
                relations.profileCodes(),
                question.scenario(),
                question.stepOrder(),
                question.options());
    }

    private void requireAllowedTaxonomy(ImportedQuestion question, Relations relations) {
        Set<String> categories = question.categories() == null ? Set.of() : question.categories();
        Set<String> skills = question.skills() == null ? Set.of() : question.skills();
        if (categories.isEmpty() || skills.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_GATEWAY,
                    "Chaque question générée doit inclure au moins une catégorie et une compétence.");
        }
        if (!relations.categoryNames().containsAll(categories) || !relations.skillNames().containsAll(skills)) {
            throw new ApiException(HttpStatus.BAD_GATEWAY,
                    "Une question générée contient une catégorie ou une compétence non sélectionnée. Aucune question n'a été importée.");
        }
    }

    private String skillLine(String name, String description) {
        return description.isBlank() ? name : name + " — " + description;
    }

    private record Relations(
            Set<String> categoryNames,
            Set<String> skillNames,
            Map<String, String> skillDescriptions,
            Set<String> profileCodes) {
    }
}
