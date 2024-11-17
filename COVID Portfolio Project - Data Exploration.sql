use PortfolioProject
go
select Location,date,total_cases,total_deaths,population
from PortfolioProject..CovidDeaths

select Location,date,total_cases,total_deaths,(Cast(total_deaths as float)/cast(total_cases as float))*100 DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%vietnam%' and total_deaths is not null

select Location,date,total_cases,population,(cast(total_cases as float)/population)*100 case_per_population
from PortfolioProject..CovidDeaths
where location like '%vietnam%' and total_deaths is not null
order by 1,2

select location,population,Max(total_cases) highestCases,(cast(Max(total_cases) as float)/cast(population as float))*100 PercentPopulationinfected
from PortfolioProject..CovidDeaths
where total_cases is not null
group by location,population
order by PercentPopulationinfected desc

select location,Max(total_deaths) highestdeahs
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by highestdeahs desc

select continent,Max(total_deaths) highestdeahs
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by highestdeahs desc

select date,sum(new_cases) totalnewcases ,sum(new_deaths) totaldeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by date
having sum(new_cases) is not null and sum(new_deaths) is not null
order by date



select d.continent, d.location,d.date, d.population,v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) ppvaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date =v.date
where d.continent is not null and v.new_vaccinations is not null

-- use cte

with popvsVac (Continent, Locaction, Date, Population, New_vaccinations, ppvaccinated)
as
(
select d.continent, d.location,d.date, d.population,v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) ppvaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date =v.date
where d.continent is not null and v.new_vaccinations is not null
)
select *,round((cast(ppvaccinated as float)/cast(Population as float))*100,2)
from popvsVac

-- Temp Table

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
select d.continent, d.location,d.date, d.population,v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) ppvaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
on d.location = v.location and d.date =v.date
where d.continent is not null and v.new_vaccinations is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 