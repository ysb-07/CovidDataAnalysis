select * 
from PortfolioProject..CovidDeaths
order by 3, 4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3, 4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

--Total cases vs Total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1, 2


--Total cases vs population
--% population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentageCovid
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1, 2


--countries with highest covid rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by PercentagePopulationInfected desc


--Countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--By Continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2



--Total population vs vaccinations

select * from
PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

With PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP Table

drop table if exists #PercentPopulataionVaccinated
create table #PercentPopulataionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulataionVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2, 3

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulataionVaccinated


--Creating view to store data for later visualisation

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2, 3

select * from
PercentPopulationVaccinated
