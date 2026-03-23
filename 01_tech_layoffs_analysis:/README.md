

# 📉 Tech Industry Layoffs: Data Engineering & Analysis Pipeline

## 📌 Project Overview

This project presents a comprehensive end-to-end SQL solution for processing and analyzing global tech layoff data. Using **MySQL**, I built a robust pipeline that transforms raw, messy data into a clean, analytical-ready format to uncover trends regarding industry volatility, geographic impact, and company-stage risk assessments from 2020 to 2023.

## 📊 Dataset Insights

* **Total Records:** 2,361
* **Unique Companies:** 1,893
* **Global Impact:** 386,379+ layoffs across 60 countries
* **Timeframe:** March 2020 – March 2023

## 🛠️ Project Phases

### Phase 1: Data Engineering & Cleaning (ETL)

The primary challenge was the inconsistency of the raw data. I implemented a multi-stage cleaning process in `01_data_cleaning.sql`:

* **Staging Environments:** Created redundant staging tables (`layoffs_staging` and `v2`) to perform non-destructive cleaning and ensure data safety.
* **Advanced Deduplication:** Utilized **Window Functions** (`ROW_NUMBER()`) partitioned across all columns to identify and remove duplicate entries.
* **Data Standardization:**
* Fixed industry inconsistencies (e.g., standardizing 'Crypto', 'Crypto Currency', and 'CryptoCurrency').
* Cleaned trailing punctuation and naming variations in country fields (e.g., 'United States.').
* Converted string-based dates to `DATE` format using `STR_TO_DATE` to enable time-series analysis.


* **Data Imputation:** Performed **Self-Joins** to backfill missing `industry` data by matching records for the same company and location.
* **Precision Filtering:** Removed entries with insufficient data (nulls in both total and percentage fields) to maintain the integrity of statistical averages.

### Phase 2: Exploratory Data Analysis (EDA)

In `02_exploratory_analysis.sql`, I developed complex queries to extract business intelligence:

* **Temporal Trends:** Calculated year-over-year growth and **3-month rolling averages** to visualize layoff surges over time.
* **Company Benchmarking:** Used `DENSE_RANK()` to identify the top 5 companies by layoff volume for each year.
* **Risk Profiling:** Analyzed "Shutdown Rates" (100% layoffs) by company funding stage and industry sector.
* **Geographic Analysis:** Identified the top countries by total employees affected to understand the epicenter of market contraction.

## 🚀 Key Insights

1. **Post-IPO Vulnerability:** While early-stage startups had higher total shutdown rates, **Post-IPO companies** accounted for the vast majority of total employees displaced.
2. **Industry Clusters:** The **Consumer** and **Retail** sectors were the most volatile, showing the highest frequency of layoff events globally.
3. **Seasonality:** Analysis of monthly trends revealed specific periods of high risk (e.g., January surges), assisting in forecasting workforce market shifts.

## 📂 File Structure

* `01_data_cleaning.sql`: SQL script for database setup, table creation, and the ETL pipeline.
* `02_exploratory_analysis.sql`: SQL script for statistical analysis, window functions, and KPI generation.
* `layoffs_Raw.csv`: The original uncleaned dataset (2,300+ rows).

## ⚙️ Setup Instructions

1. **Database Creation:** Execute the `CREATE DATABASE` and `CREATE TABLE` commands found at the top of the scripts.
2. **Data Import:** Import `layoffs_Raw.csv` into your `layoffs_raw` table using the MySQL Table Data Import Wizard.
3. **Run Pipeline:** * Execute the cleaning script to generate the `layoffs_cleaned` table.
* Execute the analysis script to generate the insights and dashboard metrics.



---

**Poorna Venkat Neelakantam** [LinkedIn](https://www.linkedin.com/in/pneelakantam/) | [Email](mailto:pvneelakantam@gmail.com) | [GitHub](https://github.com/poornavenkatn08)
