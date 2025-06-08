use layoffs;
drop table if exists layoffs_stag;

create table layoffs_stag
like layoffs;

select * from layoffs_stag;

insert layoffs_stag
select * FROM LAYOFFS;

select *,ROW_NUMBER() OVER(partition by company, industry, total_laid_off,percentage_laid_off,`date`) as row_num
FROM LAYOFFS_STAG;

with duplicate_cte as (
select *,ROW_NUMBER() OVER(partition by company,location, industry, total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM LAYOFFS_STAG
)
select * 
from duplicate_cte
where row_num >1;

select *
from layoffs_stag
where company ='hibob';

CREATE TABLE `layoffs_stag2` (
  `company` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `industry` varchar(100) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` float DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  `stage` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `funds_raised_millions` float DEFAULT NULL,
  `row_num`  int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
select *
from layoffs_stag2;

insert into layoffs_stag2
select *,
ROW_NUMBER() OVER
(partition by company,location, industry, total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM LAYOFFS_STAG;

delete
from layoffs_stag2
where row_num>1;

-- Standardizing Data 

select company,(trim(company))
from layoffs_stag2;

update layoffs_stag2
set company=trim(company);

select *
from layoffs_stag2
where industry = 'Crypto%';

update layoffs_stag2
set industry = 'Crypto' 
where industry like 'Crypto%'; 

select distinct country,trim(trailing '.' from country)
from layoffs_stag2
order by 1;

update layoffs_stag2
set country  = trim(trailing '.' from country)
where country like 'United States%';

 select `date`
 from layoffs_stag2;

update layoffs_stag2
set `date`=str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_stag2
MODIFY COLUMN `DATE` date;

 select *
 from layoffs_stag2
 where total_laid_off is NULL
 and percentage_laid_off is null;
 
 update layoffs_stag2
 set industry = null
 where industry = '';
 
  select *
 from layoffs_stag2
 where industry is null
 or industry ='';


  select *
 from layoffs_stag2
 where company ='Airbnb';

select *
 from layoffs_stag2 t1
 join layoffs_stag2 t2 
	on t1.company = t2.company
    and t1.location = t2.location
where t1.industry is null 
and t2.industry is not null;

UPDATE layoffs_stag2 t1
 join layoffs_stag2 t2 
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

select * 
from layoffs_Stag2;

DELETE 
 from layoffs_stag2
 where total_laid_off is NULL
 and percentage_laid_off is null;


ALTER TABLE layoffs_stag2
DROP COLUMN ROW_NUM;


select count(*)
from layoffs_stag2;










