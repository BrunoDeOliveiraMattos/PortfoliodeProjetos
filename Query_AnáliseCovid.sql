-- Analyzing COVID-19 data in Brazil

-- A chance de você vir a falecer caso você pegue Covid no seu país
select location, date, total_deaths, total_cases, ((total_deaths/total_cases) *100) as 'TaxaMortalidade'
from [Projeto 1 ].dbo.Mortes_Covid
where location like '%Brazil%'
Order by 1,2

-- Comparação com dados globais
select location, date, total_deaths, total_cases, ((total_deaths/total_cases) *100) as 'TaxaMortalidade'
from [Projeto 1 ].dbo.Mortes_Covid
where location like '%World%' 
Order by 1,2


-- Comparação cronológica 
Select dea.date, dea.location, dea.new_deaths, (dea.total_deaths/dea.total_cases) as TaxadeMortalidade
, Max(vac.total_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((Max(vac.total_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population) as TaxaVacinação
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%Brazil%'
order by 1 


-- Comparação com dados globais
Select dea.date, dea.location, dea.new_deaths
, Max(vac.total_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((Max(vac.total_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population)*100 as TaxaVacinação
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%World%'

-- Dados Principais
Select Max(dea.total_cases) as CasosTotais, Max(dea.total_deaths) as MortesTotais, Max(vac.total_vaccinations) as VacinadosTotal, (dea.total_deaths/dea.total_cases) as TaxaMortalidade
from [Projeto 1 ].dbo.Mortes_Covid dea --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
Join [Projeto 1 ].dbo.VacinaçãoCovid vac --abreviação para não precisar reescrever a base toda vez que for usar a fórmula
	on dea.location = vac.location
