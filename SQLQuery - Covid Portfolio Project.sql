
SELECT *
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--THE TOTAL CASES VS TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathProcentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--THE TOTAL CASES VS POPULATION
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesProcentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) AS HighestInfenctionCount, MAX((total_cases/population))*100 AS ProcentPopulationInfected
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY ProcentPopulationInfected DESC


--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount, MAX((CAST(total_deaths AS INT)/population))*100 AS ProcentPopulationDeath
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--CONTINENTS WITH THE HIGHEST DEATH COUNT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount --MAX((CAST(total_deaths AS INT)/population))*100 AS ProcentPopulationDeath
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS from 01.01.2020 to 30.04.2021
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 DeathProcentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100       --you can not use RollingPeopleVaccinated!!! you need to create CTE or TEMP TABLE
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations AS vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



---CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations AS vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations AS vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2

Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR FUTURE VISUALISATIONS (TABLEAU)

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths AS dea
JOIN CovidPortfolioProject..CovidVaccinations AS vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

  SELECT *
  FROM PercentPopulationVaccinated