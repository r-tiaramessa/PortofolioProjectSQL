Select *
From SqlPorto.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From SqlPorto.dbo.CovidVaccination
--order by 3,4

--select data that we are going to be using

--Select location, date, total_cases, new_cases, total_deaths, population
--From SqlPorto.dbo.CovidDeaths
--order by 1,2


--looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,  total_deaths, 
case
When total_cases = 0 then NULL
Else (cast(total_deaths as float)/total_cases)*100
End AS DeathPercentage
From SqlPorto.dbo.CovidDeaths
Where location like '%states%'
--Where continent is not null

order by 1,2

--looking at total cases vs population
Select location, date, population, total_cases, 
case
When population = 0 then NULL
Else (cast(total_cases as float)/population)*100
End AS DeathPercentage
From SqlPorto.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as Highest_infectioncount, 
case
When MAX(total_cases) = 0 Then NULL
Else (cast(MAX(total_cases) as float)/population)*100
End AS InfectedpopulationPercentage
From SqlPorto.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
GROUP BY location, population
ORDER BY InfectedpopulationPercentage desc

-- showing countries with highest death counts per population
Select location, MAX(cast(total_deaths as float)) as Total_deathscount
--case
--When MAX(total_cases) = 0 Then NULL
--Else (cast(MAX(total_cases) as float)/population)*100
--End AS InfectedpopulationPercentage
From SqlPorto.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
GROUP BY location
ORDER BY Total_deathscount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as float)) as Total_deathscount
--case
--When MAX(total_cases) = 0 Then NULL
--Else (cast(MAX(total_cases) as float)/population)*100
--End AS InfectedpopulationPercentage
From SqlPorto.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY Total_deathscount desc

-- SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
Select continent, MAX(cast(total_deaths as float)) as Total_deathscount
From SqlPorto.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY Total_deathscount desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, 
SUM(Cast(new_deaths as float))as total_deaths, 
SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage --total_cases,  total_deaths, 
--case
--When total_cases = 0 then NULL
--Else (cast(total_deaths as float)/total_cases)*100
--End AS DeathPercentage
From SqlPorto.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP by date
order by 1,2

Select SUM(new_cases) as total_cases, 
SUM(Cast(new_deaths as float))as total_deaths, 
SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage --total_cases,  total_deaths, 
--case
--When total_cases = 0 then NULL
--Else (cast(total_deaths as float)/total_cases)*100
--End AS DeathPercentage
From SqlPorto.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--GROUP by date
order by 1,2


-- dea as an alias to don't have to type the table name each time
Select *
From SqlPorto.dbo.CovidDeaths dea
Join SqlPorto.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations
From SqlPorto.dbo.CovidDeaths dea
Join SqlPorto.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- looking at total popultion vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
		dea.date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
From SqlPorto.dbo.CovidDeaths dea
Join SqlPorto.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
		dea.date) as RollingPeopleVaccinated

From SqlPorto.dbo.CovidDeaths dea
Join SqlPorto.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac





--Temp table
--Drop Table if exist #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
		dea.date) as RollingPeopleVaccinated

From SqlPorto.dbo.CovidDeaths dea
Join SqlPorto.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- if you want to add more table (easy to maintain)
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
		dea.date) as RollingPeopleVaccinated

From SqlPorto.dbo.CovidDeaths dea
Join SqlPorto.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--creating views to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
		dea.date) as RollingPeopleVaccinated

From SqlPorto.dbo.CovidDeaths dea
Join SqlPorto.dbo.CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated