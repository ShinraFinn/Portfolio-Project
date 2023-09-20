Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2

--Here I'm comparing the Total Number of Deaths to the Total Number of Cases
--This Query shows the chances(%) of dying if you get covid based on the country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%China%'
order by 1,2


--Here I'm comparing the Total Number of Cases to the Population
--This Query shows the percentage of people who fot covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%China%'
order by 1,2 


--This Query shows the Countries with the Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfection
From PortfolioProject1..CovidDeaths
--Where location like '%China%'
Group by Location, Population
order by PercentagePopulationInfection desc


--This Query shows the Countries with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%China%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--This Query shows the Continent with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%China%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Global Deaths Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobaDeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%south africa%'
where continent is not null
--Group By date
order by 1,2


-- Here I'm comparing the Total Population to the Vaccinations


Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinatedPeople
 --, (RollingVaccinatedPeople/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Here I'm using CTE to Query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedPeople)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinatedPeople
 --, (RollingVaccinatedPeople/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinatedPeople/Population)*100
From PopvsVac


--Here I'm Creating a Table of the percentage of people vaccinated


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinatedPeople
 --, (RollingVaccinatedPeople/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Now I'm going to create a view query for data visualization


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingVaccinatedPeople
 --, (RollingVaccinatedPeople/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated