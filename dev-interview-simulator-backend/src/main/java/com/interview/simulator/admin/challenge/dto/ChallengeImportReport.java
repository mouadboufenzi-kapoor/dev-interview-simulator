package com.interview.simulator.admin.challenge.dto;

import java.util.List;

public record ChallengeImportReport(
        boolean dryRun,
        PlannedCounts planned,
        ExecutedCounts executed,
        List<DuplicateEntry> duplicates,
        List<ImportError> errors,
        List<ImportWarning> warnings
) {

    public record PlannedCounts(int created, int updated) {
    }

    public record ExecutedCounts(int created, int updated) {
    }

    public record DuplicateEntry(int index, String externalIdOrTitle, Long existingId, String existingTitle) {
    }

    public record ImportError(int index, String externalIdOrTitle, String reason) {
    }

    public record ImportWarning(int index, String externalIdOrTitle, String message) {
    }
}
