select *
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null

-- A chance de voc� vir a falecer caso voc� pegue Covid no seu pa�s
select location, date, ((total_deaths/total_cases) *100) as 'Porcentagem de Mortes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
--where location like '%Brazil%' -- Aqui basta inserir o nome do pa�s
Order by 1,2



-- A porcentagem de mortes pela quantidade de habitantes
select location, date, population, ((total_deaths/population)*100) as 'Mortes/Habitantes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
--where location like '%Brazil%' -- Aqui basta inserir o nome do pa�s
Order by 1,2



-- A porcentagem de contamina��o pelo total de habitantes
select location, date, population, ((total_cases/population)*100) as 'Porcentagem da Popula��o Infectada'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
--where location like '%Brazil%' -- Aqui basta inserir o nome do pa�s
Order by 1,2


-- Pa�ses com a maior taxa de contamina��o pela quantidade de habitantes
select location, population, Max(total_cases), Max((total_cases/population)*100) as 'Porcentagem da Popula��o Infectada'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
Group by location, population
Order by 4 desc


-- Pa�ses com as maiores taxas de mortalidade
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

-- A chance de voc� vir a falecer caso voc� pegue Covid no seu continente
select continent, date, ((total_deaths/total_cases) *100) as 'Porcentagem de Mortes'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
Order by 2 desc


-- Continentes com a maior taxa de contamina��o pela quantidade de habitantes
select continent, sum(total_cases) as 'Total de casos', Max((total_cases/population)*100) as 'Porcentagem da Popula��o Infectada'
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
Group by continent
Order by 3 desc


-- N�meros Globais

-- Percentual de novos casos/mortes

select date, sum(new_cases) as TotaldeNovosCasos, sum(new_deaths) as TotaldeMortes, sum(new_deaths)  / sum(new_cases)  as PorcentagemDeMorte
from [Projeto 1 ].dbo.Mortes_Covid
where continent is not null
group by date
Order by 1,2


-- Percentual de mortes globais
select sum(new_cases) as TotaldeNovosCasos, sum(new_deaths) as TotaldeMortes, (sum(new_deaths)  / sum(new_cases))*100  as PorcentagemDeMorte
from [Projeto 1 ].dbo.Mortes_Covid




-- Total de vacina��o na popula��o de cada pa�s

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados
from [Projeto 1 ].dbo.Mortes_Covid dea --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
Join [Projeto 1 ].dbo.Vacina��oCovid vac --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Compara��o entre total de vacinados e a popula��o do pa�s

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population)*100 as TaxaVacina��o
from [Projeto 1 ].dbo.Mortes_Covid dea --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
Join [Projeto 1 ].dbo.Vacina��oCovid vac --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- Poss�vel observar que a taxa ficou acima de 100%, isso se deu por conta das doses da vacina��o

-- O c�digo acima podia ter sido rodado usando o m�todo CTE
With PercentualVacina(Continent,location, date, population, new_vaccinations, TotalVacinados) -- aqui eu coloco as colunas que v�o estar entre par�nteses
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados
from [Projeto 1 ].dbo.Mortes_Covid dea 
Join [Projeto 1 ].dbo.Vacina��oCovid vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (TotalVacinados/population)*100 as TaxaVacina��o -- usando o cte, consigo fazer opera��es com a coluna criada anteriormente e criar a taxa
from PercentualVacina

-- Pa�ses com maior taxa de vacina��o

Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population)*100 as TaxaVacina��o
from [Projeto 1 ].dbo.Mortes_Covid dea --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
Join [Projeto 1 ].dbo.Vacina��oCovid vac --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 6 desc


-- Rela��o entre taxa de vacina��o e novas mortes com o passar do tempo
Select dea.date, dea.location, dea.new_deaths
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population)*100 as TaxaVacina��o
from [Projeto 1 ].dbo.Mortes_Covid dea --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
Join [Projeto 1 ].dbo.Vacina��oCovid vac --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
	on dea.location = vac.location
	and dea.date = vac.date
where vac.new_vaccinations is not null
order by 3 desc


-- Rela��o entre densidade populacional e mortes
Select dea.location, dea.total_deaths, vac.population_density
from [Projeto 1 ].dbo.Mortes_Covid dea --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
Join [Projeto 1 ].dbo.Vacina��oCovid vac --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
	on dea.location = vac.location
	and dea.date = vac.date
Group by dea.location, dea.total_deaths, vac.population_density
order by 3 desc

-- Rela��o entre taxa de popula��o idosa e mortes
Select dea.location, dea.total_deaths, vac.aged_70_older
from [Projeto 1 ].dbo.Mortes_Covid dea --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
Join [Projeto 1 ].dbo.Vacina��oCovid vac --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2 desc