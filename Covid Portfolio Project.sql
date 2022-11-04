SELECT *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--from PortfolioProject..CovidVaccinations
--order by 3,4

---Select Data to be used 

SELECT Location, date, total_cases, new_cases, population, total_deaths
FROM PortfolioProject.dbo.CovidDeaths
order by 1, 2


-- Look at total cases vs total deaths

SELECT Location, date, total_cases, population, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1, 2

--- by April 2021 the liklihood of dying after contracting covid in the US was 1.78%

--- Total Cases vs Population in US
-- Shows what percentage of population in the US contracted covid:

SELECT Location, date, total_cases, population, total_deaths, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1, 2


---Looking at countries with the highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
---where location like '%states%'
group by Location, Population 
order by PercentPopulationInfected desc 

--- Showing countries with the highest death count per population

SELECT Location, Max(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Location, Population 
order by TotalDeathCount desc 


--- total death count categorized by continent
--- showing continent with highest death count per population


SELECT location, Max(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent is null
group by location 
order by TotalDeathCount desc 


SELECT continent, Max(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent  
order by TotalDeathCount desc 

-- Global numbers 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
---where location like '%states%'
where continent is not null 
Group by date 
order by 1, 2

SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage ---, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
---where location like '%states%'
where continent is not null 
---Group by date 
order by 1, 2

---Total Death Percentage across the world  = 2.1%

---Looking at Total Population vs Vaccinations


SELECT *
FROM PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null 
  order by 1, 2, 3 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) --as RollingPeopleVaccinated  --- limit by location so that when country changes aggregation does not continue 
FROM PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null 
  order by 2, 3 

  --- Use CTE for total percentage of population vaccinated 

  With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as
  (

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) --as RollingPeopleVaccinated  --- limit by location so that when country changes aggregation does not continue 
FROM PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null 
  --order by 2, 3 
  )

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE (need to specify data type)

DROP Table if exists #PercentPopulationVaccinated
(
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) --as RollingPeopleVaccinated  --- limit by location so that when country changes aggregation does not continue 
FROM PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null 
  --order by 2, 3 

  SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create view to store data for viz

Create View PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --as RollingPeopleVaccinated  --- limit by location so that when country changes aggregation does not continue 
FROM PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null 
  --order by 2, 3 