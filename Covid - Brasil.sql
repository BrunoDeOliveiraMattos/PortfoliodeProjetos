-- Fazendo an�lises pro Brasil

-- A chance de voc� vir a falecer caso voc� pegue Covid no seu pa�s
select location, date, total_deaths, total_cases, ((total_deaths/total_cases) *100) as 'TaxaMortalidade'
from [Projeto 1 ].dbo.Mortes_Covid
where location like '%Brazil%' -- Aqui basta inserir o nome do pa�s
Order by 1,2



-- A porcentagem de mortes pela quantidade de habitantes
select location, date, population, ((total_deaths/population)*100) as 'Mortes/Habitantes'
from [Projeto 1 ].dbo.Mortes_Covid
where location like '%Brazil%' -- Aqui basta inserir o nome do pa�s
Order by 1,2



-- A porcentagem de contamina��o pelo total de habitantes
select location, date, population, ((total_cases/population)*100) as 'Porcentagem da Popula��o Infectada'
from [Projeto 1 ].dbo.Mortes_Covid
where location like '%Brazil%' -- Aqui basta inserir o nome do pa�s
Order by 1,2



-- Compara��o cronol�gica 
Select dea.date, dea.location, dea.new_deaths
, Max(vac.total_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalVacinados, 
((Max(vac.total_vaccinations) over (partition by dea.location order by dea.location, dea.date))/dea.population) as TaxaVacina��o
from [Projeto 1 ].dbo.Mortes_Covid dea --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
Join [Projeto 1 ].dbo.Vacina��oCovid vac --abrevia��o para n�o precisar reescrever a base toda vez que for usar a f�rmula
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%Brazil%'
order by 1 


