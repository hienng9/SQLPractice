
SELECT * 
FROM NashvilleHousing
--  Standardize Date Format
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date 

-- Populate Property Address Data
SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
                      FROM NashvilleHousing A
                      JOIN NashvilleHousing B
                      ON A.ParcelID = B.ParcelID
                      AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


-- Breaking out Address into individual columns (Address, city, state)
ALTER TABLE NashvilleHousing
ADD PropertyAddressStreet VARCHAR(255)

ALTER TABLE NashvilleHousing
ADD PropertyAddressCity VARCHAR(255)

UPDATE NashvilleHousing
SET PropertyAddressStreet = PARSENAME(REPLACE(PropertyAddress,',','.'),2),
    PropertyAddressCity = PARSENAME(REPLACE(PropertyAddress,',','.'),1)
                            FROM NashvilleHousing


SELECT  PropertyAddressStreet, PropertyAddressCity
FROM NashvilleHousing
-- Owner address
ALTER TABLE NashvilleHousing
ADD OwnerAddressStreet VARCHAR(255), OwnerAddressCity VARCHAR(255), OwnerAddressState VARCHAR(255)


UPDATE NashvilleHousing
SET  OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
     OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
     OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
    

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    WHEN SoldAsVacant = ' Yes' THEN 'Yes'
                    ELSE SoldAsVacant
                    END

SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing

-- Remove Duplicates
SELECT *
FROM NashvilleHousing

WITH row_num_table AS (
SELECT *, ROW_NUMBER() OVER (PARTITION By ParcelID, 
                                          PropertyAddress, 
                                          SaleDate,
                                          SalePrice,
                                          LegalReference
                              ORDER BY UniqueID) AS RowNum
FROM NashvilleHousing)

SELECT *
FROM row_num_table
WHERE RowNum>1
-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
SELECT *
FROM NashvilleHousing