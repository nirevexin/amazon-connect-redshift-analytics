CREATE OR REPLACE VIEW connect.v_metric_data AS

/* ============================================================
   Amazon Connect Agent Performance Semantic Layer
   Purpose:
   Reporting-ready Redshift view for operational analytics,
   workforce management, queue performance, and BI dashboards.
   ============================================================ */

WITH base_metrics AS (

    -- Core fact table containing raw agent operational metrics
    SELECT *
    FROM connect.f_agent_metrics
    -- Optional historical filter for reporting windows:
    -- WHERE start_time >= '2025-01-01'

),

user_dim AS (

    -- User dimension table for agent identity enrichment
    SELECT
        user_id,
        user_name,
        user_lastname,
        user_email
    FROM connect.dim_users

),

final_metrics AS (

    SELECT

        /* =========================
           Date Dimensions
           ========================= */
        DATE(m.start_time) AS metric_date,
        EXTRACT(YEAR FROM m.start_time) AS metric_year,
        EXTRACT(MONTH FROM m.start_time) AS metric_month,
        EXTRACT(DAY FROM m.start_time) AS metric_day,
        EXTRACT(HOUR FROM m.start_time) AS metric_hour,

        /* =========================
           Agent Dimensions
           ========================= */
        (u.user_name || ' ' || u.user_lastname) AS user_full_name,
        u.user_email,

        m.start_time,
        m.end_time,

        /* =========================
           Agent Productivity Metrics
           ========================= */
        ROUND(m.agent_answer_rate, 2) AS agent_answer_rate,
        ROUND(m.agent_non_response, 2) AS agent_non_response,
        ROUND(m.agent_occupancy, 2) AS agent_occupancy,
        ROUND(m.avg_dials_per_minute, 2) AS avg_dials_per_minute,
        ROUND(m.sum_connecting_time_agent / 60, 2) AS sum_connecting_time_agent_min,

        /* =========================
           Talk Time Metrics
           ========================= */
        m.sum_retry_callback_attempts,
        m.percent_talk_time_customer,
        ROUND(m.avg_talk_time_customer / 60, 2) AS avg_talk_time_customer_min,
        m.percent_talk_time_agent,
        ROUND(m.avg_talk_time_agent / 60, 2) AS avg_talk_time_agent_min,
        m.percent_talk_time,
        ROUND(m.avg_talk_time / 60, 2) AS avg_talk_time_min,

        /* =========================
           Queue Performance Metrics
           ========================= */
        m.contacts_queued,
        m.contacts_queued_by_enqueue,
        ROUND(m.max_queued_time / 60, 2) AS max_queued_time_min,
        m.contacts_transferred_out_from_queue,
        ROUND(m.avg_queue_answer_time / 60, 2) AS avg_queue_answer_time_min,
        ROUND(m.abandonment_rate, 2) AS abandonment_rate,

        /* =========================
           Contact Lifecycle Metrics
           ========================= */
        m.contacts_created,
        m.sum_contacts_disconnected,
        ROUND(m.avg_active_time / 60, 2) AS avg_active_time_min,
        ROUND(m.avg_non_talk_time / 60, 2) AS avg_non_talk_time_min,
        ROUND(m.avg_interruption_time_agent / 60, 2) AS avg_interruption_time_agent_min,

        /* =========================
           Transfer & Hold Metrics
           ========================= */
        m.delivery_attempts,
        m.contacts_transferred_out,
        m.contacts_transferred_out_internal,
        m.contacts_transferred_out_external,
        m.contacts_put_on_hold,
        ROUND(m.avg_holds, 2) AS avg_holds,
        ROUND(m.sum_hold_time / 60, 2) AS sum_hold_time_min,
        m.contacts_hold_abandons,
        m.contacts_on_hold_agent_disconnect,
        m.contacts_on_hold_customer_disconnect,

        /* =========================
           Contact Handling Metrics
           ========================= */
        m.contacts_handled,
        ROUND(m.avg_handle_time / 60, 2) AS avg_handle_time_min,
        ROUND(m.sum_handle_time / 60, 2) AS sum_handle_time_min,
        ROUND(m.avg_interaction_time / 60, 2) AS avg_interaction_time_min,
        ROUND(m.sum_interaction_time / 60, 2) AS sum_interaction_time_min,
        ROUND(m.avg_contact_duration / 60, 2) AS avg_contact_duration_min,
        ROUND(m.sum_interaction_and_hold_time / 60, 2) AS sum_interaction_and_hold_time_min,

        /* =========================
           After Contact Work Metrics
           ========================= */
        ROUND(m.avg_after_contact_work_time / 60, 2) AS avg_after_contact_work_time_min,
        ROUND(m.sum_after_contact_work_time / 60, 2) AS sum_after_contact_work_time_min,

        /* =========================
           Agent Status Metrics
           ========================= */
        ROUND(m.sum_online_time_agent / 60, 2) AS sum_online_time_agent_min,
        ROUND(m.sum_non_productive_time_agent / 60, 2) AS sum_non_productive_time_agent_min,
        ROUND(m.sum_idle_time_agent / 60, 2) AS sum_idle_time_agent_min,
        ROUND(m.sum_error_status_time_agent / 60, 2) AS sum_error_status_time_agent_min,
        ROUND(m.sum_contact_time_agent / 60, 2) AS sum_contact_time_agent_min,

        /* =========================
           Workforce Adherence Metrics
           ========================= */
        ROUND(m.agent_non_response_without_customer_abandons, 2)
            AS agent_non_response_excl_abandons,
        ROUND(m.agent_non_adherent_time / 60, 2) AS agent_non_adherent_time_min,
        ROUND(m.agent_adherent_time / 60, 2) AS agent_adherent_time_min,
        ROUND(m.agent_scheduled_time / 60, 2) AS agent_scheduled_time_min,
        ROUND(m.agent_schedule_adherence, 2) AS agent_schedule_adherence

    FROM base_metrics m
    LEFT JOIN user_dim u
        ON m.agent_id = u.user_id

)

SELECT *
FROM final_metrics;


   - Built for BI tools such as Power BI, Tableau, or QuickSight
   ============================================================ */
