/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NasvilleHousing

----------------------------------------------------------------------------------------------------------

--Standardise data format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NasvilleHousing


Update NasvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NasvilleHousing
add SaleDateConverted Date

Update NasvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)


----------------------------------------------------------------------------------------------------------

--Populate Property address data

Select PropertyAddress
From PortfolioProject.dbo.NasvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NasvilleHousing a
JOIN PortfolioProject.dbo.NasvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NasvilleHousing a
JOIN PortfolioProject.dbo.NasvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------

--Breaking Out address into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NasvilleHousing
--Where PropertyAddress is null
--Order by ParcelID


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NasvilleHousing


ALTER TABLE NasvilleHousing
add PropertySplitAddress nvarchar(255)

Update NasvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NasvilleHousing
add PropertySplitCity nvarchar(255)

Update NasvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NasvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NasvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NasvilleHousing

ALTER TABLE NasvilleHousing
add OwnerSplitAddress nvarchar(255)

Update NasvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NasvilleHousing
add OwnerSplitCity nvarchar(255)

Update NasvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NasvilleHousing
add OwnerSplitState nvarchar(255)

Update NasvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject.dbo.NasvilleHousing



-----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NasvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
  END
From PortfolioProject.dbo.NasvilleHousing

Update NasvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
  END




----------------------------------------------------------------------------------------------------------

--Remove Duplicates  

With RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				  UniqueID
					)row_num
From PortfolioProject.dbo.NasvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
ORDER BY PropertyAddress




----------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select *
From PortfolioProject.dbo.NasvilleHousing


ALTER TABLE PortfolioProject.dbo.NasvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NasvilleHousing
DROP COLUMN SaleDate