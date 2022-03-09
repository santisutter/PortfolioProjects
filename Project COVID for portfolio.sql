select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4
-- ordena por columna 3 (Location) y luego por columna 4 (Date)

-- Select data that I´m going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths...
-- Shows likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathRate
from PortfolioProject..CovidDeaths
--where location like '%Argentina%'
where continent is not null
order by 1,2 

-- Looking total cases vs Population
-- Shows likelihood of contract the virus in your country
Select Location, date, total_cases, population, (total_cases/population) *100 as ContractRate
from PortfolioProject..CovidDeaths
--where location like '%Argentina%'
where continent is not null
order by 1,2 

-- Searching the most infected countries with a population higher than 1.000.000 people.
Select Location,  population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as ContractRate
from PortfolioProject..CovidDeaths
where population >= 1000000
and continent is not null
group by location, population
order by 4 desc

-- Searching the countries with highest deaths by covid per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount	
from PortfolioProject..CovidDeaths
where continent is not null
and continent != ' ' 
and location not like '%income%'
and location not like 'World'
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Argentina%'
where continent is not null
and new_cases != 0
--group by date
order by 1,2 

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as CountVaccinated
--, (CountVaccinated / Population ) *100
-- This allow the query to not count the vaccinations from different countries; 
-- when switching from one country to another, the count will start from cero. 
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.continent != ' '
order by  2, 3

-- USE CTE
-- I need this to use CountVaccinated as a column
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, CountVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as CountVaccinated
--, (CountVaccinated / Population ) *100
-- This allow the query to not count the vaccinations from different countries; 
-- when switching from one country to another, the count will start from cero. 
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.continent != ' '
--order by  2, 3
)
select *, (CountVaccinated/Population) * 100 as VaccinatedPeopleRate
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
CountVaccinated numeric
)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as CountVaccinated
--, (CountVaccinated / Population ) *100
-- This allow the query to not count the vaccinations from different countries; 
-- when switching from one country to another, the count will start from cero. 
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.continent != ' '
--order by  2, 3

select *, (CountVaccinated/Population) * 100 as VaccinatedPeopleRate
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as CountVaccinated
--, (CountVaccinated / Population ) *100
-- This allow the query to not count the vaccinations from different countries; 
-- when switching from one country to another, the count will start from cero. 
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.continent != ' '
--order by  2, 3
