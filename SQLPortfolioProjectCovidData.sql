-- COVID Portfolio Build

--SELECT *
--FROM PortfolioProject..CovidDeaths
--WHERE continent is not null -- because location and continent can be confused in the data set 
--ORDER BY 3,4

-- 1. 
-- Showing only Data that I will be using
-- First I will look at Covid Deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- 2. 
-- Looking at Total Cases vs Total Deaths
-- Percentage of Death in the USA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2 desc

-- 3. 
-- Looking at Total Cases vs Population 
-- Shows what percentage of US population got COVID (can change to any country)

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageGotCovid
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2 desc

-- 4. 
-- Highest Infection Rates per Country

SELECT location, population, MAX(total_cases) AS HighestInfestionCount, MAX((total_cases/population))*100 AS PercentageGotCovid
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population 
ORDER BY PercentageGotCovid desc

-- 5. 
-- Showing Countries with Highest Death Count per Population 
-- Casted Total Deaths as bigint data type to convert from nvarchar(255) 

SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- 6. 
-- Showing Continents with Highest Death Count

SELECT continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- 7. 
-- Showing Continents and Income Levels with Highest Death Count

SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- 8. 
-- Global Total Cases, Deaths, & Death Percentage Per Day
-- Cast New Deaths as BigInt to replace nvarchar data type

SELECT date, SUM(new_cases) AS DailyCases, SUM(cast(new_deaths as bigint)) AS DailyDeaths,
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS DailyDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 desc

-- 9. 
-- Global Total Cases, Deaths, Death Percentage as of December 2022

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as bigint)) AS TotalDeaths,
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- 10. 
-- Next I will look at COVID Vaccinations 
-- Joined with COVID Deaths for Location and Data
-- Looking at Total Population vs Vaccinations

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
FROM PortfolioProject..CovidDeaths AS Deaths
Join PortfolioProject..CovidVaccinations AS Vax
	ON Deaths.location = Vax.location
	and Deaths.date = Vax.date
WHERE Deaths.continent is not null
ORDER BY 2,3

-- 11. 
-- Creating a CTE to use for a Rolling Count Function
-- CTE number of Columns need to be the same as oringial query

--WITH PopvsVax (continent, location, date, population, new_vaccinations, RollingCount)
--AS
--(
--SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations,
--SUM(Cast(Vax.new_vaccinations as bigint)) OVER (Partition by Deaths.location ORDER BY Deaths.location, 
--Deaths.date) AS RollingCount
--FROM PortfolioProject..CovidDeaths AS Deaths
--Join PortfolioProject..CovidVaccinations AS Vax
--	ON Deaths.location = Vax.location
--	and Deaths.date = Vax.date
--WHERE Deaths.continent is not null
--)
--SELECT *
--FROM PopvsVax

-- 12. 
-- Using my CTE to Create a function to show percentage vaxxed 

WITH PopvsVax (continent, location, date, population, new_vaccinations, RollingCount)
AS
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations,
SUM(Cast(Vax.new_vaccinations as bigint)) OVER (Partition by Deaths.location ORDER BY Deaths.location, 
Deaths.date) AS RollingCount
FROM PortfolioProject..CovidDeaths AS Deaths
Join PortfolioProject..CovidVaccinations AS Vax
	ON Deaths.location = Vax.location
	and Deaths.date = Vax.date
WHERE Deaths.continent is not null
)
SELECT *, (RollingCount/population)*100 AS PercentageVaccinated
FROM PopvsVax

-- 13. 
-- Creating a TEMP Table  

DROP Table if exists #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations bigint,
RollingCount bigint
)

INSERT INTO #PercentVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations,
SUM(Cast(Vax.new_vaccinations as bigint)) OVER (Partition by Deaths.location ORDER BY Deaths.location, 
Deaths.date) AS RollingCount
FROM PortfolioProject..CovidDeaths AS Deaths
Join PortfolioProject..CovidVaccinations AS Vax
	ON Deaths.location = Vax.location
	and Deaths.date = Vax.date
WHERE Deaths.continent is not null

SELECT *, (RollingCount/population)*100 AS PercentageVaccinated
FROM #PercentVaccinated

-- 14. 
-- Creating View(s) to store data for visualizations 
-- In another Query, but added to this repository to see

--CREATE VIEW TotalDeathCount AS
--SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent is null
--GROUP BY location
----ORDER BY TotalDeathCount desc