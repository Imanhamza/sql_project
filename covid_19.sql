
SELECT location, date,total_cases,new_cases,total_deaths,population
FROM covid..covid_deaths
ORDER BY 1,2

-- Total cases vs total death
SELECT location, date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deaths_percentage
FROM covid..covid_deaths
WHERE location like '%egypt%'
ORDER BY 1,2

--Total Cases vs Population

SELECT location, date,total_cases,new_cases,population, (total_cases/population)* 100 as cases_percentage
FROM covid..covid_deaths
WHERE location like '%egypt%'
ORDER BY date DESC

-- Highest infection rate 


SELECT location,MAX(total_cases) as highest_cases,population, MAX((total_cases/population)* 100) as highest_infection
FROM covid..covid_deaths
GROUP BY location, population
ORDER BY highest_infection desc 

-- Total death 
SELECT location,MAX(cast(total_deaths as int)) as deaths_count
FROM covid..covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY deaths_count DESC

--SELECT continent,MAX(cast(total_deaths as int)) as deaths_count
--FROM covid..covid_deaths
--WHERE continent is not null
--GROUP BY continent
--ORDER BY deaths_count DESC

SELECT location,MAX(cast(total_deaths as float)) as deaths_count
FROM covid..covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY deaths_count DESC

--Global Numbers 
-- Total Deaths percentage across the world Day by Day
SELECT date, SUM(new_cases) as total_cases_sum, SUM(cast(new_deaths as float)) as total_deaths_sum, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as deaths_percentage
FROM covid..covid_deaths 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total cases and deaths till now 

SELECT SUM(new_cases) as total_cases_sum, SUM(cast(new_deaths as float)) as total_deaths_sum, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as deaths_percentage
FROM covid..covid_deaths 
WHERE continent is not null
ORDER BY 1,2

-- Cocid Vaccination 
--Joining two tables (Poplutaion vs Vaccination)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM covid..covid_deaths dea
join covid..covid_vac vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3 

-- CTE

WITH pop_vac(continent, location, date, population,new_vaccinations, vaccinated_people)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vac_people
FROM covid..covid_deaths dea
join covid..covid_vac vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *, (vaccinated_people/population)*100 as vaccinated_people_percentage
FROM pop_vac
--ORDER BY 3 DESC

-- Creating temp table
DROP TABLE if exists #VacPeoplePercentage
CREATE TABLE #VacPeoplePercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinated_people numeric
)
INSERT INTO #VacPeoplePercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vac_people
FROM covid..covid_deaths dea
join covid..covid_vac vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (vaccinated_people/population)*100 as vaccinated_people_percentage
FROM #VacPeoplePercentage

-- Creating view for later visualization 

CREATE view VacPeoplePercentage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vac_people
FROM covid..covid_deaths dea
join covid..covid_vac vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null 