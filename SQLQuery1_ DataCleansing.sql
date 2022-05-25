--Projeto de limpeza de dados

-- Nesse projeto o foco foi em criar colunas mais facilmente analis�veis, padronizar informa��es dentro das colunas,
--remover duplicatas e informa��es que n�o seriam �teis para a an�lise


select DataCompra
from dbo.Housing



-- Padronizando o formato de data
Select SaleDate, convert(date, SaleDate)
from [Projeto 2].dbo.Housing

update dbo.Housing
set DataCompra = convert(date, SaleDate)



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Preenchendo valores em branco nos endere�os
Select *  
from [Projeto 2].dbo.Housing
--where PropertyAddress is null
order by ParcelID

-- Com o c�digo acima, � p�ss�vel perceber que existem linhas com o mesmo parcel ID mas Unique ID diferentes e isso pode estar ocasionando os valores nulos de endere�o

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [Projeto 2].dbo.Housing a
join [Projeto 2].dbo.housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-- Para corrigir isso, basta utilizar a f�rmula isnull e fazer o update

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Projeto 2].dbo.Housing a
join [Projeto 2].dbo.housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


update a -- n�o podemos usar o nome da tabela, temos que usar c�digo atribu�do anteriormente
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) -- aqui estamos trocando a coluna antiga que continha os valores em branco pela nova
from [Projeto 2].dbo.Housing a
join [Projeto 2].dbo.housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null






-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Quebrando a coluna endere�o em rua, cidade e estado

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address

from dbo.Housing

Alter Table dbo.housing
add Logradouro Nvarchar(255)

select*
from dbo.Housing

Update dbo.Housing
set Logradouro = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) -- dessa forma pegamos tudo at� a v�rgula

Alter Table dbo.housing
add Cidade Nvarchar(255)

Update dbo.Housing
set Cidade= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))  -- dessa forma pegamos tudo ap�s a v�rgula







-----------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Fazendo o mesmo para Owner Address, mas nesse caso existem duas v�rgulas na coluna, por isso precisamos usar o ParseName

ParseName(Replace(OwnerAddress,',','.'),1) -- O parse name � usado para separar atrav�s do '.' e n�o pela ',' por isso precisamos usar o replace neste caso


select
ParseName(Replace(OwnerAddress,',','.'),3),
ParseName(Replace(OwnerAddress,',','.'),2),  -- importante reparar que o parsename come�a a separar pelo final da c�lula, por isso est� descendente
ParseName(Replace(OwnerAddress,',','.'),1)
from [Projeto 2].dbo.Housing

Alter Table dbo.housing
add LogradouroDono Nvarchar(255)

Update dbo.Housing
set LogradouroDono = ParseName(Replace(OwnerAddress,',','.'),3)

Alter Table dbo.housing
add CidadeDono Nvarchar(255)

Update dbo.Housing
set CidadeDono = ParseName(Replace(OwnerAddress,',','.'),2)

Alter Table dbo.housing
add EstadoDono Nvarchar(255)

Update dbo.Housing
set EstadoDono = ParseName(Replace(OwnerAddress,',','.'),1)

select *
from dbo.Housing


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Padronizar o booleano do Sold as Vacant
Select Distinct(dbo.Housing.SoldAsVacant), Count(dbo.Housing.SoldAsVacant)
From dbo.Housing
group by SoldAsVacant
order by 2

--Usando a f�rmula Case

select dbo.Housing.SoldAsVacant
, case when dbo.Housing.SoldAsVacant = 'Y' Then 'Yes'
	   when dbo.Housing.SoldAsVacant = 'N' THEN 'No'
	   Else dbo.Housing.SoldAsVacant
	   END
from dbo.Housing

update dbo.Housing
set SoldAsVacant = case when dbo.Housing.SoldAsVacant = 'Y' Then 'Yes'
	   when dbo.Housing.SoldAsVacant = 'N' THEN 'No'
	   Else dbo.Housing.SoldAsVacant
	   END




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remover duplicatas

WITH row_num_CTE as(
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate
				 Order By
					UniqueID
				    ) row_num -- verifica se tem duplicatas
from [Projeto 2].dbo.Housing
)
select *
from row_num_CTE
where row_num >1


-- Agora que temos as duplicatas, basta excluir

WITH row_num_CTE as(
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate
				 Order By
					UniqueID
				    ) row_num -- verifica se tem duplicatas
from [Projeto 2].dbo.Housing
)
Delete 
from row_num_CTE
where row_num >1



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 


 --Removendo colunas que n�o ser�o usadas

 Alter Table dbo.housing
 drop column OwnerAddress, PropertyAddress,SaleDate,TaxDistrict

 
 Alter Table dbo.housing
 drop column LegalReference


  select * 
 from dbo.Housing