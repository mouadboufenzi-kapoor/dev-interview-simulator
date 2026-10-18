package com.interview.simulator.admin.generation.assist.dto;

import java.util.List;
import java.util.Map;


public record AssistedAnalysisResponse(
        int total,
        int valid,
        int duplicates,
        int errors,
        List<String> warnings,
        Map<String, Integer> byType,
        Map<String, Integer> byDifficulty,
        Map<String, Integer> byProfile,
        Map<String, Integer> byCategory,
        List<QuestionPreview> questions) {


    public record QuestionPreview(
            int index,
            String title,
            String status,
            String reason,
            String type,
            String difficulty,
            List<String> profiles,
            List<String> categories) {
    }
}