Select *
from portifolio..coviddeths
--where location is not null
order by 3,4

--Select *
--from portifolio..covidvaccines
--order by 3,4

Select location, date ,total_cases , new_cases,total_deaths, population
from portifolio..coviddeths
where location is not null
order by 1,2


Select location, date ,total_cases ,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portifolio..coviddeths
where location like '%states%'
order by 1,2

Select location, date ,population,total_cases , (total_cases/population)*100 as covidpercentage
from portifolio..coviddeths
where location like '%zimbabwe%'
order by 1,2

Select location,population,MAX(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as covidpercentage
from portifolio..coviddeths
--where location like '%zimbabwe%'
group by location,population
order by covidpercentage desc

--showing countires with high death count

Select location, max(cast(total_deaths as int)) as totaldeathcount
from portifolio..coviddeths
--where location like '%zimbabwe%'
where continent is not null
group by location
order by totaldeathcount desc

--breaking things by contint
--showing continent ith highest death count

Select continent, max(cast(total_deaths as int)) as totaldeathcount
from portifolio..coviddeths
--where location like '%zimbabwe%'
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers

Select  date ,sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as tota_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portifolio..coviddeths
--where location like '%states%'
where  continent is not null
group by date 
order by 1,2

--total population v vaccination

select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location,dea.date) as rollingvac
from portifolio..coviddeths dea
join portifolio..covidvaccines vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

 --using cte

 with popvsvac(continent,locatio,date,population,new_vaccinations,rollingvac)
as
(
select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location Order by dea.location,
dea.date) as rollingvac
from portifolio..coviddeths dea
join portifolio..covidvaccines vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(rollingvac/population)*100
from popvsvac

--temp table

DROP Table If exists #percentpopulstionvsccinated
Create Table #percentpopulstionvsccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvac numeric
)

Insert into #percentpopulstionvsccinated
select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location Order by dea.location,
dea.date) as rollingvac
from portifolio..coviddeths dea
join portifolio..covidvaccines vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingvac/population)*100
from #percentpopulstionvsccinated

--creating view to show data

create view PercentPopulstionvacc as
select dea.continent,dea.location ,dea.date,dea.population,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint )) over (partition by dea.location Order by dea.location,
dea.date) as rollingvac
from portifolio..coviddeths dea
join portifolio..covidvaccines vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

