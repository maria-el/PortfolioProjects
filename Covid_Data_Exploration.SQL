-- Select data that we're going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths_and_Vaccinations
ORDER BY 1,2
LIMIT 50;

-- Total cases vs total deaths, likelihood of dying if you contract Covid-19 in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Covid_Deaths_and_Vaccinations
-- WHERE location LIKE "Morocco"
ORDER BY 1,2
LIMIT 50;

-- Total cases vs population
SELECT location, date, total_cases, (total_cases/population)*100 AS cases_percentage
FROM Covid_Deaths_and_Vaccinations
ORDER BY 1,2
LIMIT 50;

-- Infection rate per country
SELECT location, population, MAX(total_cases) AS highest_cases, MAX((total_cases/population))*100 AS infection_rate
FROM Covid_Deaths_and_Vaccinations
GROUP BY location, population
ORDER BY 4 DESC;

-- Death count per country
SELECT location, population, MAX(total_deaths) AS highest_deaths, MAX((total_deaths/population))*100 AS death_rate
FROM Covid_Deaths_and_Vaccinations
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC;

-- Death count by continent
SELECT location, MAX(total_deaths) AS highest_deaths
FROM Covid_Deaths_and_Vaccinations
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;

-- Global cases and death count
SELECT date, SUM(new_cases) AS total_cases_global, SUM(new_deaths) AS total_deaths_global
FROM Covid_Deaths_and_Vaccinations
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date ASC;

-- Total population vs vaccinations
SELECT continent, location, date, total_vaccinations, population, (total_vaccinations/population)*100 AS vaccination_percent
FROM Covid_Deaths_and_Vaccinations
WHERE continent IS NOT NULL
AND total_vaccinations IS NOT NULL
ORDER BY 2,3;

-- Calculate running total
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS running_total_vaccinations
FROM Covid_Deaths_and_Vaccinations
WHERE continent IS NOT NULL
AND new_vaccinations IS NOT NULL
ORDER BY 2,3;

-- Create a temp table
DROP TABLE IF EXISTS PercentPopVax;
CREATE TABLE PercentPopVax (continent STRING, location STRING, date DATE, population INT, new_vaccinations INT, running_total_vaccinations INT);

INSERT INTO PercentPopVax
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location, date) AS running_total_vaccinations
FROM Covid_Deaths_and_Vaccinations
WHERE continent IS NOT NULL
AND new_vaccinations IS NOT NULL
ORDER BY 2,3;

SELECT *
FROM PercentPopVax
LIMIT 50;
