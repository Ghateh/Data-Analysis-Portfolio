

Select *
From dbo.CovidDeaths
order by 3,4


--Select *
--From dbo.CovidVacccinations
--order by 3,4

--Select the data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

--looking at the Toatl cases vs Total deaths
--shows likehood of dying if you contact covid in you country(percentage)
Select location, date, total_cases,total_deaths, ((cast(total_deaths as float))/(cast(total_cases as float))*100) as DeathPercentage
from dbo.CovidDeaths
where location like '%Nigeria%'
order by 1,2

--looking at the total cases vs Population
--showing percentage of the population that got covid
Select location, date, population, total_cases, ((cast(total_cases as float))/(cast(population as float))*100) as PopulationPercentageInfected
from dbo.CovidDeaths
where location like '%Nigeria%'
order by 1,2

--looking at countries with highest infection rate compared to Population
Select location, population, max(total_cases) as MaxInfectionCount, max((cast(total_cases as float))/(cast(population as float))*100) as PopulationPercentageInfected
from dbo.CovidDeaths
--where location like '%Nigeria%'
group by location, population
order by PopulationPercentageInfected desc

--showing countries with the highest death cout per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCounts
from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location
order by TotalDeathCounts desc

--lets break things down by continent 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCounts
from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCounts desc



--Showing the continent with the highest death count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCounts
from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCounts desc


--Global Numbers

Select Sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as Total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2

--To join the two tables

Select *
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date


-- we look at the total population vs vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, Sum(convert(float,cv.new_vaccinations )) over (partition by cd.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--Use CTE

with Popvscv (Continent, Location, Date, Population, New_Vaccinatins, RollingPeopleVaccinaated)
as
(select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, Sum(convert(float,cv.new_vaccinations )) over (partition by cd.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinaated/Population)*100 as TotalPercentage
from Popvscv


--Temp Table


Drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinaated numeric
)



insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, Sum(convert(float,cv.new_vaccinations )) over (partition by cd.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinaated/Population)*100 as TotalPercentage
from #PercentPopulationVaccinated


--Creating View to data for later

Create View PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, Sum(convert(float,cv.new_vaccinations )) over (partition by cd.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated