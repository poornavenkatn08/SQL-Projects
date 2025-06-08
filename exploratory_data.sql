/*
==============================================================================
PROJECT: Tech Industry Layoffs Analysis - Exploratory Data Analysis
AUTHOR: [Your Name]
DATE CREATED: 2024
LAST MODIFIED: December 2024

PURPOSE: 
Comprehensive exploratory data analysis of tech industry layoffs providing
business insights through statistical analysis, trend identification, and
strategic recommendations for workforce planning and risk assessment.

KEY ANALYSES:
1. Market overview and summary statistics
2. Company-level impact analysis
3. Temporal trend analysis and seasonality
4. Geographic and industry segmentation
5. Company stage risk assessment
6. Executive dashboard metrics

BUSINESS VALUE:
- Identify high-risk periods and market conditions
- Benchmark company performance against industry
- Support strategic workforce planning decisions
- Provide data-driven investment risk insights
==============================================================================
*/

USE layoffs;

-- ===============================
-- SECTION 1: DATA OVERVIEW & VALIDATION
-- ===============================

SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT company) AS unique_companies,
    COUNT(DISTINCT industry) AS industries_affected,
    COUNT(DISTINCT country) AS countries_impacted,
    MIN(`date`) AS analysis_start_date,
    MAX(`date`) AS analysis_end_date,
    DATEDIFF(MAX(`date`), MIN(`date`)) AS analysis_period_days
FROM layoffs_cleaned;

-- ===============================
-- SECTION 2: IMPACT SCALE ANALYSIS
-- ===============================

SELECT 
    MAX(total_laid_off) AS max_single_layoff_event,
    MAX(percentage_laid_off) AS max_percentage_layoff,
    AVG(total_laid_off) AS avg_layoff_size,
    STDDEV(total_laid_off) AS layoff_size_std_dev
FROM layoffs_cleaned
WHERE total_laid_off IS NOT NULL;

SELECT 
    COUNT(*) AS shutdown_count
FROM layoffs_cleaned
WHERE percentage_laid_off = 1;

SELECT 
    company,
    industry,
    country,
    funds_raised_millions,
    `date` AS shutdown_date,
    CASE 
        WHEN funds_raised_millions >= 100 THEN 'High Funding (>$100M)'
        WHEN funds_raised_millions >= 10 THEN 'Medium Funding ($10-100M)'
        WHEN funds_raised_millions IS NOT NULL THEN 'Low Funding (<$10M)'
        ELSE 'Funding Unknown'
    END AS funding_category
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions IS NULL, funds_raised_millions DESC;

-- ===============================
-- SECTION 3: COMPANY IMPACT RANKING
-- ===============================

WITH company_totals AS (
    SELECT 
        company,
        COUNT(*) AS layoff_events,
        SUM(total_laid_off) AS total_employees_affected,
        AVG(total_laid_off) AS avg_layoff_size,
        MIN(`date`) AS first_layoff,
        MAX(`date`) AS latest_layoff,
        DATEDIFF(MAX(`date`), MIN(`date`)) AS layoff_period_days
    FROM layoffs_cleaned
    WHERE total_laid_off IS NOT NULL
    GROUP BY company
)
SELECT 
    RANK() OVER (ORDER BY total_employees_affected DESC) AS impact_rank,
    *
FROM company_totals
WHERE total_employees_affected >= 1000
LIMIT 20;

-- ===============================
-- SECTION 4: TEMPORAL TREND ANALYSIS
-- ===============================

WITH yearly_analysis AS (
    SELECT 
        YEAR(`date`) AS layoff_year,
        COUNT(*) AS layoff_events,
        SUM(total_laid_off) AS total_affected,
        COUNT(DISTINCT company) AS companies_affected,
        AVG(total_laid_off) AS avg_event_size
    FROM layoffs_cleaned
    WHERE total_laid_off IS NOT NULL
    GROUP BY YEAR(`date`)
)
SELECT 
    layoff_year,
    layoff_events,
    total_affected,
    companies_affected,
    ROUND(avg_event_size, 0) AS avg_event_size,
    ROUND(
        ((total_affected - LAG(total_affected) OVER (ORDER BY layoff_year)) / 
         NULLIF(LAG(total_affected) OVER (ORDER BY layoff_year), 0)) * 100, 1
    ) AS yoy_growth_percent
FROM yearly_analysis
WHERE layoff_year IS NOT NULL;

WITH monthly_trends AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS month_year,
        MONTH(`date`) AS month_num,
        MONTHNAME(`date`) AS month_name,
        COUNT(*) AS events,
        SUM(total_laid_off) AS monthly_total,
        AVG(total_laid_off) AS avg_size
    FROM layoffs_cleaned
    WHERE `date` IS NOT NULL AND total_laid_off IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m'), MONTH(`date`), MONTHNAME(`date`)
)
SELECT 
    month_num,
    month_name,
    COUNT(*) AS occurrence_count,
    AVG(monthly_total) AS avg_monthly_layoffs,
    SUM(monthly_total) AS total_layoffs_all_years,
    RANK() OVER (ORDER BY AVG(monthly_total) DESC) AS seasonal_risk_rank
