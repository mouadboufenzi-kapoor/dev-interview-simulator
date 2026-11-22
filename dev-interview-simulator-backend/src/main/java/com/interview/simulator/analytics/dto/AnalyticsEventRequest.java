package com.interview.simulator.analytics.dto;

import java.util.Map;

public record AnalyticsEventRequest(
        String visitorId,
        String eventName,
        Long simulationId,
        String mode,
        String difficulty,
        Integer questionIndex,
        String deviceType,
        Integer viewportWidth,
        String referrer,
        String utmSource,
        String utmMedium,
        String utmCampaign,
        Map<String, Object> metadata
) {
}
