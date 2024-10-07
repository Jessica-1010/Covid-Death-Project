SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER by 3,4

-- Select Data to use:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER by 1,2

-- Looking at % Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER by 1,2

--Looking at % Total cases vs Population 
SELECT location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER by 1,2

--Which country has the highest infection rate?
SELECT location, MAX(total_cases) as highest_cases, population, MAX((total_cases/population)*100) as infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER by infection_rate DESC

--Which countries with the highest death per population?
SELECT location, population, MAX(cast(total_deaths as int)) as total_death
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP By location, population
ORDER by total_death DESC

--Break things down by continent
SELECT location, MAX(cast(total_deaths as int)) as total_death
FROM PortfolioProject..CovidDeaths
Where continent is null
GROUP By  location
ORDER by total_death DESC

--Showing continent with the hightst death count per population
SELECT continent, MAX(cast(total_deaths as int)) as total_death
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP By  continent
ORDER by total_death DESC

-- Global numbers per day
SELECT SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths,  SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as global_death_percentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
ORDER by 1,2

-- Join the two table on date and location
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date

-- Total population vs. Vaccinations.  How many people are vaccinated. with CTE

With PopVacCTE(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (rollingpeoplevaccinated/population)*100
From PopVacCTE

-- Total population vs. Vaccinations.  How many people are vaccinated. with TEMP TABLE
DROP TABLE if exists #percentpopvaccinated
CREATE TABLE #percentpopvaccinated
(
continent nvarchar(255), 
location nvarchar(225), 
date datetime, 
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #percentpopvaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
 
SELECT *, (rollingpeoplevaccinated/population)*100
FROM #percentpopvaccinated


-- creating view to store data for later visualizations
CREATE VIEW PopVacCTE as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null;

CREATE VIEW highest_death_rate as 
SELECT location, population, MAX(cast(total_deaths as int)) as total_death
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP By location, population
--ORDER by total_death DESC
