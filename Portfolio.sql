-- SELECT THE DATA THAT WE ARE GOING TO BE USING --

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where continent is not null;
 
 -- LOOKING AT TOTAL CASES VS TOTAL DEATHS --
 
 select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where location = "United States";

-- LOOKING AT TOTAL CASES VS POPULATION --

 select location, date, total_cases, new_cases, population, (total_cases/population)*100 as infection_percentage
from covid_deaths
where location = "United States";

-- LOOKING AT COUNTRIES WITH HIGHEST TOTAL CASES VS POPULATION --

 select location, population, MAX(total_cases) as peak_infection, MAX((total_cases/population))*100 as infection_percentage
from covid_deaths
group by location, population
order by infection_percentage desc;

-- LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT VS POPULATION --

select location, MAX(CAST(TOTAL_DEATHS AS UNSIGNED)) AS PEAK_DEATHS
from covid_deaths
where continent is not null
group by location
order by peak_deaths desc;

-- LOOKING AT CONTINENTS WITH HIGHEST DEATH COUNT VS POPULATION --

select continent, MAX(CAST(TOTAL_DEATHS AS UNSIGNED)) AS PEAK_DEATHS
from covid_deaths
where continent is not null
group by continent
order by peak_deaths desc;

-- GLOBAL NUMBERS --

select SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases) * 100 as death_percentage
from covid_deaths
where continent is not null;

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS --

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date;

-- USING CTE --

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac; 

-- CREATING VIEW FOR DATA VISUALIZATIONS --

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) 
as rolling_people_vaccinated
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

Select *
from percentpopulationvaccinated