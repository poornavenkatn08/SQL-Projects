📉 Tech Industry Layoffs: Data Engineering & Analysis Pipeline
📌 Project Overview
This project presents a comprehensive end-to-end SQL solution for processing and analyzing global tech layoff data. Using MySQL, I built a robust pipeline that transforms raw, messy data into a clean, analytical-ready format to uncover trends regarding industry volatility, geographic impact, and company-stage risk assessments from 2020 to 2023.

📊 Dataset Insights
Total Records: 2,361

Unique Companies: 1,893

Global Impact: 386,379+ layoffs across 60 countries

Timeframe: March 2020 – March 2023

🛠️ Project Phases
Phase 1: Data Engineering & Cleaning (ETL)

The primary challenge was the inconsistency of the raw data. I implemented a multi-stage cleaning process in 01_data_cleaning.sql:

Staging Environments: Created redundant staging tables (layoffs_staging and v2) to perform non-destructive cleaning.

Advanced Deduplication: Utilized Window Functions (ROW_NUMBER()) partitioned across all columns to identify and remove duplicate entries.

Standardization:

Fixed industry inconsistencies (e.g., standardizing 'Crypto' and 'Crypto Currency').

Cleaned trailing punctuation in country names (e.g., 'United States.').

Converted string-based dates to DATE format using STR_TO_DATE for time-series compatibility.

Data Imputation: Performed Self-Joins to backfill missing industry data by matching records for the same company and location.

Precision Filtering: Removed entries with insufficient data (nulls in both total and percentage fields) to maintain the integrity of statistical averages.

Phase 2: Exploratory Data Analysis (EDA)

In 02_exploratory_analysis.sql, I developed complex queries to extract business intelligence:

Temporal Trends: Calculated year-over-year growth and 3-month rolling averages to visualize layoff surges.

Company Benchmarking: Used DENSE_RANK() to identify the top 5 companies by layoff volume for each year.

Risk Profiling: Analyzed "Shutdown Rates" (100% layoffs) by company funding stage and industry sector.

Geographic Analysis: Identified the top 15 countries by total employees affected to understand the epicenter of market contraction.

🚀 Key Findings
Post-IPO Vulnerability: While startups (Seed/Series A) had higher total shutdown rates, Post-IPO companies accounted for the vast majority of total employees displaced.

Industry Clusters: The Consumer and Retail sectors were the most volatile, showing the highest frequency of layoff events globally.

Seasonality: Analysis of monthly trends revealed specific periods of high risk, assisting in forecasting workforce market shifts.

📂 File Structure
01_data_cleaning.sql: SQL script for database setup and ETL pipeline.

02_exploratory_analysis.sql: SQL script for statistical analysis and KPIs.

layoffs_Raw.csv: The original uncleaned dataset (2,300+ rows).

⚙️ Setup Instructions
Clone the Repository: git clone https://github.com/poornavenkatn08/SQL-Projects.git

Database Creation: Execute the setup commands at the top of 01_data_cleaning.sql.

Data Import: Import layoffs_Raw.csv into your layoffs table.

Run Pipeline: Execute the cleaning script followed by the analysis script to see the results.

Poorna Venkat Neelakantam LinkedIn | Email | GitHub
