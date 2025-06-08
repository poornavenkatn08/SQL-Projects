/*
==============================================================================
PROJECT: Tech Industry Layoffs Analysis - Data Cleaning Pipeline
AUTHOR: Poorna Venkat Neelakntam


PURPOSE: 
Comprehensive data cleaning and preparation pipeline for tech layoffs dataset.
Transforms raw, inconsistent data into analysis-ready format through systematic
cleaning procedures including deduplication, standardization, and validation.

KEY PROCESSES:
1. Data staging and backup creation
2. Duplicate detection and removal
3. Data standardization (company names, industries, countries)
4. Date format conversion and validation
5. Null value handling and data integrity checks

DATASET: Global tech layoffs (2020-2024)
ROWS: ~2,000 companies, 500,000+ affected employees
==============================================================================
*/

-- ===========================
-- SECTION 1: DATABASE SETUP
-- ===========================

USE layoffs;

-- Create staging environment for safe data manipulation
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

-- Verify staging table structure
SELECT 'Staging table created successfully' AS status;

-- ===============================
-- SECTION 2: DATA STAGING & BACKUP
-- ===============================

-- Load raw data into staging environment
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- Verify data load
SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT company) AS unique_companies,
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date
FROM layoffs_staging;

-- ===================================
-- SECTION 3: DUPLICATE IDENTIFICATION
-- ===================================

-- Initial duplicate check with basic partitioning
SELECT 
    company,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    COUNT(*) as duplicate_count,
    ROW_NUMBER() OVER(
        PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
    ) as row_num
FROM layoffs_staging
GROUP BY company, industry, total_laid_off, percentage_laid_off, `date`
HAVING duplicate_count > 1
ORDER BY duplicate_count DESC;

-- Comprehensive duplicate detection using all relevant fields
WITH duplicate_detection AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY 
                company,
                location, 
                industry, 
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) as row_num
    FROM layoffs_staging
)
SELECT 
    COUNT(*) as total_duplicates
FROM duplicate_detection
WHERE row_num > 1;

-- ==================================
-- SECTION 4: STAGING TABLE CREATION
-- ==================================

-- Create enhanced staging table with row numbering for duplicate removal
CREATE TABLE layoffs_staging_v2 (
    `company` VARCHAR(100) DEFAULT NULL,
    `location` VARCHAR(100) DEFAULT NULL,
    `industry` VARCHAR(100) DEFAULT NULL,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` FLOAT DEFAULT NULL,
    `date` VARCHAR(100) DEFAULT NULL,
    `stage` VARCHAR(100) DEFAULT NULL,
    `country` VARCHAR(100) DEFAULT NULL,
    `funds_raised_millions` FLOAT DEFAULT NULL,
    `row_num` INT,
    INDEX idx_company (`company`),
    INDEX idx_date (`date`),
    INDEX idx_industry (`industry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populate enhanced staging table with row numbers
INSERT INTO layoffs_staging_v2
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY 
            company,
            location, 
            industry, 
            total_laid_off,
            percentage_laid_off,
            `date`,
            stage,
            country,
            funds_raised_millions
    ) as row_num
FROM layoffs_staging;

-- =============================
-- SECTION 5: DUPLICATE REMOVAL
-- =============================

-- Log duplicate removal statistics
SELECT 
    'Before duplicate removal' AS stage,
    COUNT(*) as record_count
FROM layoffs_staging_v2
UNION ALL
SELECT 
    'Duplicates identified' AS stage,
    COUNT(*) as record_count
FROM layoffs_staging_v2
WHERE row_num > 1;

-- Remove duplicate records
DELETE FROM layoffs_staging_v2
WHERE row_num > 1;

-- Verify duplicate removal
SELECT 
    'After duplicate removal' AS stage,
    COUNT(*) as record_count
FROM layoffs_staging_v2;

-- ===============================
-- SECTION 6: DATA STANDARDIZATION
-- ===============================

-- 6.1 Company Name Standardization
-- Remove leading/trailing whitespace
UPDATE layoffs_staging_v2
SET company = TRIM(company)
WHERE company IS NOT NULL;

-- Verify company name cleaning
SELECT 
    'Company names standardized' AS process,
    COUNT(DISTINCT company) AS unique_companies
FROM layoffs_staging_v2;

-- 6.2 Industry Standardization
-- Standardize cryptocurrency industry variations
SELECT DISTINCT industry 
FROM layoffs_staging_v2 
WHERE industry LIKE 'Crypto%'
ORDER BY industry;

