-- Create database and tables for layoffs analysis
CREATE DATABASE IF NOT EXISTS layoffs_analysis;
USE layoffs_analysis;

-- Drop table if exists
DROP TABLE IF EXISTS layoffs_raw;

-- Create raw data table
CREATE TABLE layoffs_raw (
    company VARCHAR(255),
    location VARCHAR(255),
    industry VARCHAR(255),
    total_laid_off INT,
    percentage_laid_off VARCHAR(10),
    date_layoff VARCHAR(50),
    stage VARCHAR(100),
    country VARCHAR(100),
    funds_raised_millions DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);