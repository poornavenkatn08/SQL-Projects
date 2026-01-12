📉 Tech Industry Layoffs: Data Engineering & Analysis Pipeline
📌 Project Overview
This project presents a robust end-to-end data pipeline built in MySQL to process and analyze global tech layoff data from 2020 to 2023. The project is divided into two primary phases:

Data Engineering: A multi-stage cleaning process to transform a messy, raw dataset of 2,361 records into a high-integrity analytical source.

Exploratory Data Analysis (EDA): Extracting business-critical insights regarding market volatility, geographic impact, and company-stage risk assessments.

📊 Dataset Highlights
Total Records: 2,361

Unique Companies: 1,893

Total Layoffs Tracked: 386,379+

Geographic Scope: 60 Countries

Time Period: March 2020 – March 2023

🛠️ Technical Workflow
1. Data Cleaning & Transformation (ETL)

To ensure the raw data didn't compromise the analysis, I implemented a rigorous cleaning strategy:

Staging Environments: Created layoffs_staging and layoffs_staging_v2 to perform non-destructive transformations.

Deduplication: Utilized Window Functions (ROW_NUMBER() OVER(...)) to identify and remove duplicate records based on 9 distinct column partitions.

Standardization:

Normalized industry names (e.g., merging all 'Crypto' variations).

Cleaned geographic data (e.g., removing trailing periods in "United States").

Converted VARCHAR temporal data into proper DATE formats using STR_TO_DATE.

Data Imputation: Employed Self-Joins to backfill null industry fields by matching records against historical company entries (e.g., populating "Travel" for missing Airbnb records).

Filtering: Removed 362 records that lacked both total layoff numbers and percentage data, as they provided no analytical value.

2. Exploratory Data Analysis (EDA)

With a clean dataset, I conducted deep-dive queries to identify trends:

Temporal Analysis: Calculated year-over-year growth and 3-month rolling averages of layoffs to identify seasonal risk periods.

Impact Ranking: Used DENSE_RANK to identify the companies and industries with the highest layoff volumes.

Risk Assessment: Analyzed the "Shutdown Rate" across company stages (Seed, Series A-E, Post-IPO) to determine which funding stages were most vulnerable to market shifts.

🚀 Key Insights
Market Leader Impact: Post-IPO companies accounted for the largest volume of layoffs, despite having higher funding levels.

Geographic Concentration: The United States represented the highest volume of global layoffs within this period.

Sector Volatility: The Consumer and Retail industries experienced significantly higher frequency of layoff events compared to others.

📂 Project Structure
Bash
├── 01_data_cleaning.sql        # The ETL pipeline (Raw -> Staging -> Clean)
├── 02_exploratory_analysis.sql # Complex queries for business insights
├── layoffs_Raw.csv             # Original dataset
└── README.md                   # Project documentation
💻 How to Use
Clone the Repo:

Bash
git clone https://github.com/poornavenkatn08/SQL-Projects.git
Import Data: Load layoffs_Raw.csv into your MySQL environment.

Run Pipeline: Execute 01_data_cleaning.sql first to create the layoffs_cleaned table.

Run Analysis: Execute 02_exploratory_analysis.sql to view the insights and KPIs.

📬 Contact
Poorna Venkat Neelakantam

LinkedIn: linkedin.com/in/pneelakantam/

Email: pvneelakantam@gmail.com

GitHub: poornavenkatn08

If you find this project helpful, please consider giving it a ⭐!
