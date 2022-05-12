select *
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null

-- A chance de você vir a falecer caso você pegue Covid no seu país
select location, date, ((total_deaths/total_cases) *100) as 'Porcentagem de Mortes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
--where location like '%Brazil%' -- Aqui basta inserir o nome do país
Order by 1,2



-- A porcentagem de mortes pela quantidade de habitantes
select location, date, population, ((total_deaths/population)*100) as 'Mortes/Habitantes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
--where location like '%Brazil%' -- Aqui basta inserir o nome do país
Order by 1,2



-- A porcentagem de contaminação pelo total de habitantes
select location, date, population, ((total_cases/population)*100) as 'Porcentagem da População Infectada'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
--where location like '%Brazil%' -- Aqui basta inserir o nome do país
Order by 1,2


-- Países com a maior taxa de contaminação pela quantidade de habitantes
select location, population, Max(total_cases), Max((total_cases/population)*100) as 'Porcentagem da População Infectada'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
Group by location, population
Order by 4 desc


-- Países com as maiores taxas de mortalidade
select location, Max(total_deaths) as 'Contagem total de mortes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
Group by location
Order by 2 desc



--        Quebrando por continente 


-- Maiores taxas de mortalidades por continente

select location, Max(total_deaths) as 'Contagem total de mortes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is null
group by location
Order by 2 desc

-- A chance de você vir a falecer caso você pegue Covid no seu continente
select continent, date, ((total_deaths/total_cases) *100) as 'Porcentagem de Mortes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
Order by 2 desc


-- Continentes com a maior taxa de contaminação pela quantidade de habitantes
select continent, sum(total_cases) as 'Total de casos', Max((total_cases/population)*100) as 'Porcentagem da População Infectada'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
Group by continent
Order by 3 desc


-- Números Globais

-- Percentual de novos casos/mortes

select date, sum(new_cases) as TotaldeNovosCasos, sum(new_deaths) as TotaldeMortes, sum(new_deaths)  / sum(new_cases)  as PorcentagemDeMorte
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
group by date
Order by 1,2


-- Percentual de mortes globais
select sum(new_cases) as TotaldeNovosCasos, sum(new_deaths) as TotaldeMortes, (sum(new_deaths)  / sum(new_cases))*100  as PorcentagemDeMorte
from [Projeto 1 ].dbo.Mortes_Covid




-- Total de vacinação na população de cada país

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Comparação entre total de vacinados e a população do país

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population)*100 as TaxaVacinação
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- Possível observar que a taxa ficou acima de 100%, isso se deu por conta das doses da vacinação

-- O código acima podia ter sido rodado usando o método CTE
With PercentualVacina(Continent,location, date, population, new_vaccinations, TotalVacinados) -- aqui eu coloco as colunas que vão estar entre parênteses
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados
from [Projeto 1 ].dbo.Mortes_Covid dea 
Join [Projeto 1 ].dbo.VacinaçãoCovid vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (TotalVacinados/population)*100 as TaxaVacinação -- usando o cte, consigo fazer operações com a coluna criada anteriormente e criar a taxa
from PercentualVacina

-- Países com maior taxa de vacinação

Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population)*100 as TaxaVacinação
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 6 desc


-- Relação entre taxa de vacinação e novas mortes com o passar do tempo
Select dea.date, dea.location, dea.new_deaths
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population)*100 as TaxaVacinação
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
where vac.new_vaccinations is not null
order by 3 desc


-- Relação entre densidade populacional e mortes
Select dea.location, dea.total_deaths, vac.population_density
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
Group by dea.location, dea.total_deaths, vac.population_density
order by 3 desc

-- Relação entre taxa de população idosa e mortes
Select dea.location, dea.total_deaths, vac.aged_70_older
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2 desc
