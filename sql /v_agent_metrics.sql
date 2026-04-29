CREATE OR REPLACE VIEW connect.v_agent_metrics AS

WITH base AS (

    -- =========================
    -- Base call data
    -- =========================
    SELECT
        *
    FROM connect.f_calls
    WHERE CAST(agent_conn AS DATE) IS NOT NULL

),

enriched AS (

    -- =========================
    -- Join dimensions
    -- =========================
    SELECT
        c.*,
        u.user_name,
        u.user_lastname,
        u.user_email,
        q.queue_name,
        l.title,
        l.cm_job_title__c,
        l.department__c,

        -- Full name
        u.user_name || ' ' || u.user_lastname AS user_complete_name,

        -- Time components
        CAST(c.agent_conn AS DATE) AS call_date,
        EXTRACT(MONTH FROM c.agent_conn) AS call_month,
        EXTRACT(DAY FROM c.agent_conn) AS call_day,
        EXTRACT(HOUR FROM c.agent_conn) AS call_hour

    FROM base c
    LEFT JOIN connect.dim_users u
        ON c.agent_id = u.user_id
    LEFT JOIN connect.dim_queues q
        ON c.queue_id = q.queue_id
    LEFT JOIN litify.dim_users l
        ON c.agent_username = l.username
),

metrics AS (

    -- =========================
    -- KPI calculations
    -- =========================
    SELECT

        call_date,
        call_month,
        call_day,
        call_hour,

        user_name,
        user_lastname,
        user_complete_name,
        user_email,

        title,
        cm_job_title__c AS cm_job_title,
        department__c AS department,

        queue_name,

        -- =========================
        -- Interaction metrics
        -- =========================
        SUM(agent_interact_duration) AS total_agent_interaction,
        ROUND(SUM(agent_interact_duration) / 3600.0, 2) AS total_agent_interaction_hours,
        SUM(agent_interact_duration) / 60::INT AS total_agent_interaction_minutes,
        AVG(agent_interact_duration) AS avg_agent_interaction,

        -- =========================
        -- Contact duration
        -- =========================
        SUM(EXTRACT(EPOCH FROM disconn_time - agent_conn)) AS total_contact_duration,
        ROUND(SUM(EXTRACT(EPOCH FROM disconn_time - agent_conn)) / 3600.0, 2) AS total_contact_duration_hours,
        SUM(EXTRACT(EPOCH FROM disconn_time - agent_conn)) / 60::INT AS total_contact_duration_minutes,
        AVG(EXTRACT(EPOCH FROM disconn_time - agent_conn)) AS avg_contact_duration,

        -- =========================
        -- After call work (AFW)
        -- =========================
        SUM(agent_afw_duration) AS total_agent_afw_duration,
        ROUND(SUM(agent_afw_duration) / 3600.0, 2) AS total_agent_afw_duration_hours,
        SUM(agent_afw_duration) / 60::INT AS total_agent_afw_duration_minutes,
        AVG(agent_afw_duration) AS avg_agent_afw_duration,

        -- =========================
        -- Hold metrics
        -- =========================
        MIN(agent_longest_hold) AS min_agent_longest_hold,
        MAX(agent_longest_hold) AS max_agent_longest_hold,

        SUM(customer_hold_duration) AS total_customer_hold_duration,
        ROUND(SUM(customer_hold_duration) / 3600.0, 2) AS total_customer_hold_duration_hours,
        SUM(customer_hold_duration) / 60::INT AS total_customer_hold_duration_minutes,
        AVG(customer_hold_duration) AS avg_customer_hold_duration,

        -- =========================
        -- Volume metrics
        -- =========================
        COUNT(DISTINCT customer_phone) AS unique_customers,
        COUNT(*) AS total_calls,
        SUM(agent_conn_att) AS total_agent_conn_attempts,

        -- =========================
        -- Call type classification
        -- =========================
        SUM(CASE WHEN init_method = 'INBOUND' THEN 1 ELSE 0 END) AS inbound_calls,
        SUM(CASE WHEN init_method = 'OUTBOUND' THEN 1 ELSE 0 END) AS outbound_calls,
        SUM(CASE WHEN init_method = 'TRANSFER' THEN 1 ELSE 0 END) AS transfer_calls,
        SUM(CASE WHEN init_method = 'CALLBACK' THEN 1 ELSE 0 END) AS callback_calls,

        -- =========================
        -- Duration buckets
        -- =========================
        SUM(CASE WHEN agent_interact_duration BETWEEN 0 AND 120 THEN 1 ELSE 0 END) AS duration_less_2_min,
        SUM(CASE WHEN agent_interact_duration BETWEEN 120 AND 300 THEN 1 ELSE 0 END) AS duration_2_to_5_min,
        SUM(CASE WHEN agent_interact_duration BETWEEN 360 AND 1200 THEN 1 ELSE 0 END) AS duration_6_to_20_min,
        SUM(CASE WHEN agent_interact_duration BETWEEN 1260 AND 2700 THEN 1 ELSE 0 END) AS duration_21_to_45_min,
        SUM(CASE WHEN agent_interact_duration BETWEEN 2760 AND 5400 THEN 1 ELSE 0 END) AS duration_46_to_90_min,
        SUM(CASE WHEN agent_interact_duration > 5400 THEN 1 ELSE 0 END) AS duration_over_90_min,

        -- =========================
        -- Shift analysis
        -- =========================
        SUM(CASE
            WHEN EXTRACT(HOUR FROM agent_conn) BETWEEN 9 AND 13
            AND EXTRACT(HOUR FROM disconn_time) <= 13
            THEN 1 ELSE 0 END
        ) AS calls_9_13,

        SUM(CASE
            WHEN EXTRACT(HOUR FROM agent_conn) BETWEEN 13 AND 17
            AND EXTRACT(HOUR FROM disconn_time) <= 17
            THEN 1 ELSE 0 END
        ) AS calls_13_17,

        SUM(CASE
            WHEN EXTRACT(HOUR FROM agent_conn) >= 17
            THEN 1 ELSE 0 END
        ) AS calls_after_17

    FROM enriched
    GROUP BY
        call_date,
        call_month,
        call_day,
        call_hour,
        user_name,
        user_lastname,
        user_complete_name,
        user_email,
        title,
        cm_job_title,
        department,
        queue_name

)

SELECT *
FROM metrics;
