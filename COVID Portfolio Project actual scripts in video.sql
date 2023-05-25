SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1

--ALTER TABLE CovidVaccinations
--ALTER COLUMN new_vaccinations float;

--UPDATE CovidVaccinations
--SET new_vaccinations = NULL
--WHERE new_vaccinations = '';

--UPDATE CovidVaccinations
--SET date = FORMAT(CONVERT(datetime, date), 'yyyy-MM-dd')


-- Looking at the total cases vs Population
-- shows what percentage  of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfec
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- showing the countries with the highest death count per population
SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's break things down by continent

-- showing the continents with the highest death count per population

SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLobal numbers

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1


-- Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
WHERE dea.continent is not NULL 
	AND vac.continent is not NULL
ORDER BY 2, 3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
WHERE dea.continent is not NULL 
	AND vac.continent is not NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated
FROM PopvsVac

-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
--WHERE dea.continent is not NULL 
--	AND vac.continent is not NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
WHERE dea.continent is not NULL 
	AND vac.continent is not NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated