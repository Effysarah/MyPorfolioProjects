SELECT*
FROM  PortfolioProject..CovidDeaths$
ORDER BY 3,4


--SELECT*
--FROM  PortfolioProject..CovidVaccination$
--ORDER BY 3,4



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM  PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at the total_cases vs total_deaths


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM  PortfolioProject..CovidDeaths$
---WHERE location like '%Nigeria%'
ORDER BY 1,2


--Looking at the Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM  PortfolioProject..CovidDeaths$
---WHERE location like '%Nigeria%'
ORDER BY 1,2


--Looking at Countries with the highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM  PortfolioProject..CovidDeaths$
---WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


--Countries with the highest Death Count Per Population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
---WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM  PortfolioProject..CovidDeaths$
---WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM  PortfolioProject..CovidDeaths$
---WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT*
FROM  PortfolioProject..CovidVaccinations$


--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

--With Cte


With  PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


---using Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPopulationVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPopulationVaccinated)*100
FROM  #PercentagePopulationVaccinated

--Using Create View

CREATE VIEW [PercentagePopulationVaccination] AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



SELECT *
FROM PercentagePopulationVaccination



CREATE VIEW [PercentagePopulationInfected] AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM  PortfolioProject..CovidDeaths$
---WHERE location like '%Nigeria%'
GROUP BY location, population
--ORDER BY PercentagePopulationInfected DESC


SELECT *
FROM PercentagePopulationInfected