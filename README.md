# Layoffs Analysis (SQL Project)

This project focuses on data cleaning and exploratory data analysis using SQL on a dataset of tech company layoffs.

## 🧹 Data Cleaning
- Removed duplicates using ROW_NUMBER
- Standardized company names, industries, and date formats
- Handled nulls and missing values
- Normalized country names and industries

## 📊 Exploratory Data Analysis
- Total layoffs by company, industry, and year
- Trends over time (monthly/yearly)
- Highest layoff events and rolling totals
- Country and stage-wise breakdowns

## 📁 Files

- `sql/1_data_cleaning.sql`: Cleans and preprocesses the raw data
- `sql/2_exploratory_eda.sql`: Performs deep analysis on cleaned data

## 🔧 Tools Used
- MySQL
- SQL Window Functions, Aggregates, CTEs

## 🚀 How to Run
1. Import the dataset into MySQL
2. Run `1_data_cleaning.sql`
3. Then run `2_exploratory_eda.sql` to view insights

## 📄 License
MIT
