
 -- MYSQL  
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * FROM PortfolioProjects.covid_deaths
Where continent is not null 
order by 3,4


-- Standardize Date Format


SELECT DATE_FORMAT(date,'%y-%m-%d') FROM covid_deaths;

UPDATE covid_deaths
SET date = STR_TO_DATE(date,"%d/%m/%y");

ALTER TABLE covid_deaths
MODIFY date DATE;

SELECT * FROM covid_deaths;

DESCRIBE covid_deaths; 

---------------------------------------------------------------------------------------------------

-- Replacing Empty String cells with NULLS-------------------------------


SELECT * FROM covid_deaths;

SELECT total_deaths,
       NULLIF(TRIM(both '()' FROM total_deaths),'') 
FROM covid_deaths;
UPDATE covid_deaths
SET total_deaths = NULLIF(TRIM(both '()' FROM total_deaths),'')


-- If it doesn't Update properly



UPDATE covid_deaths
SET total_deaths = NULLIF(TRIM(both '()' FROM total_deaths),''),
    total_cases = NULLIF(TRIM(both '()' FROM total_cases),'') ,
    new_cases = NULLIF(TRIM(both '()' FROM new_cases),''),
    new_deaths = NULLIF(TRIM(both '()' FROM new_deaths),'');


UPDATE covid_deaths
SET continent = NULLIF(TRIM(both '()' FROM continent),''),
	new_cases_smoothed = NULLIF(TRIM(both '()' FROM new_cases_smoothed),'') ,
    new_deaths_smoothed = NULLIF(TRIM(both '()' FROM new_deaths_smoothed),'') ,
	total_cases_per_million = NULLIF(TRIM(both '()' FROM total_cases_per_million),'') ,
	new_cases_per_million = NULLIF(TRIM(both '()' FROM new_cases_per_million),'') ,
	new_cases_smoothed_per_million= NULLIF(TRIM(both '()' FROM new_cases_smoothed_per_million),''), 
	total_deaths_per_million = NULLIF(TRIM(both '()' FROM total_deaths_per_million),'') ,
	total_deaths_per_million = NULLIF(TRIM(both '()' FROM total_deaths_per_million),'') ,
	new_deaths_smoothed_per_million = NULLIF(TRIM(both '()' FROM new_deaths_smoothed_per_million),'') ,
	reproduction_rate = NULLIF(TRIM(both '()' FROM reproduction_rate),'') ,
	icu_patients = NULLIF(TRIM(both '()' FROM icu_patients),'') ,
	icu_patients_per_million = NULLIF(TRIM(both '()' FROM icu_patients_per_million),''), 
	hosp_patients = NULLIF(TRIM(both '()' FROM hosp_patients),'') ,
	hosp_patients_per_million = NULLIF(TRIM(both '()' FROM hosp_patients_per_million),'') ,
	weekly_icu_admissions = NULLIF(TRIM(both '()' FROM weekly_icu_admissions),''), 
	weekly_icu_admissions_per_million = NULLIF(TRIM(both '()' FROM weekly_icu_admissions_per_million),'') ,
	weekly_hosp_admissions = NULLIF(TRIM(both '()' FROM weekly_hosp_admissions),'') ,
	weekly_hosp_admissions_per_million = NULLIF(TRIM(both '()' FROM weekly_hosp_admissions_per_million),'') ,
    new_deaths_per_million = NULLIF(TRIM(both '()' FROM new_deaths_per_million),'') ;
    
SELECT * FROM covid_deaths;

DESC covid_deaths;

 
-- Converting Data type of Cloumns---------------------------------------



ALTER TABLE covid_deaths
MODIFY total_deaths INT,
MODIFY new_deaths INT,
MODIFY icu_patients INT,
MODIFY hosp_patients INT,
MODIFY weekly_icu_admissions INT,
MODIFY weekly_hosp_admissions INT;

ALTER TABLE covid_deaths
MODIFY new_cases_smoothed DOUBLE,
MODIFY new_deaths_smoothed DOUBLE,
MODIFY new_cases_smoothed_per_million DOUBLE,
MODIFY total_deaths_per_million DOUBLE,
MODIFY new_deaths_per_million  DOUBLE,
MODIFY new_deaths_smoothed_per_million DOUBLE,
MODIFY weekly_icu_admissions_per_million DOUBLE,
MODIFY weekly_hosp_admissions_per_million DOUBLE,
MODIFY reproduction_rate DOUBLE,
MODIFY icu_patients_per_million DOUBLE,
MODIFY hosp_patients_per_million DOUBLE;

SELECT * FROM covid_deaths
WHERE continent IS NULL;

DESC covid_deaths;

----------------------------------------------------------------------------------------------


-- Select Data that we are going to be starting with


Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_deaths
Where continent is not null 
order by 1,2



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country



SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location LIKE '%ndia%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Window Funtion



SELECT *,
MAX(death_percentage)Over() AS Max_percentage
FROM (SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location LIKE '%ndia%'
ORDER BY 2) AS new_t



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


SELECT location,date,population, total_cases, ( total_cases/population*100) AS PercentPopulationInfected
FROM covid_deaths
-- WHERE location LIKE '%ndia%'
ORDER BY 1,2




-- Countries with Highest Infection Rate compared to Population



SELECT location , population , MAX(total_cases) AS HighestInfectionCount , MAX(( total_cases/population))*100 AS PercentPopulationInfected
FROM covid_deaths
-- WHERE location LIKE '%ndia%'
GROUP BY 1,2
ORDER BY PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population



SELECT location , population , MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
-- WHERE location LIKE '%ndia%'
WHERE continent IS NOT NULL
GROUP BY 1,2
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population



SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
-- WHERE location LIKE '%ndia%'
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY TotalDeathCount DESC



-- Creating View to store data for later visualizations



CREATE VIEW TotalDeathCountByContinent AS 
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
##WHERE location LIKE '%ndia%'
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY TotalDeathCount DESC

SELECT * 
FROM TotalDeathCountByContinent



-- GLOBAL NUMBERS --------------------------------



SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid_deaths
##WHERE location LIKE '%ndia%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid_deaths
##WHERE location LIKE '%ndia%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2


----------------------------------------------------------------------------------------------


-- Select data that we are going to join 


SELECT * FROM covid_vaccinations
WHERE continent IS NOT NULL

DESC covid_vaccinations;

ALTER TABLE covid_vaccinations1
RENAME TO covid_vaccinations;

UPDATE covid_vaccinations
SET new_vaccinations = NULLIF(TRIM(BOTH '()' FROM new_vaccinations),''),
	continent = NULLIF(TRIM(BOTH '()' FROM continent),'');

ALTER TABLE covid_vaccinations
MODIFY date DATE,
MODIFY new_vaccinations INT;


  
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY location ORDER BY dea.location ,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query



WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
( 
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY location ORDER BY dea.location ,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
) 
SELECT *,( RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query---------


-- TEMP TABLE-------


DROP TABLE IF EXISTS  PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
date DATE,
population INT,
new_vaccinations INT,
RollingPeopleVaccinated BIGINT
);

INSERT INTO PercentPopulationVaccinated 
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY location ORDER BY dea.location ,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3  ;

SELECT *,( RollingPeopleVaccinated/Population)*100
FROM  PercentPopulationVaccinated;




-- Creating View to store data for later visualizations



CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY location ORDER BY dea.location ,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3  ;

SELECT *
FROM PercentPopulationVaccinated




        
        



