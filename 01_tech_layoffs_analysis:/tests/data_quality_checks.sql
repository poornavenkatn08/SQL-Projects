-- Data quality validation queries
-- Check for duplicates
SELECT company, location, date_layoff, COUNT(*) as duplicate_count
FROM layoffs_clean
GROUP BY company, location, date_layoff
HAVING COUNT(*) > 1;

-- Check data completeness
SELECT 
    COUNT(*) as total_records,
    COUNT(company) as companies_filled,
    COUNT(total_laid_off) as layoffs_filled,
    COUNT(date_layoff) as dates_filled
FROM layoffs_clean;