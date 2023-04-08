select * 
from CovidDeaths$
order by 3,4

select * 
from [PortafolioProject].[dbo].[CovidVaccinations$]
order by 3,4


--Select Data that we are going to use
select location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths$
order by 1,2


--Looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows porcentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as CovidPorcentage
from CovidDeaths$
where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercetPopulationInfected
from CovidDeaths$
group by location,population
order by PercetPopulationInfected desc

--showing countries with highest death count per population
select location,MAX(cast(total_deaths as int) ) as HighestDeathsCount
from CovidDeaths$
where continent is not null
group by location
order by HighestDeathsCount desc

--by continent
select continent,MAX(cast(total_deaths as int) ) as HighestDeathsCount
from CovidDeaths$
where continent is not  null
group by continent
order by HighestDeathsCount desc

--global numbers

select date,sum(new_cases), sum(cast(new_deaths as int)) as total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
order by 1,2

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations  as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations  as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into  #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations  as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations  as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated
