package com.interview.simulator.admin.generation.assist.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest;
import com.interview.simulator.admin.challenge.dto.ChallengeImportRequest.ImportedQuestion;
import com.interview.simulator.admin.challenge.service.ChallengeImportService;
import com.interview.simulator.admin.generation.assist.dto.AssistedAnalysisResponse;
import com.interview.simulator.admin.generation.assist.dto.AssistedAnalysisResponse.QuestionPreview;
import com.interview.simulator.admin.generation.assist.dto.AssistedPromptRequest;
import com.interview.simulator.admin.generation.assist.dto.AssistedPromptResponse;
import com.interview.simulator.challenge.entity.ContentStatus;
import com.interview.simulator.challenge.service.ChallengeIdentityService;
import com.interview.simulator.exception.ApiException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class AssistedGenerationService {

    private static final String STATUS_VALID = "VALID";
    private static final String STATUS_DUPLICATE = "DUPLICATE";
    private static final String STATUS_ERROR = "ERROR";

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

    /** Import revalide cote serveur (parse strict + pipeline complet), en DRAFT. */
    public ChallengeImportReport importJson(String rawJson) {
        List<ImportedQuestion> questions = prepare(rawJson);
        return challengeImportService.importQuestions(questions, ContentStatus.DRAFT, false);
    }

    private List<ImportedQuestion> prepare(String rawJson) {
        ChallengeImportRequest request;
        try {
            request = strictMapper.readValue(rawJson, ChallengeImportRequest.class);
        } catch (JsonProcessingException e) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "JSON illisible ou contenant des champs inconnus : " + e.getOriginalMessage());
        }
        if (request.questions() == null || request.questions().isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "La liste « questions » est obligatoire.");
        }
        requireBatchSize(request.questions().size());
        return withServerExternalIds(request.questions());
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
                    question.estimatedTimeSeconds(),
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
}