FROM monthly_trends
GROUP BY month_num, month_name
ORDER BY month_num;

WITH monthly_totals AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS month_year,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_cleaned
    WHERE `date` IS NOT NULL AND total_laid_off IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)
SELECT 
    month_year,
    monthly_layoffs,
    SUM(monthly_layoffs) OVER (ORDER BY month_year) AS cumulative_layoffs,
    AVG(monthly_layoffs) OVER (
        ORDER BY month_year 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_avg
FROM monthly_totals
ORDER BY month_year;

-- ===============================
-- SECTION 5: GEOGRAPHIC ANALYSIS
-- ===============================

SELECT 
    RANK() OVER (ORDER BY SUM(total_laid_off) DESC) AS country_rank,
    country,
    COUNT(*) AS layoff_events,
    COUNT(DISTINCT company) AS companies_affected,
    SUM(total_laid_off) AS total_employees_affected,
    AVG(total_laid_off) AS avg_layoff_size,
    ROUND(
        (SUM(total_laid_off) * 100.0 / (
            SELECT SUM(total_laid_off) 
            FROM layoffs_cleaned 
            WHERE total_laid_off IS NOT NULL
        )), 2
    ) AS percentage_of_global_layoffs
FROM layoffs_cleaned
WHERE total_laid_off IS NOT NULL AND country IS NOT NULL
GROUP BY country
ORDER BY total_employees_affected DESC
LIMIT 15;

-- ===============================
-- SECTION 6: INDUSTRY ANALYSIS
-- ===============================

SELECT 
    RANK() OVER (ORDER BY SUM(total_laid_off) DESC) AS industry_rank,
    COALESCE(industry, 'Unknown') AS industry,
    COUNT(*) AS layoff_events,
    COUNT(DISTINCT company) AS companies_in_industry,
    SUM(total_laid_off) AS total_impact,
    AVG(total_laid_off) AS avg_layoff_size,
    ROUND(
        (SUM(total_laid_off) * 100.0 / (
            SELECT SUM(total_laid_off) 
            FROM layoffs_cleaned 
            WHERE total_laid_off IS NOT NULL
        )), 2
    ) AS industry_share_percent
FROM layoffs_cleaned
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_impact DESC;

-- ===============================
-- SECTION 7: COMPANY STAGE RISK ANALYSIS
-- ===============================

SELECT 
    COALESCE(stage, 'Unknown') AS company_stage,
    COUNT(*) AS layoff_events,
    COUNT(DISTINCT company) AS companies_affected,
    SUM(total_laid_off) AS total_employees_affected,
    AVG(total_laid_off) AS avg_layoff_size,
    AVG(percentage_laid_off) AS avg_percentage_laid_off,
    COUNT(CASE WHEN percentage_laid_off = 1 THEN 1 END) AS complete_shutdowns,
    ROUND(
        (COUNT(CASE WHEN percentage_laid_off = 1 THEN 1 END) * 100.0 / COUNT(*)), 2
    ) AS shutdown_rate_percent
FROM layoffs_cleaned
WHERE total_laid_off IS NOT NULL
GROUP BY stage
ORDER BY total_employees_affected DESC;

-- ===============================
-- SECTION 8: COMPETITIVE INTELLIGENCE
-- ===============================

WITH company_yearly_totals AS (
    SELECT 
        company,
        YEAR(`date`) AS layoff_year,
        SUM(total_laid_off) AS yearly_total
    FROM layoffs_cleaned
    WHERE total_laid_off IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
ranked_companies AS (
    SELECT 
        layoff_year,
        company,
        yearly_total,
        DENSE_RANK() OVER (
            PARTITION BY layoff_year 
            ORDER BY yearly_total DESC
        ) AS yearly_rank
    FROM company_yearly_totals
    WHERE layoff_year IS NOT NULL
)
SELECT 
    layoff_year,
    yearly_rank,
    company,
    yearly_total AS employees_affected,
    CASE 
        WHEN yearly_rank = 1 THEN '🥇 Highest Impact'
        WHEN yearly_rank = 2 THEN '🥈 Second Highest'
        WHEN yearly_rank = 3 THEN '🥉 Third Highest'
        ELSE CONCAT('Top ', yearly_rank)
    END AS market_position
FROM ranked_companies
WHERE yearly_rank <= 5
ORDER BY layoff_year DESC, yearly_rank;

-- ===============================
-- SECTION 9: EXECUTIVE DASHBOARD METRICS
-- ===============================

SELECT 
    'Market Overview' AS kpi_category,
    'Total Market Impact' AS kpi_name,
    CONCAT(FORMAT(SUM(total_laid_off), 0), ' employees') AS kpi_value
FROM layoffs_cleaned
WHERE total_laid_off IS NOT NULL

UNION ALL

SELECT 
    'Market Overview' AS kpi_category,
    'Companies Affected' AS kpi_name,
    CONCAT(COUNT(DISTINCT company), ' companies') AS kpi_value
FROM layoffs_cleaned
WHERE total_laid_off IS NOT NULL;
