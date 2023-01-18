Select *
From PortfolioProject.dbo.Housing


--Date standardization

ALTER TABLE PortfolioProject.dbo.Housing
Add SaleDateConverted Date

Update PortfolioProject.dbo.Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate property address

Select *
From PortfolioProject.dbo.Housing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Housing a
JOIN PortfolioProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Housing a
JOIN PortfolioProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Split address into different columns

Select PropertyAddress
From PortfolioProject.dbo.Housing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.Housing


drop table if exists  PropertySplitAddress
ALTER TABLE PortfolioProject.dbo.Housing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject.dbo.Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject.dbo.Housing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject.dbo.Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.Housing

--Owner address separation

select owneraddress
from PortfolioProject.dbo.Housing



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProject.dbo.Housing

ALTER TABLE PortfolioProject.dbo.Housing
Add OwnerSplitAddress Nvarchar(255)


Update PortfolioProject.dbo.Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.Housing
Add OwnerSplitCity Nvarchar(255)

Update PortfolioProject.dbo.Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE PortfolioProject.dbo.Housing
Add OwnerSplitState Nvarchar(255)

Update PortfolioProject.dbo.Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

--alter table PortfolioProject.dbo.Housing
--DROP COLUMN OwnerSplitStatey

select *
from PortfolioProject.dbo.Housing


--to make 'Y' & 'N' to 'Yes' & 'No' in soldasvacant column

select Distinct(soldasvacant),count(SoldAsVacant)
from PortfolioProject.dbo.Housing
group by SoldAsVacant
order by 2


select SoldAsVacant,
 CASE when soldasvacant= 'Y' then 'Yes'
       when soldasvacant= 'N' then 'No'
	   else soldasvacant
	   end
from PortfolioProject.dbo.Housing


Update PortfolioProject.dbo.Housing
Set SoldAsVacant = CASE when soldasvacant= 'Y' then 'Yes'
       when soldasvacant= 'N' then 'No'
	   else soldasvacant
	   end
from PortfolioProject.dbo.Housing


--To remove duplicates

select *
from PortfolioProject.dbo.Housing



With RownumCTE As(
select *, ROW_NUMBER() over (Partition by parcelid,
                                          PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference
										  order by
										    UniqueID
											) row_num

from PortfolioProject.dbo.Housing
--order by ParcelID
)
Delete                              --select *
from RownumCTE
where row_num > 1
                                    -- order by UniqueID



--Delete Unsed columns

Alter Table PortfolioProject.dbo.Housing
Drop column OwnerAddress, propertyaddress, LandUse, Taxdistrict, SaleDate


