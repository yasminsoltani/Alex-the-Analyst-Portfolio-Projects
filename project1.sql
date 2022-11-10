----

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Projects]..['covid deaths$']
WHERE continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--likelyhood of dying if you contract covid in your country

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Projects]..['covid deaths$']
WHERE location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM [Portfolio Projects]..['covid deaths$']
-- WHERE location like '%states%'
WHERE continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS 
PercentPopulationInfected
FROM [Portfolio Projects]..['covid deaths$']
WHERE continent is not null
GROUP BY Location, population
-- WHERE location like '%states%'
order by PercentPopulationInfected desc

--Showing Countries with the Highest Deat Count per Population 
SELECT Location, max(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Projects]..['covid deaths$']
WHERE continent is not null
GROUP BY Location
-- WHERE location like '%states%'
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing continents with the highest death count per population

SELECT continent, max(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Projects]..['covid deaths$']
WHERE continent is not null
GROUP BY continent
-- WHERE location like '%states%'
order by TotalDeathCount desc



--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Projects]..['covid deaths$']
WHERE continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
AS RollingPeopoleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Projects]..['covid deaths$'] as dea
JOIN [Portfolio Projects]..['covid vaccinations$'] as vac
On dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
AS

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
AS RollingPeopoleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Projects]..['covid deaths$'] as dea
JOIN [Portfolio Projects]..['covid vaccinations$'] as vac
On dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

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

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
AS RollingPeopoleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Projects]..['covid deaths$'] as dea
JOIN [Portfolio Projects]..['covid vaccinations$'] as vac
On dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View Percent