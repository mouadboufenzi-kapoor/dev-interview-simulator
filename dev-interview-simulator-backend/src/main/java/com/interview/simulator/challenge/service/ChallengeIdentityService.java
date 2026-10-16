package com.interview.simulator.challenge.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.ChallengeType;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Comparator;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ChallengeIdentityService {

    private static final String HASH_ALGORITHM = "SHA-256";
    private static final String FIELD_SEPARATOR = "|";
    private static final String ADMIN_EXTERNAL_ID_PREFIX = "admin-";
    private static final String LEGACY_EXTERNAL_ID_PREFIX = "legacy-";
    private static final String CORRECT_TRUE = "true";
    private static final String CORRECT_FALSE = "false";
    private static final String WHITESPACE_PATTERN = "\\s+";
    private static final String WHITESPACE_REPLACEMENT = " ";

    public String generateExternalId() {
        return ADMIN_EXTERNAL_ID_PREFIX + UUID.randomUUID();
    }

    public String legacyExternalId(Long challengeId) {
        return LEGACY_EXTERNAL_ID_PREFIX + challengeId;
    }

    public String contentHash(Challenge challenge) {
        String payload = String.join(FIELD_SEPARATOR,
                normalize(challenge.getType() != null ? challenge.getType().name() : null),
                normalize(challenge.getContext()),
                normalize(challenge.getQuestion()),
                normalize(challenge.getCodeSnippet()),
                optionsPayload(challenge),
                scenarioPayload(challenge));
        return sha256Hex(payload);
    }

    private String optionsPayload(Challenge challenge) {
        return sortedOptions(challenge).stream()
                .map(this::optionPayload)
                .collect(Collectors.joining(FIELD_SEPARATOR));
    }

    private List<ChallengeOption> sortedOptions(Challenge challenge) {
        List<ChallengeOption> options = challenge.getOptions();
        if (challenge.getType() == ChallengeType.SEQUENTIAL_REASONING) {
            return options.stream()
                    .sorted(Comparator.comparingInt(ChallengeOption::getDisplayOrder))
                    .toList();
        }
        return options.stream()
                .sorted(Comparator.comparing((ChallengeOption option) -> normalize(option.getContent()))
                        .thenComparing(ChallengeOption::isCorrect))
                .toList();
    }

    private String optionPayload(ChallengeOption option) {
        return normalize(option.getContent())
                + FIELD_SEPARATOR
                + (option.isCorrect() ? CORRECT_TRUE : CORRECT_FALSE);
    }

    private String scenarioPayload(Challenge challenge) {
        if (challenge.getType() != ChallengeType.ARCHITECTURE || challenge.getScenario() == null) {
            return "";
        }
        return normalize(challenge.getScenario().getTitle());
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.trim()
                .replaceAll(WHITESPACE_PATTERN, WHITESPACE_REPLACEMENT)
                .toLowerCase(Locale.ROOT);
    }

    private String sha256Hex(String payload) {
        try {
            MessageDigest digest = MessageDigest.getInstance(HASH_ALGORITHM);
            return HexFormat.of().formatHex(digest.digest(payload.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("Algorithme de hash indisponible : " + HASH_ALGORITHM, e);
        }
    }
}
