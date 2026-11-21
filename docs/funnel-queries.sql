WITH periods AS (
    SELECT INTERVAL '7 days' AS span
    UNION ALL
    SELECT INTERVAL '30 days'
),
stages AS (
    SELECT
        p.span,
        e.visitor_id,
        MIN(e.created_at) FILTER (WHERE e.event_name = 'landing_viewed') AS landing_at,
        MIN(e.created_at) FILTER (WHERE e.event_name = 'simulation_started') AS started_at,
        MIN(e.created_at) FILTER (WHERE e.event_name = 'simulation_completed') AS completed_at,
        MIN(e.created_at) FILTER (WHERE e.event_name = 'result_viewed') AS result_at,
        MIN(e.created_at) FILTER (WHERE e.event_name = 'guest_cta_viewed') AS cta_viewed_at,
        MIN(e.created_at) FILTER (WHERE e.event_name = 'guest_cta_clicked') AS cta_clicked_at,
        MIN(e.created_at) FILTER (WHERE e.event_name = 'signup_completed') AS signup_at
    FROM analytics_events e
    CROSS JOIN periods p
    WHERE e.created_at >= NOW() - p.span
    GROUP BY p.span, e.visitor_id
)
SELECT
    span,
    COUNT(*) FILTER (WHERE landing_at IS NOT NULL) AS landing_viewed,
    COUNT(*) FILTER (WHERE started_at >= landing_at) AS simulation_started,
    COUNT(*) FILTER (WHERE completed_at >= started_at) AS simulation_completed,
    COUNT(*) FILTER (WHERE result_at >= completed_at) AS result_viewed,
    COUNT(*) FILTER (WHERE cta_viewed_at >= result_at) AS guest_cta_viewed,
    COUNT(*) FILTER (WHERE cta_clicked_at >= cta_viewed_at) AS guest_cta_clicked,
    COUNT(*) FILTER (WHERE signup_at >= cta_clicked_at) AS signup_completed
FROM stages
GROUP BY span
ORDER BY span;


SELECT
    question_index,
    COUNT(*) AS abandonments,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_percent
FROM analytics_events
WHERE event_name = 'simulation_abandoned'
  AND question_index IS NOT NULL
GROUP BY question_index
ORDER BY question_index;


WITH sessions AS (
    SELECT
        simulation_id,
        MAX(device_type) FILTER (WHERE event_name = 'simulation_started') AS device_type,
        COUNT(*) FILTER (WHERE event_name = 'simulation_started') AS started,
        COUNT(*) FILTER (WHERE event_name = 'simulation_completed') AS completed
    FROM analytics_events
    WHERE simulation_id IS NOT NULL
      AND event_name IN ('simulation_started', 'simulation_completed')
    GROUP BY simulation_id
)
SELECT
    COALESCE(device_type, 'unknown') AS device_type,
    COUNT(*) FILTER (WHERE started > 0) AS started_sessions,
    COUNT(*) FILTER (WHERE completed > 0 AND started > 0) AS completed_sessions,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE completed > 0 AND started > 0)
        / NULLIF(COUNT(*) FILTER (WHERE started > 0), 0),
        2
    ) AS completion_rate
FROM sessions
GROUP BY COALESCE(device_type, 'unknown')
ORDER BY started_sessions DESC;


WITH visitors AS (
    SELECT
        visitor_id,
        COALESCE(MAX(utm_source), 'direct') AS utm_source,
        BOOL_OR(event_name = 'landing_viewed') AS landed,
        BOOL_OR(event_name = 'signup_completed') AS signed_up
    FROM analytics_events
    GROUP BY visitor_id
)
SELECT
    utm_source,
    COUNT(*) FILTER (WHERE landed) AS visitors,
    COUNT(*) FILTER (WHERE signed_up) AS signups,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE signed_up)
        / NULLIF(COUNT(*) FILTER (WHERE landed), 0),
        2
    ) AS conversion_rate
FROM visitors
GROUP BY utm_source
ORDER BY signups DESC, visitors DESC;
