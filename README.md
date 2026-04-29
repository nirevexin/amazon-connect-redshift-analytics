# Amazon Connect Redshift Analytics Semantic Layer

## Overview
This project provides a production-style Amazon Redshift semantic reporting layer designed for Amazon Connect operational analytics.

The repository transforms raw contact center agent performance data into business-ready KPIs for:

- Agent productivity monitoring
- Workforce management
- Queue performance analysis
- Contact handling optimization
- Schedule adherence tracking
- Business intelligence dashboards

By combining fact and dimension tables into a denormalized analytics view, this project enables efficient reporting for BI tools such as:

- Power BI
- Tableau
- Amazon QuickSight

---

## Project Objectives
- Standardize 50+ operational KPIs
- Improve reporting efficiency
- Simplify dashboard development
- Normalize duration metrics into business-readable minutes
- Build scalable semantic layers for enterprise analytics
- Demonstrate Redshift data warehousing best practices

---

## Data Architecture

### Source Tables

#### `connect.f_agent_metrics`
Fact table containing raw Amazon Connect agent metrics.

#### `connect.dim_users`
Dimension table containing agent profile information.

---

### Final Semantic Layer

#### `connect.v_metric_data`
A reporting-ready SQL view containing:

### Date Dimensions
- Metric date
- Year
- Month
- Day
- Hour

### Agent Dimensions
- Full name
- Email
- Session timestamps

### Operational KPIs
- Answer rate
- Occupancy
- Non-response
- Talk time
- Queue metrics
- Handle time
- Hold time
- Transfer metrics
- After-contact work
- Workforce adherence

---

## Technical Features

### SQL Engineering Practices
- CTE-based modular query design
- Logical metric grouping
- Standardized naming conventions
- Business-friendly aliases
- Inline documentation
- Unit conversions (seconds → minutes)
- KPI precision standardization using rounding

---

## Redshift Optimization Strategy

### Recommended Performance Enhancements
- **DISTKEY:** `agent_id`
- **SORTKEY:** `start_time`

### Design Considerations
- LEFT JOIN preserves complete metric history
- Time-series optimization for dashboard queries
- Reporting flexibility for historical analysis
- BI-ready denormalization

---

## Example Business Use Cases

### Workforce Management
- Agent schedule adherence
- Productivity trends
- Idle time analysis

### Contact Center Operations
- Queue abandonment analysis
- Average handle time
- Contact lifecycle optimization

### Executive Reporting
- KPI dashboards
- Agent performance benchmarking
- Operational efficiency reporting

---

## Repository Structure

```bash
amazon-connect-redshift-analytics/
│
├── sql/
│   └── v_metric_data.sql
│
│
└── README.md
