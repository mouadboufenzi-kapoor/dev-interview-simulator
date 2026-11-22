package com.interview.simulator.analytics.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "analytics_events")
public class AnalyticsEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "visitor_id", nullable = false, length = 64)
    private String visitorId;

    @Column(name = "event_name", nullable = false, length = 64)
    private String eventName;

    @Column(name = "simulation_id")
    private Long simulationId;

    @Column(name = "user_id")
    private Long userId;

    @Column(length = 32)
    private String mode;

    @Column(length = 32)
    private String difficulty;

    @Column(name = "question_index")
    private Integer questionIndex;

    @Column(name = "device_type", length = 16)
    private String deviceType;

    @Column(name = "viewport_width")
    private Integer viewportWidth;

    @Column(columnDefinition = "text")
    private String referrer;

    @Column(name = "utm_source", length = 255)
    private String utmSource;

    @Column(name = "utm_medium", length = 255)
    private String utmMedium;

    @Column(name = "utm_campaign", length = 255)
    private String utmCampaign;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> metadata;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public String getVisitorId() { return visitorId; }
    public void setVisitorId(String visitorId) { this.visitorId = visitorId; }
    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }
    public Long getSimulationId() { return simulationId; }
    public void setSimulationId(Long simulationId) { this.simulationId = simulationId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getMode() { return mode; }
    public void setMode(String mode) { this.mode = mode; }
    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }
    public Integer getQuestionIndex() { return questionIndex; }
    public void setQuestionIndex(Integer questionIndex) { this.questionIndex = questionIndex; }
    public String getDeviceType() { return deviceType; }
    public void setDeviceType(String deviceType) { this.deviceType = deviceType; }
    public Integer getViewportWidth() { return viewportWidth; }
    public void setViewportWidth(Integer viewportWidth) { this.viewportWidth = viewportWidth; }
    public String getReferrer() { return referrer; }
    public void setReferrer(String referrer) { this.referrer = referrer; }
    public String getUtmSource() { return utmSource; }
    public void setUtmSource(String utmSource) { this.utmSource = utmSource; }
    public String getUtmMedium() { return utmMedium; }
    public void setUtmMedium(String utmMedium) { this.utmMedium = utmMedium; }
    public String getUtmCampaign() { return utmCampaign; }
    public void setUtmCampaign(String utmCampaign) { this.utmCampaign = utmCampaign; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public Map<String, Object> getMetadata() { return metadata; }
    public void setMetadata(Map<String, Object> metadata) { this.metadata = metadata; }
}
