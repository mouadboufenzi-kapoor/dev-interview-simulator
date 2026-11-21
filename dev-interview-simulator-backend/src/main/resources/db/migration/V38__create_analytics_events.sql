CREATE TABLE analytics_events (
    id BIGSERIAL PRIMARY KEY,
    visitor_id VARCHAR(64) NOT NULL,
    event_name VARCHAR(64) NOT NULL,
    simulation_id BIGINT,
    user_id BIGINT,
    mode VARCHAR(32),
    difficulty VARCHAR(32),
    question_index INTEGER,
    device_type VARCHAR(16),
    viewport_width INTEGER,
    referrer TEXT,
    utm_source VARCHAR(255),
    utm_medium VARCHAR(255),
    utm_campaign VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_analytics_events_name_created
    ON analytics_events (event_name, created_at);

CREATE INDEX idx_analytics_events_visitor
    ON analytics_events (visitor_id);
