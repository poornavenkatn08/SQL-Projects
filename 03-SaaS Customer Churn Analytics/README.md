# SaaS Customer Churn Prediction & Retention Analytics — SQL Analysis

## 📊 Project Overview

Analyzed **500 SaaS accounts across 5 relational tables (33,000+ records)** for RavenStack, an AI-driven team tools startup, to uncover churn patterns, quantify revenue impact, and identify at-risk customers using advanced SQL queries.

**Dataset:** RavenStack SaaS Subscription & Churn Analytics (by River @ Rivalytics)  
**Database:** PostgreSQL  
**Records:** 33,100+ across 5 tables  

---

## 🗃️ Database Schema

```
accounts (500 rows) ──── PK: account_id
│
├── subscriptions (5,000 rows) ──── FK → accounts.account_id
│   └── feature_usage (25,000 rows) ──── FK → subscriptions.subscription_id
│
├── support_tickets (2,000 rows) ──── FK → accounts.account_id
└── churn_events (600 rows) ──── FK → accounts.account_id
```

---

## 🔍 Business Questions & SQL Queries (16 Total)

### Category A: Churn Overview
| # | Business Question | Key Finding |
|---|------------------|-------------|
| 1 | Does churn rate differ across pricing tiers? | Pro tier churns at 25.2%, Basic at 19.3%, Enterprise at 23.2% |
| 2 | Which industries churn most? | DevTools has highest churn (45.5% at Enterprise tier) |
| 3 | Is churn getting worse month-over-month? | Churn accelerated sharply in late 2024 |

### Category B: Revenue Impact
| # | Business Question | Key Finding |
|---|------------------|-------------|
| 4 | How much MRR have we lost by tier? | $1.2M total MRR lost to churn |
| 5 | Which active customers are at risk right now? | 123 Medium + 1 High risk accounts identified |
| 6 | What's the lifetime value by industry × plan? | Enterprise FinTech has highest LTV |

### Category C: Behavioral Patterns
| # | Business Question | Key Finding |
|---|------------------|-------------|
| 7 | Do churned users adopt fewer features? | Minimal difference (~27.7 vs ~27.6 features) |
| 8 | Do churned users have worse support experiences? | Support metrics nearly identical — churn not driven by support quality |
| 9 | At what resolution time does churn spike? | No significant resolution time threshold found |
| 10 | Are downgrades an early warning for churn? | Retained customers upgraded 64% vs churned 58.8% |
| 11 | Does beta feature access help or hurt retention? | Beta adoption similar across both groups |

### Category D: Advanced Analytics
| # | Business Question | Key Finding |
|---|------------------|-------------|
| 12 | How does retention change over 3/6/12 months by cohort? | Recent cohorts retaining at similar rates |
| 13 | Which churn reason costs us the most revenue? | Budget ($267K) and Support ($205K) are top revenue-loss reasons |
| 14 | Can we score customer health with RFM? | RFM scoring segmented customers into Champions, Loyal, At Risk, Lost |
| 15 | Which acquisition channel brings customers who stay? | Partner referrals churn least (12.8%), Event referrals churn most (34.5%) |
| 16 | Master analytics table for ML + Tableau | Consolidated all 5 tables into 1 analysis-ready export |

---

## 🛠️ SQL Skills Demonstrated

- **Multi-table JOINs** across 5 relational tables (INNER, LEFT)
- **CTEs** (WITH clauses) for readable, layered analysis
- **Window Functions** (NTILE, ROW_NUMBER for RFM scoring)
- **CASE Statements** for conditional logic and bucketing
- **Date Functions** (DATE_TRUNC, EXTRACT, AGE) for cohort analysis
- **Aggregate Functions** with GROUP BY + HAVING
- **Subqueries** for nested calculations
- **Data Quality Handling** — boolean text-string comparison ('True'/'False')

---

## 📈 Key Insights

1. **22% overall churn rate** — 110 of 500 accounts lost
2. **$1.2M MRR lost** to churned accounts
3. **Budget and features** are the top churn reasons by revenue impact
4. **Event-sourced customers** churn at 34.5% vs partner-sourced at 12.8%
5. **DevTools + Enterprise** is the worst-performing segment (45.5% churn)
6. **Support quality does NOT drive churn** — metrics nearly identical for churned vs retained

---

## 🔗 Related Work

- **Python Analysis:** [Python_Pandas-Data-Analysis-Portfolio](https://github.com/poornavenkatn08/Python_Pandas-Data-Analysis-Portfolio)
- **Tableau Dashboard:** [dashboards-portfolio](https://github.com/poornavenkatn08/dashboards-portfolio)
- **Live Dashboard:** [View on Tableau Public](https://public.tableau.com/app/profile/poorna.venkat.neelakantam/viz/SaaSCustomerChurnAnalyticsDashboard/Homepage)

---

## 📁 Files

```
SaaS-Churn-Analytics/
├── 00_schema_creation.sql          # Table schemas with primary/foreign keys
├── 01_analysis_queries.sql         # All 16 business queries with comments
└── README.md
```

---

**Dataset Credit:** RavenStack dataset by River @ Rivalytics (MIT License, fully synthetic)
