select *
From PortfolioProject..CovidDeaths
order by 3,4

select *
From PortfolioProject..CovidVaccinations
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%kingdom%' and continent is not null
order by 1,2

Select Location, date, Population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%kingdom%' and continent is not null
order by 1,2

Select Location, Population, MAX(total_cases) as TotalInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentaage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentaage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

with PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccination, CumulativeVaccinations) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.Date) as CumulativeVaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
)
Select *, (CumulativeVaccinations/Population)*100
From PercentPopulationVaccinated

ALTERNATIVE METHOD: 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.Date) as CumulativeVaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null

Select *, (CumulativeVaccinations/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.Date) as CumulativeVaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null

Create View DeathPercentage as 
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentaage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