UPDATE layoffs_staging_v2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

-- Convert empty strings to NULL for proper handling
UPDATE layoffs_staging_v2
SET industry = NULL
WHERE industry = '';

-- 6.3 Country Standardization
-- Remove trailing periods and standardize country names
SELECT DISTINCT 
    country,
    TRIM(TRAILING '.' FROM country) AS cleaned_country
FROM layoffs_staging_v2
WHERE country LIKE '%.%'
ORDER BY country;

UPDATE layoffs_staging_v2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- =============================
-- SECTION 7: DATE PROCESSING
-- =============================

-- 7.1 Date Format Conversion
-- Convert string dates to proper DATE format
UPDATE layoffs_staging_v2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

-- 7.2 Change column data type
ALTER TABLE layoffs_staging_v2
MODIFY COLUMN `date` DATE;

-- Verify date conversion
SELECT 
    MIN(`date`) AS earliest_layoff,
    MAX(`date`) AS latest_layoff,
    COUNT(DISTINCT `date`) AS unique_dates
FROM layoffs_staging_v2
WHERE `date` IS NOT NULL;

-- =================================
-- SECTION 8: MISSING DATA HANDLING
-- =================================

-- 8.1 Identify records with missing critical data
SELECT 
    'Records with missing layoff data' AS data_issue,
    COUNT(*) AS count
FROM layoffs_staging_v2
WHERE total_laid_off IS NULL 
    AND percentage_laid_off IS NULL;

-- 8.2 Industry backfill using company matching
-- Find companies where industry can be inferred from other records
SELECT DISTINCT
    t1.company,
    t1.industry AS missing_industry,
    t2.industry AS available_industry
FROM layoffs_staging_v2 t1
JOIN layoffs_staging_v2 t2 
    ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL 
    AND t2.industry IS NOT NULL;

-- Backfill missing industry data
UPDATE layoffs_staging_v2 t1
JOIN layoffs_staging_v2 t2 
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
    AND t2.industry IS NOT NULL;

-- ==============================
-- SECTION 9: DATA QUALITY CHECKS
-- ==============================

-- 9.1 Final data quality assessment
SELECT 
    'Total Records' AS metric,
    COUNT(*) AS value
FROM layoffs_staging_v2
UNION ALL
SELECT 
    'Complete Records (no nulls in key fields)' AS metric,
    COUNT(*) AS value
FROM layoffs_staging_v2
WHERE company IS NOT NULL 
    AND `date` IS NOT NULL
    AND (total_laid_off IS NOT NULL OR percentage_laid_off IS NOT NULL)
UNION ALL
SELECT 
    'Records with Industry Data' AS metric,
    COUNT(*) AS value
FROM layoffs_staging_v2
WHERE industry IS NOT NULL
UNION ALL
SELECT 
    'Unique Companies' AS metric,
    COUNT(DISTINCT company) AS value
FROM layoffs_staging_v2;

-- 9.2 Remove records with insufficient data for analysis
DELETE FROM layoffs_staging_v2
WHERE total_laid_off IS NULL 
    AND percentage_laid_off IS NULL;

-- ===============================
-- SECTION 10: FINAL TABLE CLEANUP
-- ===============================

-- Remove helper column and create final clean table
ALTER TABLE layoffs_staging_v2
DROP COLUMN row_num;

-- Create final cleaned table
CREATE TABLE layoffs_cleaned AS
SELECT * FROM layoffs_staging_v2;

-- Final verification
SELECT 
    'Data cleaning completed successfully' AS status,
    COUNT(*) AS final_record_count,
    COUNT(DISTINCT company) AS unique_companies,
    MIN(`date`) AS data_start_date,
    MAX(`date`) AS data_end_date
FROM layoffs_cleaned;

-- ===============================
-- SECTION 11: CLEANUP
-- ===============================

-- Drop temporary staging tables
DROP TABLE IF EXISTS layoffs_staging;
DROP TABLE IF EXISTS layoffs_staging_v2;

/*
==============================================================================
DATA CLEANING SUMMARY:
- Removed duplicate records using comprehensive field matching
- Standardized company names, industries, and country names
- Converted dates to proper DATE format for time-series analysis
- Backfilled missing industry data where possible
- Removed records insufficient for analysis
- Created optimized final table: layoffs_cleaned

NEXT STEPS:
Execute 02_exploratory_analysis.sql for comprehensive data analysis
==============================================================================
*/
