package com.interview.simulator.analytics.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.interview.simulator.analytics.service.AnalyticsEventService;
import com.interview.simulator.analytics.service.AnalyticsRateLimiter;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/events")
public class AnalyticsEventController {

    private final AnalyticsEventService analyticsEventService;
    private final AnalyticsRateLimiter rateLimiter;

    public AnalyticsEventController(
            AnalyticsEventService analyticsEventService,
            AnalyticsRateLimiter rateLimiter) {
        this.analyticsEventService = analyticsEventService;
        this.rateLimiter = rateLimiter;
    }

    @PostMapping
    public ResponseEntity<Void> record(
            @RequestBody(required = false) JsonNode payload,
            HttpServletRequest request) {
        if (rateLimiter.allow(request.getRemoteAddr())) {
            analyticsEventService.record(payload);
        }
        return ResponseEntity.noContent().build();
    }
}
