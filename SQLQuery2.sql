--Cleaning Data in SQL Queries
select * from NashvileHousing

--Standardize Date Formart
select SaleDate
from NashvileHousing

update NashvileHousing
set SaleDate = CONVERT(Date,SaleDate) 

alter table NashvileHousing
add SaleDateConverted Date

update NashvileHousing
set SaleDateConverted = CONVERT(Date,SaleDate) 

--Populate Property Addres data

select *
from NashvileHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvileHousing a
join NashvileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where b.PropertyAddress is null 

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvileHousing a
join NashvileHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out addres inot individual columns(addres,city,state)

select PropertyAddress
from NashvileHousing

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as ad
from NashvileHousing

alter table NashvileHousing
add PropertySplitAddress nvarchar(255)

update NashvileHousing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvileHousing
add PropertySplitCity nvarchar(255)

update NashvileHousing
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvileHousing

alter table NashvileHousing
add OwnerSplitAddress nvarchar(255)

update NashvileHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvileHousing
add OwnerSplitCity nvarchar(255)

update NashvileHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvileHousing
add OwnerSplitState nvarchar(255)

update NashvileHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select * from NashvileHousing

--Change Y and N to Yes and No in Sold as Vacant field

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvileHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant  = 'N' then 'No'
	else SoldAsVacant
	END 
from NashvileHousing

update NashvileHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant  = 'N' then 'No'
	else SoldAsVacant
	END 

--Remove Duplicates
with RowNumCTE as (
select *,
ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID
) row_num
from NashvileHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num>1

--Delete Unused Columns
select *
from NashvileHousing

alter table NashvileHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress


alter table NashvileHousing
drop column SaleDate


