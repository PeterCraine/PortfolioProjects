Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking into Total Cases versus Total Deaths 
--Looking into percent risk of death if Covid is contracted by country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' 
Order by 1,2

--Looking into Total Cases versus Population
--Looking into Population percentage that contracted Covid

Select Location, Date, Population, Total_cases, (Total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%' 

--Looking into Countries with Highest Infection Rate compare to Population
Select Location, Population, Max(Total_cases) as HighestInfectionCount, Max((Total_cases/population))*100 as HighestPercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
Order by HighestPercentPopulationInfected desc

--Showing Countries with the Highest Death Count per Population
Select Location, Max(cast(Total_Deaths as int)) as HighestTotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by HighestTotalDeathCount desc

--Broken down by Continent
Select location, Max(cast(Total_Deaths as int)) as HighestTotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null and location not like '%income'
Group by location
Order by HighestTotalDeathCount desc

--Showing continents with highest death count per population

Select continent, Max(cast(Total_Deaths as int)) as HighestTotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
Order by HighestTotalDeathCount desc

--Global Numbers By Date
Select Date, Sum(new_cases)as Daily_Total_Cases, Sum(cast(new_deaths as int))as Daily_Total_Deaths, Sum(cast(new_deaths as int))/NULLIF(Sum(new_cases),0)*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' and 
Where continent is not null
Group by Date
Order by 1,2


--Global Numbers 
Select Sum(new_cases)as Total_Cases, Sum(cast(new_deaths as int))as Total_Deaths, Sum(cast(new_deaths as int))/NULLIF(Sum(new_cases),0)*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' and 
Where continent is not null
--Group by Date
Order by 1,2

--Total Population versus Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--New Vaccinations per Day
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate, (RollingPeopleVaccinate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Option 1: USE CTE

With PopVersusVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVersusVac


--Option 2: TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for Tableau visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated