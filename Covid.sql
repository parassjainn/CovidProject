
select *
from dbo.[Covid Deaths]
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from dbo.[Covid Deaths]
where continent is not null
order by 1,2



-- Looking for total case vs tortal death   in india
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.[Covid Deaths]
where location like '%India%'
order by 1,2



-- looking at total case vs population 
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from dbo.[Covid Deaths]
where location like '%India%'
order by 1,2

-- Country with highest infection rate compared to population 
select location, Population, max(cast(total_cases as int)) as HighestInfectionRate, Max((total_cases/population))*100 as Percentpopulationinfected
from dbo.[Covid Deaths]
group by location, population
order by Percentpopulationinfected desc

--lets break by continents
select location ,  max(cast(total_deaths as int)) as TotalDeathcount
from dbo.[Covid Deaths]
where continent is  null
group by location
order by TotalDeathcount desc
--Countries with highest death per population

select location,  max(cast(total_deaths as int)) as TotalDeathcount
from dbo.[Covid Deaths]
where continent is not null
group by location
order by TotalDeathcount desc



-- continent with highest death counts 
select continent ,  max(cast(total_deaths as int)) as TotalDeathcount
from dbo.[Covid Deaths]
where continent is not null
group by continent
order by TotalDeathcount desc


-- Global Numbers 
select  SUM(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths,
sum(cast (new_deaths as int))/sum(new_cases)*100 as deathpercenatge
from dbo.[Covid Deaths]
where continent is not null
group by date
order by 1,2

--join covid death anf vaccination 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by  dea.location, dea.date)
as rolling_people_vaccinated
from dbo.[Covid Deaths] dea
join dbo.[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- use cte

with popvsvac( continent, location, date, population, new_vaccinations,rolling_people_vaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by  dea.location, dea.date)
as rolling_people_vaccinated
from dbo.[Covid Deaths] dea
join dbo.[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
) 
select *
from popvsvac

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
rollingpeoplevaccinated numeric
)


insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations )) over (partition by dea.location order by  dea.location, dea.date)
as rollingpeoplevaccinated

from dbo.[Covid Deaths] dea
join dbo.[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select *, ( rollingpeoplevaccinated / population)*100
from #percentpopulationvaccinated

-- create a view to store data for visualization
create  view percentpopulationvaccinated as 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations )) over (partition by dea.location order by  dea.location, dea.date)
as rollingpeoplevaccinated

from dbo.[Covid Deaths] dea
join dbo.[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
from percentpopulationvaccinated