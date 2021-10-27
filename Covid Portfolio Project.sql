Select *
From PortfolioProject..covid_deaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..covid_vaccinations$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths$
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths$
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population has had covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentOfPopulationInfected
From PortfolioProject..covid_deaths$
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at countries with highest infection rate 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
From PortfolioProject..covid_deaths$
--Where location like '%states%'
Where continent is not null
Group by Location, Population 
order by PercentOfPopulationInfected desc


-- Showing Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is not null
Group by Location 
order by TotalDeathCount desc

-- Breaking things down by continent
-- Showing the continents with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths$
Where continent is null
Group by location 
order by TotalDeathCount desc


-- Global numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths$
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2


-- Looking a total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinations/Population)*100
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
) 

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'Canada'
--order by 2,3

Select *, (RollingVaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View CanadaPercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'Canada'
--order by 2,3

Select * 
From CanadaPercentPopulationVaccinated
 
