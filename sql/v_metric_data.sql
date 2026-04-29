CREATE OR REPLACE VIEW connect.v_metric_data AS
/* ============================================================
   Amazon Connect Agent Performance Semantic Layer
   Purpose:
   Reporting-ready Redshift view for operational analytics,
   workforce management, queue performance, and BI dashboards.
   ============================================================ */

SELECT 
    DATE(m.start_time) AS metric_date,
    EXTRACT(YEAR FROM m.start_time) AS metric_year,
    EXTRACT(MONTH FROM m.start_time) AS metric_month,
    EXTRACT(DAY FROM m.start_time) AS metric_day,
    EXTRACT(HOUR FROM m.start_time) AS metric_hour,

    (u.user_name || ' ' || u.user_lastname) AS user_full_name,
    u.user_email,

    m.start_time,
    m.end_time,

    ROUND(m.agent_answer_rate, 2) AS agent_answer_rate,
    ROUND(m.agent_non_response, 2) AS agent_non_response,
    ROUND(m.agent_occupancy, 2) AS agent_occupancy,
    ROUND(m.avg_dials_per_minute, 2) AS avg_dials_per_minute,
    ROUND(m.sum_connecting_time_agent / 60, 2) AS sum_connecting_time_agent_min,
    m.sum_retry_callback_attempts,
    m.percent_talk_time_customer,
    ROUND(m.avg_talk_time_customer / 60, 2) AS avg_talk_time_customer_min,
    m.percent_talk_time_agent,
    ROUND(m.avg_talk_time_agent / 60, 2) AS avg_talk_time_agent_min,
    m.percent_talk_time,
    ROUND(m.avg_talk_time / 60, 2) AS avg_talk_time_min,
    m.contacts_queued,
    m.contacts_queued_by_enqueue,
    ROUND(m.max_queued_time / 60, 2) AS max_queued_time_min,
    m.contacts_transferred_out_from_queue,
    ROUND(m.avg_queue_answer_time / 60, 2) AS avg_queue_answer_time_min,
    m.contacts_created, 
    m.sum_contacts_disconnected,
    ROUND(m.avg_active_time / 60, 2) AS avg_active_time_min,
    ROUND(m.abandonment_rate, 2) AS abandonment_rate,
    ROUND(m.avg_non_talk_time / 60, 2) AS avg_non_talk_time_min,
    ROUND(m.avg_interruption_time_agent / 60, 2) AS avg_interruption_time_agent_min,
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
    m.contacts_handled,
    ROUND(m.avg_handle_time / 60, 2) AS avg_handle_time_min,
    ROUND(m.sum_handle_time / 60, 2) AS sum_handle_time_min,
    ROUND(m.avg_interaction_time / 60, 2) AS avg_interaction_time_min,
    ROUND(m.sum_interaction_time / 60, 2) AS sum_interaction_time_min,
    ROUND(m.avg_contact_duration / 60, 2) AS avg_contact_duration_min,
    ROUND(m.sum_interaction_and_hold_time / 60, 2) AS sum_interaction_and_hold_time_min,
    ROUND(m.avg_after_contact_work_time / 60, 2) AS avg_after_contact_work_time_min,
    ROUND(m.sum_after_contact_work_time / 60, 2) AS sum_after_contact_work_time_min,
    ROUND(m.sum_online_time_agent / 60, 2) AS sum_online_time_agent_min,
    ROUND(m.sum_non_productive_time_agent / 60, 2) AS sum_non_productive_time_agent_min,
    ROUND(m.sum_idle_time_agent / 60, 2) AS sum_idle_time_agent_min,
    ROUND(m.sum_error_status_time_agent / 60, 2) AS sum_error_status_time_agent_min,
    ROUND(m.sum_contact_time_agent / 60, 2) AS sum_contact_time_agent_min,

    -- Shortened alias for clarity
    ROUND(m.agent_non_response_without_customer_abandons, 2) AS agent_non_response_excl_abandons,

    ROUND(m.agent_non_adherent_time / 60, 2) AS agent_non_adherent_time_min,
    ROUND(m.agent_adherent_time / 60, 2) AS agent_adherent_time_min,
    ROUND(m.agent_scheduled_time / 60, 2) AS agent_scheduled_time_min,
    ROUND(m.agent_schedule_adherence, 2) AS agent_schedule_adherence

FROM connect.f_agent_metrics m
LEFT JOIN connect.dim_users u ON m.agent_id = u.user_id
-- Uncomment the line below to filter to a specific reporting window (improves performance)
-- WHERE m.start_time >= '2025-01-01';
