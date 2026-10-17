package com.interview.simulator.admin.generation.assist.service;

import com.interview.simulator.admin.generation.assist.dto.AssistedPromptRequest;
import com.interview.simulator.category.entity.Category;
import com.interview.simulator.category.repository.CategoryRepository;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.exception.ApiException;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.skill.entity.Skill;
import com.interview.simulator.skill.repository.SkillRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;


@Service
public class AssistedPromptService {

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
        List<String> skillNames = requireSkillNames(request.skillIds());
        List<String> profileCodes = requireProfileCodes(request.profileIds());

        StringBuilder prompt = new StringBuilder();
        prompt.append("Tu prépares un lot de questions pour InterviewLab, une plateforme de préparation aux entretiens techniques. Réponds UNIQUEMENT avec un objet JSON de forme {\"questions\": [...]} : ni texte avant ou après, ni balises markdown, ni commentaire.\n\n");
        prompt.append("Lot demandé : exactement ").append(request.count())
                .append(" questions de type ").append(request.type())
                .append(" de niveau ").append(request.difficulty()).append(".\n");
        if (!categoryNames.isEmpty()) {
            prompt.append("Catégories techniques autorisées (noms exacts) : ").append(String.join(", ", categoryNames)).append(".\n");
        }
        if (!skillNames.isEmpty()) {
            prompt.append("Compétences autorisées (noms exacts) : ").append(String.join(", ", skillNames)).append(".\n");
        }
        if (!profileCodes.isEmpty()) {
            prompt.append("Profils destinataires (codes exacts) : ").append(String.join(", ", profileCodes)).append(".\n");
        }
        prompt.append("\nRègles communes :\n");
        prompt.append("- N'invente JAMAIS de profil, catégorie ou compétence : recopie exactement une ou plusieurs des valeurs listées ci-dessus dans les champs « categories » (noms), « skills » (noms) et « profiles » (codes).\n");
        prompt.append("- Ne mets PAS de champ « externalId » : le serveur en attribue un à chaque question.\n");
        prompt.append("- Chaque question est originale : aucune répétition ni reformulation d'une autre question du lot.\n");
        prompt.append("- Rédige en français, ton professionnel, sans emoji, lisible sur mobile (phrases courtes, une idée par phrase).\n");
        prompt.append("- Titre court et direct (< 120 caractères) ; mise en situation compacte (2 à 5 phrases courtes) ; options courtes ; explication utile et concise.\n");
        prompt.append("- « estimatedTimeSeconds » > 0 (ex. 30 à 180) et « points » entre 1 et 10.\n");
        prompt.append("- Format exact de chaque question (aucun autre champ) : {\"title\": string, \"type\": \"")
                .append(request.type())
                .append("\", \"difficulty\": \"").append(request.difficulty())
                .append("\", \"selectionType\": \"SINGLE_CHOICE\" ou \"MULTIPLE_CHOICE\", \"context\": string|null, \"question\": string, \"codeSnippet\": string|null, \"codeLanguage\": string|null, \"explanation\": string, \"revealedInformation\": string|null, \"tradeoff\": string|null, \"estimatedTimeSeconds\": int, \"points\": int, \"categories\": [noms exacts], \"skills\": [noms exacts], \"profiles\": [codes exacts], \"scenario\": string|null, \"stepOrder\": int|null, \"options\": [{\"content\": string, \"correct\": bool, \"severity\": string|null, \"explanation\": string|null, \"displayOrder\": int}]}.\n");
        prompt.append(typeRules(request.type()));
        if (request.instructions() != null && !request.instructions().isBlank()) {
            prompt.append("Consigne complémentaire de l'administrateur à respecter : ")
                    .append(request.instructions().trim()).append('\n');
        }
        prompt.append("\nEnvoie uniquement le JSON final, sans Markdown ni texte d'introduction.");
        return prompt.toString();
    }

    private String typeRules(ChallengeType type) {
        return switch (type) {
            case SITUATIONAL_QCM -> """
                    Règles du type SITUATIONAL_QCM : selectionType vaut SINGLE_CHOICE ; exactement 4 options \
                    dont exactement une avec correct=true ; severity=null partout ; le contexte décrit une \
                    situation professionnelle réaliste.\n
                    """;
            case PROBLEM_SOLVING -> """
                    Règles du type PROBLEM_SOLVING : selectionType vaut SINGLE_CHOICE ; exactement 4 options \
                    dont exactement une avec correct=true ; severity=null partout ; la question présente un \
                    problème concret à résoudre.\n
                    """;
            case CODE_REVIEW -> """
                    Règles du type CODE_REVIEW : selectionType vaut MULTIPLE_CHOICE ; codeSnippet obligatoire \
                    (extrait de code Java ou TypeScript de 5 à 20 lignes contenant des défauts réels) et \
                    codeLanguage correspondant ("java" ou "typescript") ; de 4 à 6 options dont au moins deux \
                    avec correct=true ; chaque option porte une severity parmi BUG, PERFORMANCE, SECURITY, \
                    CODE_QUALITY, ARCHITECTURE, MAINTAINABILITY, TESTING, DATABASE.\n
                    """;
            case ARCHITECTURE -> """
                    Règles du type ARCHITECTURE : toutes les questions du lot forment les étapes d'un même \
                    scénario ; chaque question porte le même champ scenario (titre court du scénario) et un \
                    stepOrder unique et consécutif commençant à 1 ; selectionType vaut SINGLE_CHOICE ; exactement \
                    2 options dont exactement une avec correct=true ; revealedInformation (repère concret) et \
                    tradeoff (compromis assumé) sont obligatoires et ne doivent jamais être null.\n
                    """;
            case SEQUENTIAL_REASONING -> """
                    Règles du type SEQUENTIAL_REASONING : chaque question présente exactement 5 étapes dans \
                    options, toutes avec correct=true et severity=null ; displayOrder couvre exactement 0 à 4 \
                    et reflète l'ordre attendu de la démarche ; scenario=null et stepOrder=null ; selectionType \
                    vaut SINGLE_CHOICE ; l'explication de chaque étape justifie sa position.\n
                    """;
        };
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

    private List<String> requireSkillNames(Set<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        Set<Skill> found = skillRepository.findAllById(ids).stream().collect(Collectors.toSet());
        rejectMissing(ids, found.stream().map(Skill::getId).collect(Collectors.toSet()),
                "Compétence(s) introuvable(s) : ");
        return found.stream().map(Skill::getName).sorted().toList();
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