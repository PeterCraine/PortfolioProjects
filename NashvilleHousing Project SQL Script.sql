--Cleaning Data in SQL Queries To Make it More Usuable

Select*
From NashvilleHousing

--Standardize (Change Sale Dates) Date Format

Select SaleDate, Convert(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Select SaleDate
From NashvilleHousing

--Did not update

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDate, SaleDateConverted
From NashvilleHousing

--Populate Property Address Data

Select PropertyAddress
From NashvilleHousing
Where Propertyaddress is Null

Select *
From NashvilleHousing
Where Propertyaddress is Null

Select *
From NashvilleHousing
Order by ParcelID
--Parcel ID will be same as Property address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From NashvilleHousing As a
Join NashvilleHousing As b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing As a
Join NashvilleHousing As b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing As a
Join NashvilleHousing As b
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) As Address
,Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) As Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashvilleHousing

--Parse is simplier than substring

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3)
,PARSENAME(Replace(OwnerAddress,',','.'), 2)
,PARSENAME(Replace(OwnerAddress,',','.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

Select *
From NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant)
From NashvilleHousing

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

--Remove Duplicates

With RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER ( 
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 Order by UniqueID
				 ) row_num
From NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1

With RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER ( 
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 Order by UniqueID
				 ) row_num
From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1

--Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate
