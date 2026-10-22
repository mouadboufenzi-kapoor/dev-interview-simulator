package com.interview.simulator.admin.generation.assist.service;

import com.interview.simulator.admin.generation.assist.dto.AssistedPromptRequest;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.OptionSeverity;
import com.interview.simulator.challenge.entity.SelectionType;
import com.interview.simulator.challenge.service.ChallengeTimePolicy;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;


@Service
public class AssistedPromptService {

    private static final String EXAMPLE_MARKER =
            "Exemple de JSON complet et valide pour ce type (même structure, contenu à adapter) :";
    private static final String CLOSING_RULE =
            "Envoie uniquement le JSON final, sans Markdown ni texte d'introduction.";
    private static final String FUNDAMENTALS_SKILL_NAME = "Fundamentals";
    private static final String FUNDAMENTALS_RULE =
            "Règle Fundamentals : question de connaissance ou de théorie sans scénario à diagnostiquer, "
                    + "optimiser ou concevoir ; dès qu'une situation est à résoudre, choisir une autre compétence.";

    private static final String EXAMPLE_TEMPLATE = """
            {
              "questions": [
                {
                  "title": "Titre court et direct de la question",
                  "type": "%s",
                  "difficulty": "%s",
                  "selectionType": "%s",
                  "context": %s,
                  "question": "Énoncé clair de la question, rédigé en français.",
                  "codeSnippet": %s,
                  "codeLanguage": %s,
                  "explanation": "Explication utile et concise de la réponse.",
                  "revealedInformation": %s,
                  "tradeoff": %s,
                  "estimatedTimeSeconds": %d,
                  "points": 10,
                  "categories": %s,
                  "skills": %s,
                  "profiles": %s,
                  "scenario": %s,
                  "stepOrder": %s,
                  "options": %s
                }
              ]
            }
            """;

    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;
    private final ProfileRepository profileRepository;

    public AssistedPromptService(
            CategoryRepository categoryRepository,
            SkillRepository skillRepository,
            ProfileRepository profileRepository) {
        this.categoryRepository = categoryRepository;
        this.skillRepository = skillRepository;
        this.profileRepository = profileRepository;
    }

    public String buildPrompt(AssistedPromptRequest request) {
        List<String> categoryNames = requireCategoryNames(request.categoryIds());
        List<Skill> skills = requireSkills(request.skillIds());
        List<String> skillNames = skills.stream().map(Skill::getName).toList();
        List<String> profileCodes = requireProfileCodes(request.profileIds());

        StringBuilder prompt = new StringBuilder();
        prompt.append("Tu prépares un lot de questions pour InterviewLab, une plateforme de préparation aux entretiens techniques. Réponds UNIQUEMENT avec un objet JSON de forme {\"questions\": [...]} : ni texte avant ou après, ni balises markdown, ni commentaire.\n\n");
        prompt.append("Lot demandé : exactement ").append(request.count())
                .append(" questions de type ").append(request.type())
                .append(" de niveau ").append(request.difficulty()).append(".\n");
        if (!categoryNames.isEmpty()) {
            prompt.append("Catégories techniques autorisées (noms exacts) : ").append(String.join(", ", categoryNames)).append(".\n");
        }
        if (!skills.isEmpty()) {
            prompt.append("Compétences autorisées (nom exact — description) :\n");
            skills.forEach(skill -> prompt.append("- ").append(skillLine(skill)).append('\n'));
            if (containsFundamentals(skills)) {
                prompt.append(FUNDAMENTALS_RULE).append('\n');
            }
        }
        if (!profileCodes.isEmpty()) {
            prompt.append("Profils destinataires (codes exacts) : ").append(String.join(", ", profileCodes)).append(".\n");
        }
        prompt.append("\nTaxonomie :\n");
        prompt.append("- Une catégorie = le sujet technique de la question ; une compétence = la capacité que la question évalue.\n");
        prompt.append("- Chaque question doit comporter au moins une catégorie et au moins une compétence, choisies UNIQUEMENT parmi les listes autorisées ci-dessus.\n");
        prompt.append("\nRègles communes :\n");
        prompt.append("- N'invente JAMAIS de profil, catégorie ou compétence : recopie exactement une ou plusieurs des valeurs listées ci-dessus dans les champs « categories » (noms), « skills » (noms) et « profiles » (codes).\n");
        prompt.append("- Ne mets PAS de champ « externalId » : le serveur en attribue un à chaque question.\n");
        prompt.append("- Chaque question est originale : aucune répétition ni reformulation d'une autre question du lot.\n");
        prompt.append("- Rédige en français clair et professionnel, sans emoji ; une idée par phrase, vocabulaire adapté au niveau, lisible sur mobile.\n");
        prompt.append("- Titre direct (< 120 caractères) ; contexte compact mais suffisant ; question explicite ; explication correcte, pédagogique et concise.\n");
        prompt.append("- Chaque question évalue une compétence principale, dans un contexte réaliste ; évite les ambiguïtés, les doubles négations, les détails décoratifs et les connaissances hors sujet.\n");
        prompt.append("- Les options restent plausibles et de longueur, ton et construction comparables ; aucune ne révèle la bonne réponse par sa précision, sa formulation, un absolu ou la reprise de l'énoncé.\n");
        prompt.append("- Pour éviter les indices de position dans le lot, répartis les bonnes réponses entre les displayOrder disponibles ; ne place pas systématiquement la bonne réponse au même rang.\n");
        prompt.append(ChallengeTimePolicy.promptRule(request.type()));
        prompt.append("- « points » entre 1 et 10.\n");
        prompt.append("- Format exact de chaque question (aucun autre champ) : {\"title\": string, \"type\": \"")
                .append(request.type())
                .append("\", \"difficulty\": \"").append(request.difficulty())
                .append("\", \"selectionType\": \"SINGLE_CHOICE\" ou \"MULTIPLE_CHOICE\", \"context\": string|null, \"question\": string, \"codeSnippet\": string|null, \"codeLanguage\": string|null, \"explanation\": string, \"revealedInformation\": string|null, \"tradeoff\": string|null, \"estimatedTimeSeconds\": int, \"points\": int, \"categories\": [noms exacts], \"skills\": [noms exacts], \"profiles\": [codes exacts], \"scenario\": string|null, \"stepOrder\": int|null, \"options\": [{\"content\": string, \"correct\": bool, \"severity\": string|null, \"explanation\": string|null, \"displayOrder\": int}]}.\n");
        prompt.append(typeRules(request.type()));
        if (request.instructions() != null && !request.instructions().isBlank()) {
            prompt.append("Consigne complémentaire de l'administrateur à respecter : ")
                    .append(request.instructions().trim()).append('\n');
        }
        prompt.append("\n").append(exampleSection(request, categoryNames, skillNames, profileCodes)).append("\n");
        prompt.append(CLOSING_RULE);
        return prompt.toString();
    }

    private String exampleSection(
            AssistedPromptRequest request,
            List<String> categoryNames,
            List<String> skillNames,
            List<String> profileCodes) {
        String example = EXAMPLE_TEMPLATE.formatted(
                request.type().name(),
                request.difficulty().name(),
                selectionTypeJson(request.type()),
                contextJson(request.type()),
                codeSnippetJson(request.type()),
                codeLanguageJson(request.type()),
                revealedInformationJson(request.type()),
                tradeoffJson(request.type()),
                ChallengeTimePolicy.normalize(request.type(), ChallengeTimePolicy.DEFAULT_SECONDS),
                jsonArray(categoryNames),
                jsonArray(skillNames),
                jsonArray(profileCodes),
                scenarioJson(request.type()),
                stepOrderJson(request.type()),
                optionsJson(request.type()));
        return EXAMPLE_MARKER + "\n" + example;
    }

    private String typeRules(ChallengeType type) {
        return switch (type) {
            case SITUATIONAL_QCM -> """
                    Règles du type SITUATIONAL_QCM : selectionType vaut SINGLE_CHOICE ; exactement 4 options \
                    dont exactement une avec correct=true ; severity=null partout ; scenario=null et stepOrder=null ; \
                    le contexte décrit une situation professionnelle réaliste.\n
                    """;
            case PROBLEM_SOLVING -> """
                    Règles du type PROBLEM_SOLVING : selectionType vaut SINGLE_CHOICE ; exactement 4 options \
                    dont exactement une avec correct=true ; severity=null partout ; scenario=null et stepOrder=null ; \
                    la question présente un problème concret à résoudre.\n
                    """;
            case CODE_REVIEW -> """
                    Règles du type CODE_REVIEW : selectionType vaut MULTIPLE_CHOICE ; codeSnippet obligatoire \
                    (extrait de code Java ou TypeScript de 5 à 20 lignes contenant des défauts réels) et \
                    codeLanguage correspondant ("java" ou "typescript") ; de 4 à 6 options dont au moins deux \
                    avec correct=true ; chaque option porte une severity parmi BUG, PERFORMANCE, SECURITY, \
                    CODE_QUALITY, ARCHITECTURE, MAINTAINABILITY, TESTING, DATABASE ; \
                    scenario=null et stepOrder=null.\n
                    """;
            case ARCHITECTURE -> """
                    Règles du type ARCHITECTURE : scenario et stepOrder sont obligatoires (jamais null) ; \
                    toutes les questions du lot forment les étapes d'un même scénario ; chaque question porte \
                    le même titre de scénario dans « scenario » et un stepOrder unique et consécutif commençant à 1 ; \
                    selectionType vaut SINGLE_CHOICE ; exactement 4 options dont exactement une avec correct=true ; \
                    revealedInformation (repère concret) et tradeoff (compromis assumé) sont obligatoires \
                    et ne doivent jamais être null.\n
                    """;
            case SEQUENTIAL_REASONING -> """
                    Règles du type SEQUENTIAL_REASONING : chaque question présente exactement 5 étapes dans \
                    options, toutes avec correct=true et severity=null ; displayOrder couvre exactement 0 à 4 \
                    et reflète l'ordre attendu de la démarche ; scenario=null et stepOrder=null ; \
                    selectionType vaut SINGLE_CHOICE ; l'explication de chaque étape justifie sa position.\n
                    """;
        };
    }

    private String selectionTypeJson(ChallengeType type) {
        SelectionType selectionType = type == ChallengeType.CODE_REVIEW
                ? SelectionType.MULTIPLE_CHOICE
                : SelectionType.SINGLE_CHOICE;
        return selectionType.name();
    }

    private String contextJson(ChallengeType type) {
        return switch (type) {
            case SITUATIONAL_QCM -> "\"Une mise en situation professionnelle en 2 à 5 phrases courtes.\"";
            case PROBLEM_SOLVING -> "\"Un problème concret rencontré par une équipe de développement.\"";
            default -> "null";
        };
    }

    private String codeSnippetJson(ChallengeType type) {
        if (type != ChallengeType.CODE_REVIEW) {
            return "null";
        }
        return "\"public int somme(List<Integer> valeurs) {\\n"
                + "    int total = 0;\\n"
                + "    for (int i = 0; i <= valeurs.size(); i++) {\\n"
                + "        total += valeurs.get(i);\\n"
                + "    }\\n"
                + "    return total;\\n"
                + "}\"";
    }

    private String codeLanguageJson(ChallengeType type) {
        return type == ChallengeType.CODE_REVIEW ? "\"java\"" : "null";
    }

    private String revealedInformationJson(ChallengeType type) {
        return type == ChallengeType.ARCHITECTURE
                ? "\"Repère concret : l'existant traite déjà 1 200 commandes par nuit.\""
                : "null";
    }

    private String tradeoffJson(ChallengeType type) {
        return type == ChallengeType.ARCHITECTURE
                ? "\"Compromis assumé : livrer par étapes plutôt que tout réécrire d'un bloc.\""
                : "null";
    }

    private String scenarioJson(ChallengeType type) {
        return type == ChallengeType.ARCHITECTURE
                ? "\"Refonte de l'API de facturation\""
                : "null";
    }

    private String stepOrderJson(ChallengeType type) {
        return type == ChallengeType.ARCHITECTURE ? "1" : "null";
    }

    private String optionsJson(ChallengeType type) {
        return switch (type) {
            case SITUATIONAL_QCM -> situationalQcmOptions();
            case PROBLEM_SOLVING -> problemSolvingOptions();
            case CODE_REVIEW -> codeReviewOptions();
            case ARCHITECTURE -> architectureOptions();
            case SEQUENTIAL_REASONING -> sequentialReasoningOptions();
        };
    }

    private String situationalQcmOptions() {
        return "["
                + option("Première proposition plausible.", false, null, null, 0)
                + ", " + option("Deuxième proposition, correcte dans la situation.", true, null, "Justification courte et factuelle.", 1)
                + ", " + option("Troisième proposition plausible.", false, null, null, 2)
                + ", " + option("Quatrième proposition plausible.", false, null, null, 3)
                + "]";
    }

    private String problemSolvingOptions() {
        return "["
                + option("Une piste plausible mais non vérifiée.", false, null, null, 0)
                + ", " + option("Une démarche de diagnostic puis de correction ciblée.", true, null, "Elle traite la cause avant de modifier le système.", 1)
                + ", " + option("Un contournement plausible qui masque le symptôme.", false, null, null, 2)
                + ", " + option("Une modification plausible mais sans lien avec les faits.", false, null, null, 3)
                + "]";
    }

    private String codeReviewOptions() {
        return "["
                + option("La condition de boucle sort des bornes de la liste.", true, OptionSeverity.BUG,
                        "Index hors bornes à l'exécution.", 0)
                + ", " + option("La méthode recalcule la taille à chaque itération.", true, OptionSeverity.PERFORMANCE,
                        "Complexité évitable.", 1)
                + ", " + option("Le nom de la variable masque l'intention métier.", false, OptionSeverity.CODE_QUALITY,
                        null, 2)
                + ", " + option("Le style respecte la convention du projet.", false, OptionSeverity.CODE_QUALITY,
                        null, 3)
                + "]";
    }

    private String architectureOptions() {
        return "["
                + option("Découper le service en modules par domaine.", true, null,
                        "Réduit le couplage entre les équipes.", 0)
                + ", " + option("Conserver un service unique avec des paquets internes.", false, null,
                        "Renforce le couplage global.", 1)
                + ", " + option("Extraire chaque fonction dans un microservice distinct sans besoin de montée en charge.", false, null,
                        "Ajoute des coûts opérationnels sans bénéfice établi.", 2)
                + ", " + option("Choisir le stockage avant de clarifier les contraintes de cohérence.", false, null,
                        "Le choix ne découle pas des besoins exprimés.", 3)
                + "]";
    }

    private String sequentialReasoningOptions() {
        return "["
                + option("Étape 1 : clarifier les contraintes.", true, null, "On cadre d'abord le besoin.", 0)
                + ", " + option("Étape 2 : recueillir les données utiles.", true, null,
                        "Les données nourrissent l'étape suivante.", 1)
                + ", " + option("Étape 3 : comparer les pistes.", true, null, "La comparaison vient après la collecte.", 2)
                + ", " + option("Étape 4 : choisir la solution.", true, null, "Le choix conclut la comparaison.", 3)
                + ", " + option("Étape 5 : vérifier les risques.", true, null, "Le contrôle clôt la démarche.", 4)
                + "]";
    }

    private String option(String content, boolean correct, OptionSeverity severity, String explanation, int displayOrder) {
        return "{\"content\": \"" + content + "\", \"correct\": " + correct
                + ", \"severity\": " + severityJson(severity)
                + ", \"explanation\": " + explanationJson(explanation)
                + ", \"displayOrder\": " + displayOrder + "}";
    }

    private String severityJson(OptionSeverity severity) {
        return severity == null ? "null" : "\"" + severity.name() + "\"";
    }

    private String explanationJson(String explanation) {
        return explanation == null ? "null" : "\"" + explanation + "\"";
    }

    private String jsonArray(List<String> values) {
        if (values.isEmpty()) {
            return "[]";
        }
        return values.stream().map(this::jsonString).collect(Collectors.joining(", ", "[", "]"));
    }

    private String jsonString(String value) {
        return "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }

    private List<String> requireCategoryNames(Set<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        Set<Category> found = categoryRepository.findAllById(ids).stream().collect(Collectors.toSet());
        rejectMissing(ids, found.stream().map(Category::getId).collect(Collectors.toSet()),
                "Catégorie(s) introuvable(s) : ");
        return found.stream().map(Category::getName).sorted().toList();
    }

    private List<Skill> requireSkills(Set<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        Set<Skill> found = skillRepository.findAllById(ids).stream().collect(Collectors.toSet());
        rejectMissing(ids, found.stream().map(Skill::getId).collect(Collectors.toSet()),
                "Compétence(s) introuvable(s) : ");
        return found.stream().sorted(Comparator.comparing(Skill::getName)).toList();
    }

    private String skillLine(Skill skill) {
        return isBlank(skill.getDescription())
                ? skill.getName()
                : skill.getName() + " — " + skill.getDescription();
    }

    private boolean containsFundamentals(List<Skill> skills) {
        return skills.stream().anyMatch(skill -> FUNDAMENTALS_SKILL_NAME.equals(skill.getName()));
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private List<String> requireProfileCodes(Set<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        Set<Profile> found = profileRepository.findAllById(ids).stream().collect(Collectors.toSet());
        rejectMissing(ids, found.stream().map(Profile::getId).collect(Collectors.toSet()),
                "Profil(s) introuvable(s) : ");
        List<String> inactive = found.stream()
                .filter(profile -> !profile.isActive())
                .map(Profile::getCode)
                .sorted()
                .toList();
        if (!inactive.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Profil(s) inactif(s) : " + String.join(", ", inactive));
        }
        return found.stream().map(Profile::getCode).sorted().toList();
    }

    private void rejectMissing(Set<Long> requested, Set<Long> found, String messagePrefix) {
        List<String> missing = requested.stream()
                .filter(id -> !found.contains(id))
                .map(String::valueOf)
                .sorted()
                .toList();
        if (!missing.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, messagePrefix + String.join(", ", missing));
        }
    }
}