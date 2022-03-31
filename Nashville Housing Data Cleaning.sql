/*
nashville,tn data cleaning
skills used: datatype format conversion, populating null column values, 
substring operations, parse name operations, removing duplicate rows, 
deleting useless columns
*/

select * 
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------

--standardize sale date format
--convert from date/time format to date format

select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

---------------------------------------------------------------------------------------------------------

--populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b. PropertyAddress, isnull(a.PropertyAddress,b. PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b. PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------

-- breaking out property address into individual columns (address, city, state) using substrings

select 
substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------

--breaking out owner address into individual columns (address, city, state) using parse name

select
parsename(replace(OwnerAddress, ',','.'),3),
parsename(replace(OwnerAddress, ',','.'),2),
parsename(replace(OwnerAddress, ',','.'),1)
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'),3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.'),2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'),1)

---------------------------------------------------------------------------------------------------------

--explore the different variations of "SoldAsVacant" field
--change Y and N to Yes and No in "SoldAsVacant" field

select
distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2 desc

select SoldAsVacant,
case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------

--remove all duplicate rows using a CTE
with RowNumCTE as (
select *,
row_number() over(
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by 
UniqueID
) row_num

from PortfolioProject.dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress

---------------------------------------------------------------------------------------------------------

--delete unused columns

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict,PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate
