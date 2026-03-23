# 📊 SQL Portfolio: Data Engineering & Analytics

Welcome to my SQL portfolio. This repository is a collection of end-to-end projects demonstrating my ability to transform raw, messy data into actionable business intelligence using advanced SQL techniques.

---

## 🚀 Featured Projects

### 1. [SaaS Customer Churn Prediction & Retention Analytics](./03-SaasCustomerChurnAnalytics/)

**Focus:** Multi-Table Churn Analysis, Revenue Impact Quantification, RFM Health Scoring, Cohort Retention

* **Problem:** RavenStack, an AI SaaS startup, was experiencing 22% churn across 500 accounts and losing $1.2M MRR. Leadership needed to understand what drives churn, which customers are at risk, and where to invest retention resources before public launch.
* **Solution:** Wrote 16 production-grade SQL queries across 5 relational tables (33K+ records) to analyze churn by segment, quantify revenue impact, compare behavioral patterns, build RFM health scores, and create a master analytics table feeding ML models and Tableau dashboards.
* **Key Results:**
  * Quantified **$1.2M MRR lost** to churn, with Budget ($267K) and Support ($205K) as costliest reasons
  * Discovered **DevTools Enterprise** churns at 45.5% — 2x the company average
  * Found **event referrals** churn at 34.5% vs partner referrals at 12.8% — marketing reallocation opportunity
  * Built **revenue-at-risk scoring system** categorizing 500 accounts into CRITICAL/HIGH/MEDIUM/LOW risk levels
  * Proved **support quality does NOT drive churn** — metrics nearly identical for churned vs retained
  * Created **RFM health scoring** (Query 14) segmenting customers into Champions, Loyal, At Risk, and Lost
* **Tech:** PostgreSQL, CTEs, Window Functions (NTILE), Multi-table JOINs (5 tables), CASE statements, Cohort Analysis

📊 **[View Interactive Dashboard](https://public.tableau.com/app/profile/poorna.venkat.neelakantam/viz/SaaSCustomerChurnAnalyticsDashboard/Homepage)**

**Sample Query - Revenue At-Risk Scoring System:**
```sql
WITH account_health AS (
    SELECT
        a.account_id,
        a.account_name,
        a.plan_tier,
        a.industry,
        MAX(s.mrr_amount) AS current_mrr,
        COUNT(DISTINCT st.ticket_id) AS total_tickets,
        ROUND(AVG(st.satisfaction_score), 2) AS avg_satisfaction,
        SUM(CASE WHEN st.priority IN ('high', 'urgent') THEN 1 ELSE 0 END) AS critical_tickets,
        MAX(CASE WHEN s.downgrade_flag = 'True' THEN 1 ELSE 0 END) AS had_downgrade
    FROM accounts a
    LEFT JOIN subscriptions s ON a.account_id = s.account_id
    LEFT JOIN support_tickets st ON a.account_id = st.account_id
    WHERE a.churn_flag = 'False'
    GROUP BY a.account_id, a.account_name, a.plan_tier, a.industry
)
SELECT *,
    CASE
        WHEN had_downgrade = 1 AND avg_satisfaction < 3 THEN 'CRITICAL'
        WHEN critical_tickets >= 3 OR avg_satisfaction < 3 THEN 'HIGH'
        WHEN total_tickets >= 5 OR avg_satisfaction < 4 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level
FROM account_health
ORDER BY current_mrr DESC;
```

**Query Inventory (16 Total):**
| # | Business Question | Category |
|---|------------------|----------|
| 1 | Churn rate by plan tier | Churn Overview |
| 2 | Churn rate by industry | Churn Overview |
| 3 | Monthly churn trend | Churn Overview |
| 4 | Total MRR lost by tier | Revenue Impact |
| 5 | Active accounts at risk (scoring system) | Revenue Impact |
| 6 | Customer lifetime value by industry × plan | Revenue Impact |
| 7 | Feature usage: churned vs retained | Behavioral Patterns |
| 8 | Support tickets: churned vs retained | Behavioral Patterns |
| 9 | Resolution time impact on churn | Behavioral Patterns |
| 10 | Upgrade/downgrade patterns before churn | Behavioral Patterns |
| 11 | Beta feature adoption vs churn | Behavioral Patterns |
| 12 | Cohort retention analysis (3/6/12 months) | Advanced Analytics |
| 13 | Churn reason distribution with revenue impact | Advanced Analytics |
| 14 | RFM-style health scoring for SaaS | Advanced Analytics |
| 15 | Referral source effectiveness | Advanced Analytics |
| 16 | Master analytics table (ML + Tableau export) | Data Engineering |

---

### 2. [E-Commerce Customer Analytics](./02-Ecommerce-Customer-Analytics/)

**Focus:** Customer Segmentation, RFM Analysis, and Revenue Intelligence

* **Problem:** E-commerce company needed to understand customer behavior across 100K+ orders to optimize marketing spend and reduce churn.
* **Solution:** Built SQL queries to calculate RFM (Recency, Frequency, Monetary) scores, segment customers, and analyze geographic revenue distribution.
* **Key Results:**
  * Identified R$2.9M revenue opportunity from "Lost" customer segment
  * Flagged 12,039 at-risk customers for retention campaigns
  * Discovered 40% revenue spike in November (seasonal optimization)
* **Tech:** MySQL, CTEs, Window Functions, Aggregations, CASE statements

📊 **[View Interactive Dashboard](https://public.tableau.com/app/profile/poorna.venkat.neelakantam/viz/E-CommerceCustomerAnalyticsDashboard/Dashboard1)**

**Sample Query - RFM Calculation:**
```sql
WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        DATEDIFF('2018-08-30', MAX(o.order_purchase_timestamp)) as Recency,
        COUNT(DISTINCT o.order_id) as Frequency,
        SUM(p.payment_value) as Monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
)
SELECT 
    customer_id,
    Recency,
    Frequency,
    Monetary,
    NTILE(4) OVER (ORDER BY Recency DESC) as R_Score,
    NTILE(4) OVER (ORDER BY Frequency) as F_Score,
    NTILE(4) OVER (ORDER BY Monetary) as M_Score
FROM customer_rfm;
```

---

### 3. [Tech Industry Layoffs Analysis](./01_Tech_Layoffs_Analysis/)

**Focus:** Data Cleaning (ETL), Pipeline Engineering, and Exploratory Data Analysis

* **Problem:** Raw layoff data was inconsistent, duplicated, and contained missing values.
* **Solution:** Built a multi-stage cleaning pipeline in MySQL using CTEs and Window Functions to ensure 100% data integrity.
* **Key Result:** Identified a 15% volatility spike in the Retail sector and tracked impact across 380k+ global employees.
* **Tech:** MySQL, Self-Joins, Rolling Averages, Indexing

---

## 📊 Project Summary

| Project | Dataset Size | Key Technique | Business Impact |
|---------|--------------|---------------|-----------------|
| SaaS Churn Analytics | 33K+ records (5 tables) | Multi-table JOINs, CTEs, NTILE, Cohort Analysis | $1.2M MRR lost quantified, 123 at-risk accounts scored |
| E-Commerce Customer Analytics | 100K+ orders | RFM Analysis, CTEs | R$2.9M revenue opportunity identified |
| Tech Layoffs Analysis | 380K+ employees | Data Cleaning, Window Functions | 15% sector volatility discovered |

---

## 🛠️ Technical Toolkit

| Category | Skills |
|----------|--------|
| **Dialects** | PostgreSQL (Expert), MySQL (Expert) |
| **Advanced Concepts** | CTEs, Window Functions (RANK, ROW_NUMBER, NTILE, LEAD/LAG), Subqueries |
| **Multi-Table Analysis** | 5-table JOINs (INNER, LEFT), Foreign Key relationships, Referential integrity |
| **Data Engineering** | Schema Design, Primary/Foreign Keys, Indexing, Staging Tables, Master Table Export |
| **Analytics** | RFM Segmentation, Cohort Retention, Churn Analysis, Revenue Impact, Risk Scoring |
| **Data Quality** | Boolean text-string handling, NULL imputation, Orphan record validation |
| **Tools** | DBeaver, MySQL Workbench, pgAdmin, Git, Tableau |

---

## 📈 Database Architecture Methodology

I follow a systematic approach to every SQL project to ensure scalability and accuracy:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  1. STAGING │ →  │ 2. CLEANING │ →  │ 3. TRANSFORM│ →  │ 4. ANALYSIS │
│  Raw Import │    │  Duplicates │    │  Joins/CTEs │    │  KPIs/Trends│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

1. **Staging:** Importing raw data into a safe environment
2. **Cleaning:** Removing duplicates and standardizing formats
3. **Transform:** Joining tables, creating calculated fields with CTEs
4. **Analysis:** Developing KPIs and trend reports for stakeholders

---

## 🔗 Related Repositories

| Repository | Description |
|------------|-------------|
| 📊 [Dashboard Portfolio](https://github.com/poornavenkatn08/dashboards-portfolio) | Tableau & Power BI visualizations |
| 🐍 [Python Analytics Portfolio](https://github.com/poornavenkatn08/Python_Pandas-Data-Analysis-Portfolio) | Pandas, Scikit-learn, XGBoost analysis |

---

## 📬 Let's Connect!

📧 [pvneelakantam@gmail.com](mailto:pvneelakantam@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/pneelakantam/)  
💻 [GitHub](https://github.com/poornavenkatn08)  
📊 [Tableau Public](https://public.tableau.com/app/profile/poorna.venkat.neelakantam)
