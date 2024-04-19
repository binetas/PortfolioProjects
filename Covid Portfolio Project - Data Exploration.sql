--SELECT *
--FROM [dbo].[CovidDeaths]

-- Select data that we are going to be using

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%state%'
order by 1,2

-- Looking at countries with Hightest Infection Rate compared  to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as 
	PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%state%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%state%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the Highest death count per population
 
 
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%state%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCase, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%state%'
where continent is not null
order by 1,2

 
 -- Looking at Population vs Vaccinations
 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, RollingPeopleVaccinated
From PopvsVac





-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *
from PercentPopulationVaccinated
