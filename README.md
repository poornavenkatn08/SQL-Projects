# 📊 SQL Portfolio: Data Engineering & Analytics

Welcome to my SQL portfolio. This repository is a collection of end-to-end projects demonstrating my ability to transform raw, messy data into actionable business intelligence using advanced SQL techniques.

---

## 🚀 Featured Projects

### 1. [E-Commerce Customer Analytics](./02-Ecommerce-Customer-Analytics/)

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

### 2. [Tech Industry Layoffs Analysis](./01_Tech_Layoffs_Analysis/)

**Focus:** Data Cleaning (ETL), Pipeline Engineering, and Exploratory Data Analysis

* **Problem:** Raw layoff data was inconsistent, duplicated, and contained missing values.
* **Solution:** Built a multi-stage cleaning pipeline in MySQL using CTEs and Window Functions to ensure 100% data integrity.
* **Key Result:** Identified a 15% volatility spike in the Retail sector and tracked impact across 380k+ global employees.
* **Tech:** MySQL, Self-Joins, Rolling Averages, Indexing

---

## 📊 Project Summary

| Project | Dataset Size | Key Technique | Business Impact |
|---------|--------------|---------------|-----------------|
| E-Commerce Customer Analytics | 100K+ orders | RFM Analysis, CTEs | R$2.9M revenue opportunity identified |
| Tech Layoffs Analysis | 380K+ employees | Data Cleaning, Window Functions | 15% sector volatility discovered |

---

## 🛠️ Technical Toolkit

| Category | Skills |
|----------|--------|
| **Dialects** | MySQL (Expert), PostgreSQL (Intermediate) |
| **Advanced Concepts** | CTEs, Window Functions (RANK, ROW_NUMBER, NTILE, LEAD/LAG), Subqueries |
| **Data Engineering** | Staging Tables, Schema Design, Performance Tuning, Indexing |
| **Analytics** | RFM Segmentation, Cohort Analysis, Rolling Averages, Trend Analysis |
| **Tools** | DBeaver, MySQL Workbench, Git, Tableau |

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
| 🐍 [Python Analytics Portfolio](https://github.com/poornavenkatn08/Python_Pandas-Data-Analysis-Portfolio) | Pandas, Scikit-learn analysis |

---

## 📬 Let's Connect!

📧 [pvneelakantam@gmail.com](mailto:pvneelakantam@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/pneelakantam/)  
💻 [GitHub](https://github.com/poornavenkatn08)  
📊 [Tableau Public](https://public.tableau.com/app/profile/poorna.venkat.neelakantam)
