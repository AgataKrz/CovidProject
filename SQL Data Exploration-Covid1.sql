SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent is not NULL
ORDER BY 3,4

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..covidDeaths
ORDER BY 5

--Total cases vs Total deaths in Poland


SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE location like '%Poland%'
ORDER BY 2,4

--Total cases vs Population

SELECT location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
FROM PortfolioProject..covidDeaths
ORDER BY 1,2

--Countries with Highest Infection Rate compared with Population

SELECT location, MAX(cast(total_cases as float)) as HighestInfectionCount, population, MAX(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest Death count per Population


SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Continents with The Highest Death count per Population


SELECT continent, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount 

--GLOBAL NUMBERS

SELECT  SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2


--Total population vs total vaccinations


SELECT dea.location, dea.population, dea.date, dea.continent, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..covidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null 
AND dea.population is not null
order by 2,3

--CTE

With PopvsVac (Continent, Population, Date, location, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.location, dea.population, dea.date, dea.continent, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..covidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null 
AND dea.population is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedRate
From PopvsVac 

--TEMP TABLE



DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(

Location nvarchar (255),
Population float,
Date datetime,
Continent nvarchar (255),
New_vaccinations float,
RollingPeopleVaccinated float
)





INSERT INTO #PercentPopulationVaccinated
SELECT dea.location, dea.population, dea.date, dea.continent, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..covidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null 
AND dea.population is not null
--order by 2,3


SELECT * FROM #PercentPopulationVaccinated

Select *, cast(RollingPeopleVaccinated as float)/(cast(Population as float)*100 as PeopleVaccinatedRate
From #PercentPopulationVaccinated



Create View PercentPopulationVaccinated as
SELECT dea.location, dea.population, dea.date, dea.continent, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..covidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null 

