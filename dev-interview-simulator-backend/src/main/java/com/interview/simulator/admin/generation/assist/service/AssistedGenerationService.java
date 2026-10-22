package com.interview.simulator.admin.generation.assist.service;

import com.fasterxml.jackson.core.JsonLocation;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.exc.InvalidFormatException;
import com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedOption;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.admin.challenge.service.ChallengeImportService;
import com.interview.simulator.admin.generation.assist.dto.AssistedAnalysisResponse;
import com.interview.simulator.admin.generation.assist.dto.AssistedAnalysisResponse.QuestionPreview;
import com.interview.simulator.admin.generation.assist.dto.AssistedPromptRequest;
import com.interview.simulator.admin.generation.assist.dto.AssistedPromptResponse;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.entity.DifficultyLevel;
import com.interview.simulator.challenge.entity.OptionSeverity;
import com.interview.simulator.challenge.entity.SelectionType;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import com.interview.simulator.challenge.service.ChallengeTimePolicy;
import com.interview.simulator.exception.ApiException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.lang.reflect.RecordComponent;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AssistedGenerationService {

    private static final String STATUS_VALID = "VALID";
    private static final String STATUS_DUPLICATE = "DUPLICATE";
    private static final String STATUS_ERROR = "ERROR";
    private static final String VALID_JSON_ESCAPES = "\"\\/bfnrtu";

    private final AssistedPromptService assistedPromptService;
    private final ChallengeImportService challengeImportService;
    private final ChallengeIdentityService challengeIdentityService;
    private final int maxBatch;
    /** Mapper strict : FAIL_ON_UNKNOWN_PROPERTIES actif par defaut => champs inconnus refuses. */
    private final ObjectMapper strictMapper = new ObjectMapper();

    public AssistedGenerationService(
            AssistedPromptService assistedPromptService,
            ChallengeImportService challengeImportService,
            ChallengeIdentityService challengeIdentityService,
            @Value("${app.generation.assist.max-batch:20}") int maxBatch) {
        this.assistedPromptService = assistedPromptService;
        this.challengeImportService = challengeImportService;
        this.challengeIdentityService = challengeIdentityService;
        this.maxBatch = maxBatch;
    }

    public AssistedPromptResponse prompt(AssistedPromptRequest request) {
        requireBatchSize(request.count());
        return new AssistedPromptResponse(assistedPromptService.buildPrompt(request));
    }

    /** Analyse sans ecriture : dry-run du pipeline d'import + doublons internes au lot. */
    public AssistedAnalysisResponse analyze(String rawJson) {
        List<ImportedQuestion> questions = prepare(rawJson);
        ChallengeImportReport report =
                challengeImportService.importQuestions(questions, ContentStatus.DRAFT, true);
        return toAnalysis(questions, report);
    }

    public ChallengeImportReport importJson(String rawJson, ContentStatus status) {
        ContentStatus effectiveStatus = status == null ? ContentStatus.DRAFT : status;
        requireImportStatus(effectiveStatus);
        List<ImportedQuestion> questions = prepare(rawJson);
        return challengeImportService.importQuestions(questions, effectiveStatus, false);
    }

    private void requireImportStatus(ContentStatus status) {
        if (status != ContentStatus.DRAFT && status != ContentStatus.VALIDATED) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Le statut doit être DRAFT ou VALIDATED.");
        }
    }

    private List<ImportedQuestion> prepare(String rawJson) {
        JsonNode root = readRoot(repairJson(rawJson));
        ArrayNode questionsNode = questionsNode(root);
        List<ImportedQuestion> questions = new ArrayList<>(questionsNode.size());
        for (int index = 0; index < questionsNode.size(); index++) {
            questions.add(readQuestion(questionsNode.get(index), index));
        }
        if (questions.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "La liste « questions » est obligatoire.");
        }
        requireBatchSize(questions.size());
        return withServerExternalIds(questions);
    }

    private JsonNode readRoot(String rawJson) {
        JsonNode root;
        try {
            root = strictMapper.readTree(rawJson);
        } catch (JsonProcessingException e) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "JSON invalide" + location(e) + " : " + e.getOriginalMessage() + ".");
        }
        if (root == null || root.isNull()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "JSON vide.");
        }
        if (!root.isObject()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Structure invalide : le JSON doit être un objet contenant « questions ».");
        }
        List<String> unknown = unknownFields(root, recordFieldNames(ChallengeImportRequest.class));
        if (!unknown.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Champ(s) inconnu(s) à la racine : " + String.join(", ", unknown)
                            + ". Champs autorisés : " + String.join(", ", recordFieldNames(ChallengeImportRequest.class)) + ".");
        }
        return root;
    }

    private ArrayNode questionsNode(JsonNode root) {
        JsonNode questions = root.get("questions");
        if (questions == null || questions.isNull()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "La liste « questions » est obligatoire.");
        }
        if (!questions.isArray()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Structure invalide : le champ « questions » doit contenir une liste.");
        }
        return (ArrayNode) questions;
    }

    private ImportedQuestion readQuestion(JsonNode node, int index) {
        if (node == null || !node.isObject()) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Question #" + index + " : chaque question doit être un objet JSON.");
        }
        try {
            return strictMapper.treeToValue(node, ImportedQuestion.class);
        } catch (JsonProcessingException e) {
            throw questionError(index, e);
        }
    }

    private ApiException questionError(int index, JsonProcessingException e) {
        String prefix = "Question #" + index + " : ";
        if (e instanceof InvalidFormatException invalid) {
            return new ApiException(HttpStatus.BAD_REQUEST, prefix + invalidFormatDetail(invalid));
        }
        if (e instanceof UnrecognizedPropertyException unknown) {
            return new ApiException(HttpStatus.BAD_REQUEST, prefix + unknownPropertyDetail(unknown));
        }
        if (e instanceof JsonMappingException mapping) {
            return new ApiException(HttpStatus.BAD_REQUEST, prefix + mappingDetail(mapping));
        }
        return new ApiException(HttpStatus.BAD_REQUEST, prefix + "structure inattendue : un objet question est attendu.");
    }

    private String invalidFormatDetail(InvalidFormatException invalid) {
        String value = String.valueOf(invalid.getValue());
        if (invalid.getTargetType() != null && invalid.getTargetType().isEnum()) {
            String field = enumFieldName(invalid.getTargetType());
            if (field == null) {
                field = lastFieldName(invalid);
            }
            if (field != null) {
                return "champ « " + field + " » : valeur « " + value + " » inconnue. Valeurs autorisées : "
                        + enumValues(invalid.getTargetType()) + ".";
            }
            return "valeur « " + value + " » inconnue. Valeurs autorisées : "
                    + enumValues(invalid.getTargetType()) + ".";
        }
        String field = lastFieldName(invalid);
        if (field == null) {
            return "valeur « " + value + " » invalide.";
        }
        return "champ « " + field + " » : valeur « " + value + " » invalide.";
    }

    private String unknownPropertyDetail(UnrecognizedPropertyException unknown) {
        String field = unknown.getPropertyName();
        boolean insideOptions = pathContainsField(unknown, "options")
                || recordFieldNames(ImportedQuestion.class).contains(field);
        List<String> allowed = recordFieldNames(insideOptions ? ImportedOption.class : ImportedQuestion.class);
        return "champ « " + field + " » inconnu. Champs autorisés : " + String.join(", ", allowed) + ".";
    }

    private String mappingDetail(JsonMappingException e) {
        String field = lastFieldName(e);
        if (field == null) {
            return "structure inattendue : un objet question est attendu.";
        }
        return "champ « " + field + " » : structure invalide.";
    }

    private String enumFieldName(Class<?> enumType) {
        if (enumType == ChallengeType.class) {
            return "type";
        }
        if (enumType == DifficultyLevel.class) {
            return "difficulty";
        }
        if (enumType == SelectionType.class) {
            return "selectionType";
        }
        if (enumType == OptionSeverity.class) {
            return "severity";
        }
        return null;
    }

    private String enumValues(Class<?> enumType) {
        return Arrays.stream(enumType.getEnumConstants())
                .map(String::valueOf)
                .collect(Collectors.joining(", "));
    }

    private String lastFieldName(JsonMappingException e) {
        String field = null;
        for (JsonMappingException.Reference reference : e.getPath()) {
            if (reference.getFieldName() != null) {
                field = reference.getFieldName();
            }
        }
        return field;
    }

    private boolean pathContainsField(JsonMappingException e, String field) {
        return e.getPath().stream().anyMatch(reference -> field.equals(reference.getFieldName()));
    }

    private List<String> unknownFields(JsonNode node, List<String> allowed) {
        List<String> unknown = new ArrayList<>();
        node.fieldNames().forEachRemaining(name -> {
            if (!allowed.contains(name)) {
                unknown.add(name);
            }
        });
        return unknown;
    }

    private List<String> recordFieldNames(Class<?> recordType) {
        return Arrays.stream(recordType.getRecordComponents())
                .map(RecordComponent::getName)
                .toList();
    }

    private String location(JsonProcessingException e) {
        JsonLocation jsonLocation = e.getLocation();
        if (jsonLocation == null || jsonLocation.getLineNr() < 0) {
            return "";
        }
        return " (ligne " + jsonLocation.getLineNr() + ", colonne " + jsonLocation.getColumnNr() + ")";
    }

    private void requireBatchSize(int count) {
        if (count > maxBatch) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "La taille du lot dépasse la limite de " + maxBatch + " questions.");
        }
    }

    /** Les externalId du LLM sont ignores : le serveur en attribue de nouveaux et uniques. */
    private List<ImportedQuestion> withServerExternalIds(List<ImportedQuestion> questions) {
        List<ImportedQuestion> prepared = new ArrayList<>(questions.size());
        for (ImportedQuestion question : questions) {
            prepared.add(new ImportedQuestion(
                    challengeIdentityService.generateExternalId(),
                    question.title(),
                    question.type(),
                    question.difficulty(),
                    question.selectionType(),
                    question.context(),
                    question.question(),
                    question.codeSnippet(),
                    question.codeLanguage(),
                    question.explanation(),
                    question.revealedInformation(),
                    question.tradeoff(),
                    ChallengeTimePolicy.normalize(question.type(), question.estimatedTimeSeconds()),
                    question.points(),
                    question.categories(),
                    question.skills(),
                    question.profiles(),
                    question.scenario(),
                    question.stepOrder(),
                    question.options()));
        }
        return prepared;
    }

    private AssistedAnalysisResponse toAnalysis(List<ImportedQuestion> questions, ChallengeImportReport report) {
        Map<Integer, String> errorReasons = new HashMap<>();
        report.errors().forEach(error -> errorReasons.put(error.index(), error.reason()));
        Map<Integer, ChallengeImportReport.DuplicateEntry> dbDuplicates = new HashMap<>();
        report.duplicates().forEach(duplicate -> dbDuplicates.put(duplicate.index(), duplicate));

        // Doublons exacts a l'interieur du lot : le mecanisme de hash existe en base,
        // mais rien n'etant ecrit en dry-run, ils sont detectes ici (titre+question normalises).
        Map<String, Integer> firstIndexByKey = new HashMap<>();
        Map<Integer, Integer> intraLotDuplicateOf = new HashMap<>();
        for (int index = 0; index < questions.size(); index++) {
            String key = normalizedKey(questions.get(index));
            Integer firstIndex = firstIndexByKey.putIfAbsent(key, index);
            if (firstIndex != null) {
                intraLotDuplicateOf.put(index, firstIndex);
            }
        }

        List<QuestionPreview> previews = new ArrayList<>(questions.size());
        int valid = 0;
        int duplicates = 0;
        int errors = 0;
        Map<String, Integer> byType = new HashMap<>();
        Map<String, Integer> byDifficulty = new HashMap<>();
        Map<String, Integer> byProfile = new HashMap<>();
        Map<String, Integer> byCategory = new HashMap<>();
        for (int index = 0; index < questions.size(); index++) {
            ImportedQuestion question = questions.get(index);
            String status;
            String reason = null;
            if (errorReasons.containsKey(index)) {
                status = STATUS_ERROR;
                reason = errorReasons.get(index);
                errors++;
            } else if (dbDuplicates.containsKey(index)) {
                status = STATUS_DUPLICATE;
                ChallengeImportReport.DuplicateEntry duplicate = dbDuplicates.get(index);
                reason = "Existe déjà en base (question #" + duplicate.existingId() + " « "
                        + duplicate.existingTitle() + " »).";
                duplicates++;
            } else if (intraLotDuplicateOf.containsKey(index)) {
                status = STATUS_DUPLICATE;
                reason = "Doublon interne : identique à la question à l'index "
                        + intraLotDuplicateOf.get(index) + " du lot.";
                duplicates++;
            } else {
                status = STATUS_VALID;
                valid++;
                if (question.type() != null) {
                    byType.merge(question.type().name(), 1, Integer::sum);
                }
                if (question.difficulty() != null) {
                    byDifficulty.merge(question.difficulty().name(), 1, Integer::sum);
                }
                if (question.profiles() != null) {
                    question.profiles().forEach(profile -> byProfile.merge(profile, 1, Integer::sum));
                }
                if (question.categories() != null) {
                    question.categories().forEach(category -> byCategory.merge(category, 1, Integer::sum));
                }
            }
            previews.add(new QuestionPreview(
                    index,
                    question.title(),
                    status,
                    reason,
                    question.type() == null ? null : question.type().name(),
                    question.difficulty() == null ? null : question.difficulty().name(),
                    question.profiles() == null ? List.of() : List.copyOf(question.profiles()),
                    question.categories() == null ? List.of() : List.copyOf(question.categories())));
        }
        List<String> warnings = report.warnings().stream()
                .map(warning -> "Question #" + warning.index() + " (« " + warning.externalIdOrTitle()
                        + " ») : " + warning.message())
                .toList();
        return new AssistedAnalysisResponse(
                questions.size(), valid, duplicates, errors, warnings,
                byType, byDifficulty, byProfile, byCategory, previews);
    }

    private String normalizedKey(ImportedQuestion question) {
        String title = question.title() == null ? "" : question.title().trim().toLowerCase(Locale.ROOT);
        String text = question.question() == null ? "" : question.question().trim().toLowerCase(Locale.ROOT);
        return title + "||" + text;
    }

    private String repairJson(String rawJson) {
        StringBuilder repaired = new StringBuilder(rawJson.length());
        boolean insideString = false;
        for (int index = 0; index < rawJson.length(); index++) {
            char current = rawJson.charAt(index);
            if (!insideString) {
                repaired.append(current);
                if (current == '"') {
                    insideString = true;
                }
                continue;
            }
            if (current == '\\') {
                index = appendEscape(repaired, rawJson, index);
                continue;
            }
            if (current == '"' && !endsString(rawJson, index)) {
                repaired.append("\\\"");
                continue;
            }
            if (current == '"') {
                insideString = false;
            }
            repaired.append(current);
        }
        return repaired.toString();
    }

    private int appendEscape(StringBuilder repaired, String rawJson, int index) {
        if (index + 1 >= rawJson.length()) {
            return index;
        }
        char escaped = rawJson.charAt(index + 1);
        if (VALID_JSON_ESCAPES.indexOf(escaped) < 0) {
            repaired.append(escaped);
        } else {
            repaired.append('\\').append(escaped);
        }
        return index + 1;
    }

    private boolean endsString(String rawJson, int index) {
        for (int next = index + 1; next < rawJson.length(); next++) {
            char current = rawJson.charAt(next);
            if (!Character.isWhitespace(current)) {
                return current == ',' || current == ':' || current == '}' || current == ']';
            }
        }
        return true;
    }
}