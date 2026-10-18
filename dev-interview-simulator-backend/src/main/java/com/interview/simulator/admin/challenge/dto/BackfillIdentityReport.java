package com.interview.simulator.admin.challenge.dto;

import java.util.List;

public record BackfillIdentityReport(int processed, List<DuplicateGroup> duplicates) {

    public record DuplicateGroup(String contentHash, List<ChallengeReference> challenges) {
    }

    public record ChallengeReference(Long id, String title) {
    }
}
