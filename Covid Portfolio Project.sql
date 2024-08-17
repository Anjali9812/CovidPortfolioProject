
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4



--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location ,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null

--Looking at Total cases vs Total Death

Select Location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at the Total cases vs Population
--Showing what percentage of population got covid

Select Location ,date,Population,total_cases ,(total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


--Looking at the Countries with highest infection Rate compared to Population

Select Location ,Population,MAX(total_cases) as HighestInfectionCount ,MAX((total_cases/Population))*100 as
PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location , Population
order by PercentPopulationInfected desc


--Showing Countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathcount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continent with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathcount desc



--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


--Looking at total Population Vs Vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(int, v.new_vaccinations )) OVER (Partition by d.location Order by d.location, d.date) 
as Rollingpeoplevaccinated
From PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
   ON d.location = v.location
   and d.date = v.date
Where d.continent is not null
order by 2,3



--Use CTE
With Popvsvac(Continent,location , date , population,new_vaccination,Rollingpeoplevaccinated)
as(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(int, v.new_vaccinations )) OVER (Partition by d.location Order by d.location, d.date) 
as Rollingpeoplevaccinated
From PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
   ON d.location = v.location
   and d.date = v.date
Where d.continent is not null
)
Select *, (Rollingpeoplevaccinated/population)*100
from Popvsvac


--Temp Table
Drop Table if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinated numeric,
Rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(int, v.new_vaccinations )) OVER (Partition by d.location Order by d.location, d.date) 
as Rollingpeoplevaccinated
From PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
   ON d.location = v.location
   and d.date = v.date
--Where d.continent is not null

Select * , (Rollingpeoplevaccinated/population)*100
From #percentpopulationvaccinated


--Creating view to store data for later visualizations

Create view percentpopulationvaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Convert(int, v.new_vaccinations )) OVER (Partition by d.location Order by d.location, d.date) 
as Rollingpeoplevaccinated
From PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
   ON d.location = v.location
   and d.date = v.date
 Where d.continent is not null

 Select * 
 From percentpopulationvaccinated