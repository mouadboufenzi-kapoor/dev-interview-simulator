package com.interview.simulator.analytics.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.interview.simulator.analytics.dto.AnalyticsEventRequest;
import com.interview.simulator.analytics.entity.AnalyticsEvent;
import com.interview.simulator.analytics.repository.AnalyticsEventRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.service.UserResolver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class AnalyticsEventService {

    private static final Logger log = LoggerFactory.getLogger(AnalyticsEventService.class);

    private static final int MAX_BATCH_SIZE = 10;
    private static final int MAX_VISITOR_ID_LENGTH = 64;
    private static final int MAX_LABEL_LENGTH = 32;
    private static final int MAX_REFERRER_LENGTH = 2048;
    private static final int MAX_UTM_LENGTH = 255;
    private static final int MAX_METADATA_LENGTH = 2000;
    private static final int MAX_VIEWPORT_WIDTH = 10000;

    private static final Set<String> ALLOWED_EVENTS = Set.of(
            "landing_viewed",
            "profile_selected",
            "config_mode_selected",
            "config_level_selected",
            "config_theme_toggled",
            "config_personalize_opened",
            "simulation_started",
            "question_viewed",
            "question_answered",
            "simulation_completed",
            "simulation_abandoned",
            "result_viewed",
            "guest_cta_viewed",
            "guest_cta_clicked",
            "result_locked_clicked",
            "placement_continue_clicked",
            "auth_modal_opened",
            "auth_method_chosen",
            "signup_completed",
            "login_completed"
    );

    private static final Set<String> ALLOWED_DEVICE_TYPES = Set.of("mobile", "tablet", "desktop");

    private final AnalyticsEventRepository repository;
    private final ObjectMapper objectMapper;
    private final UserResolver userResolver;

    public AnalyticsEventService(
            AnalyticsEventRepository repository,
            ObjectMapper objectMapper,
            UserResolver userResolver) {
        this.repository = repository;
        this.objectMapper = objectMapper;
        this.userResolver = userResolver;
    }

    @Transactional
    public void record(JsonNode payload) {
        List<AnalyticsEventRequest> requests = readRequests(payload);
        if (requests.isEmpty()) {
            return;
        }
        User user = userResolver.currentAuthenticatedOrNull().orElse(null);
        List<AnalyticsEvent> events = requests.stream()
                .filter(this::isValid)
                .map(request -> toEntity(request, user))
                .toList();
        if (!events.isEmpty()) {
            repository.saveAll(events);
        }
    }

    private List<AnalyticsEventRequest> readRequests(JsonNode payload) {
        if (payload == null || payload.isNull()) {
            return List.of();
        }
        List<AnalyticsEventRequest> requests = new ArrayList<>();
        if (payload.isArray()) {
            for (JsonNode node : payload) {
                if (requests.size() >= MAX_BATCH_SIZE) {
                    break;
                }
                addRequest(requests, node);
            }
            return requests;
        }
        addRequest(requests, payload);
        return requests;
    }

    private void addRequest(List<AnalyticsEventRequest> requests, JsonNode node) {
        try {
            requests.add(objectMapper.treeToValue(node, AnalyticsEventRequest.class));
        } catch (JsonProcessingException exception) {
            log.warn("Événement analytics ignoré : payload invalide.");
        }
    }

    private boolean isValid(AnalyticsEventRequest request) {
        return request != null
                && request.visitorId() != null
                && !request.visitorId().isBlank()
                && request.eventName() != null
                && ALLOWED_EVENTS.contains(request.eventName());
    }

    private AnalyticsEvent toEntity(AnalyticsEventRequest request, User user) {
        AnalyticsEvent event = new AnalyticsEvent();
        event.setVisitorId(limit(request.visitorId(), MAX_VISITOR_ID_LENGTH));
        event.setEventName(request.eventName());
        event.setSimulationId(positiveOrNull(request.simulationId()));
        event.setUserId(user != null ? user.getId() : null);
        event.setMode(limit(request.mode(), MAX_LABEL_LENGTH));
        event.setDifficulty(limit(request.difficulty(), MAX_LABEL_LENGTH));
        event.setQuestionIndex(nonNegativeOrNull(request.questionIndex()));
        event.setDeviceType(request.deviceType() != null
                && ALLOWED_DEVICE_TYPES.contains(request.deviceType())
                ? request.deviceType()
                : null);
        event.setViewportWidth(viewportWidth(request.viewportWidth()));
        event.setReferrer(limit(request.referrer(), MAX_REFERRER_LENGTH));
        event.setUtmSource(limit(request.utmSource(), MAX_UTM_LENGTH));
        event.setUtmMedium(limit(request.utmMedium(), MAX_UTM_LENGTH));
        event.setUtmCampaign(limit(request.utmCampaign(), MAX_UTM_LENGTH));
        event.setMetadata(limitedMetadata(request.metadata()));
        return event;
    }

    private String limit(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        if (trimmed.isEmpty()) {
            return null;
        }
        return trimmed.length() <= maxLength ? trimmed : trimmed.substring(0, maxLength);
    }

    private Long positiveOrNull(Long value) {
        return value != null && value > 0 ? value : null;
    }

    private Integer nonNegativeOrNull(Integer value) {
        return value != null && value >= 0 ? value : null;
    }

    private Integer viewportWidth(Integer value) {
        return value != null && value > 0 && value <= MAX_VIEWPORT_WIDTH ? value : null;
    }

    private Map<String, Object> limitedMetadata(Map<String, Object> metadata) {
        if (metadata == null || metadata.isEmpty()) {
            return null;
        }
        try {
            String serialized = objectMapper.writeValueAsString(metadata);
            return serialized.length() <= MAX_METADATA_LENGTH ? metadata : null;
        } catch (JsonProcessingException exception) {
            return null;
        }
    }
}
