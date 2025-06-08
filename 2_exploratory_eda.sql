-- Exploratory Data Analysis

use layoffs;

select * 
from layoffs_stag2;  

select max(total_laid_off),max(percentage_laid_off)
from layoffs_stag2;

select *
from layoffs_stag2
where percentage_laid_off =1
order by funds_raised_millions DESC;

select company,sum(total_laid_off)
from layoffs_stag2
group by company
order by 2 desc ;


select min(date),max(date)
from layoffs_stag2;

select country,sum(total_laid_off)
from layoffs_stag2
group by country
order by 2 desc ;

select industry,sum(total_laid_off)
from layoffs_stag2
group by industry
order by 2 desc ;

select year(date),sum(total_laid_off)
from layoffs_stag2
group by year(date)
order by 1 desc ;

select stage,sum(total_laid_off)
from layoffs_stag2
group by  stage
order by 2 desc ;

select substring(`date`,1,7) as `month`,sum(total_laid_off) as total_off
from layoffs_stag2
where substring(`date`,1,7) is not null 
group by `month`
order by 1 ASC;

with rolling_total as (
select substring(`date`,1,7) as `month`,sum(total_laid_off) as total_off
from layoffs_stag2
where substring(`date`,1,7) is not null 
group by `month`
order by 1 ASC
)

select `month`,total_off,sum(total_off) over(order by `month`) as ROLLING_TOTAL
from rolling_total;

select company,year(`date`),sum(total_laid_off)
from layoffs_stag2
group by company,year(`date`)
order by 3 desc ;

with company_year as (
select company,year(`date`) years ,sum(total_laid_off) as total_laid_off
from layoffs_stag2
group by company,year(`date`)
), compnay_year_rank as (
select * , dense_rank() over(partition by years order by total_laid_off desc) as ranking 
from company_year
where years is not null
)

select * from compnay_year_rank
where ranking <= 5;
