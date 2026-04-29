# Amazon Connect Redshift Analytics

**Production-ready SQL views for Amazon Connect contact center analytics**  
Built for Amazon Redshift. Enables agent performance tracking, queue health monitoring, workforce adherence, and BI dashboards (Power BI, Tableau, QuickSight).

---

## Overview

This repository contains two analytical views that transform raw Amazon Connect data into business-friendly metrics:

- **`v_metric_data`** – Semantic layer for agent productivity, talk time, queue performance, contact handling, and schedule adherence.
- **`v_agent_metrics`** – Call‑level analysis including interaction durations, hold metrics, call classification, and shift‑based volume.

Both views are designed to sit on top of a Redshift data warehouse with the following source tables:
- `connect.f_agent_metrics` – Fact table with aggregated agent intervals.
- `connect.f_calls` – Fact table at individual contact level.
- `connect.dim_users` – Agent dimension.
- `connect.dim_queues` – Queue dimension.
- `litify.dim_users` – Additional HR attributes (job title, department).

---

## 🚀 Features

### `v_metric_data`
- Agent answer rate, occupancy, non‑response (with/without customer abandons)
- Talk time (customer, agent, total) in minutes
- Queue metrics: abandonment rate, max queued time, average queue answer time
- Contact lifecycle: active time, non‑talk time, interruption time
- Hold / transfer metrics
- After contact work & handle time
- Workforce adherence: scheduled time, adherent time, schedule adherence %

### `v_agent_metrics`
- Aggregated per agent per hour/day
- Interaction, contact, and after‑call work durations (seconds, minutes, hours)
- Hold metrics (min/max/total/avg)
- Call volume by type (inbound/outbound/transfer/callback)
- Duration buckets (e.g., <2 min, 2‑5 min, 46‑90 min, >90 min)
- Shift analysis (calls 9‑13, 13‑17, after 17)

---

## Repository Structure
amazon-connect-redshift-analytics/
│
├── sql/
│ ├── v_agent_metrics.sql -- Call-level analytics view
│ └── v_metric_data.sql -- Semantic layer for agent & queue metrics
│
├── LICENSE 
└── README.md 

## 📁 Repository Structure
