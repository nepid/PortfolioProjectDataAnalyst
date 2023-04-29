

---EVERYTHING FROM CovidDeaths Table

select*
from FirstDatabase..CovidDeaths
order by 3,4

-- Looking at Total cases vs Population

select location, date, total_cases, total_deaths, (total_deaths/ total_cases) *100 as DeathPercentage
from FirstDatabase..CovidDeaths
where location like '%states%'
order by 3

select location, date, total_cases, total_deaths, (total_deaths/ total_cases) *100 as DeathPercentage
from FirstDatabase..CovidDeaths
where location='Nepal'
order by 3


-- looking at total cases vs population
-- shows what percentage of population got COVID

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from FirstDatabase..CovidDeaths
where location='Nepal'
order by 3

-- countries with the Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighesetInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
from FirstDatabase..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc


-- showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from FirstDatabase..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Continents with the Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from FirstDatabase..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Looking at Total cases vs Total death as DeathPercentage per Cases

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from FirstDatabase..CovidDeaths
where continent is not null
group by date

-- Looking at Total cases vs Total death as DeathPercentage per Cases-- TILL THE LAST DAY OF THE RECORD
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from FirstDatabase..CovidDeaths
where continent is not null
--group by date


-- JOINING TWO TABLE

Select*
From FirstDatabase..CovidVaccinations

Select*
From FirstDatabase..CovidDeaths dea
Join FirstDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population Vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From FirstDatabase..CovidDeaths dea
Join FirstDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Rollling Count of vaccination of Each country, Each day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From FirstDatabase..CovidDeaths dea
Join FirstDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- Finding the percentage of Vaccination Percentage of Each country, Each day-- using CTE

with cte as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From FirstDatabase..CovidDeaths dea
Join FirstDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/cte.population)*100 as PercentagePeopleVaccinated
from cte
order by PercentagePeopleVaccinated desc


-- another way of using CTE on the same problem

with PopVsVac (Continent, Location, Date, Population, New_VAccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From FirstDatabase..CovidDeaths dea
Join FirstDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
from PopVsVac
--order by PercentagePeopleVaccinated desc


-- another way of using TEMP TABLE on the same problem

DROP Table if exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From FirstDatabase..CovidDeaths dea
Join FirstDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
from #PercentagePeopleVaccinated

-- Creating View to store data for Later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From FirstDatabase..CovidDeaths dea
Join FirstDatabase..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null