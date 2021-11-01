--select *
--from CovidVaccinations

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM CovidDeaths
order by 1,2


-- Looking at total case vs total deaths
UPDATE CovidDeaths
SET total_cases = NULL  
WHERE total_cases = 0

SELECT distinct location
FROM CovidDeaths
order by 1

SELECT location,date, population, total_cases, total_deaths, total_deaths/total_cases * 100 as PercentofDeathsvsCases
FROM CovidDeaths
WHERE location = 'Finland'
ORDER BY 1,2

SELECT location,date, population, total_cases,  total_cases/population * 100 as PercentofCasesvsPopulation
FROM CovidDeaths
WHERE location = 'Finland'
ORDER BY 1,2

SELECT location,date, population, total_cases,  total_cases/population * 100 as PercentofCasesvsPopulation
FROM CovidDeaths
WHERE location = 'Vietnam'
ORDER BY 1,2

-- What country has the highest infection rate?
SELECT location, MAX(population) AS population, MAX(total_cases) AS total_cases, (MAX(total_cases)/MAX(population))*100 as InfectionRate
FROM CovidDeaths
GROUP BY location
ORDER BY 4 DESC

-- Showing the countries with the highest Death Count per populatioN 
SELECT location, population, MAX(CAST(total_deaths AS INT)) as total_deaths--, (MAX(total_deaths)/population)*100 as DeathPercentperPopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 desc

-- BY CONTINENTS
-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) as total_deaths--, (MAX(total_deaths)/population)*100 as DeathPercentperPopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths desc

-- Can drill down
SELECT continent, location,sum(population) as population, MAX(CAST(total_deaths AS INT)) as total_deaths--, (MAX(total_deaths)/population)*100 as DeathPercentperPopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY total_deaths desc

-- GLOBAL NUMBERS
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INT

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INT

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths INT

ALTER TABLE CovidDeaths
ALTER COLUMN date DATE

SELECT date, sum(total_cases) as total_cases, sum(total_deaths) as total_deaths, 
         SUM(new_cases) AS new_cases, SUM(new_deaths) as newdeaths,
         (sum(new_deaths)/sum(new_cases))*100 as PercentDeathsEachDay
FROM CovidDeaths
WHERE continent is NOT NULL
--AND date <= '2021-04-30'
GROUP BY date
ORDER BY date

SELECT    SUM(new_cases) AS new_cases, 
          SUM(new_deaths) as newdeaths,
         (sum(new_deaths)/sum(new_cases))*100 as PercentDeathsEachDay
FROM CovidDeaths
WHERE location = 'Vietnam'

-- How many people in the world who have gotten vaccinations
ALTER TABLE CovidVaccinations
ALTER COLUMN total_vaccinations BIGINT

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations INT


WITH PopVSVacc AS (
SELECT d.location, max(population) as population, max(total_vaccinations) as total_vaccinations
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
GROUP BY D.location
-- ORDER BY location
)

SELECT SUM(population) as world_population, SUM(total_vaccinations) as world_total_vaccinations
FROM PopVSVacc

SELECT d.location, d.date, d.population, v.new_vaccinations, v.total_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (PARTITION BY d.location order by d.date) as sum_new_vacc, 
(total_vaccinations/d.population)*100 as PercentVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null and d.location = 'Finland'
order by 1,2
--GROUP BY d.population

