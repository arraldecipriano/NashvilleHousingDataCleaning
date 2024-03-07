-- Selecting all the data

SELECT *
FROM NashvilleHousing;

-- Reformating date column

SELECT	SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing;

-- Added new column
ALTER TABLE NashvilleHousing
ADD ConvertedSaleDate date;

UPDATE NashvilleHousing
SET ConvertedSaleDate = CONVERT(date, SaleDate);

SELECT ConvertedSaleDate, SaleDate
FROM NashvilleHousing;

-- Putting data into PropertyAddress column

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;
-- 29 PropertyAddress NULL values

-- Self joining the table to populate PropertyAddress column
SELECT a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;
-- Now this query gives 0 rows

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;
-- Populated the 29 NULL values found before

-- Separating the address in different columns

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS 'Address',
 -- -1 to not include the comma
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS 'City'
 -- +1 to start just after the comma
 FROM NashvilleHousing;

 -- Creating new columns

 ALTER TABLE NashvilleHousing
 ADD Address nvarchar(255);

 UPDATE NashvilleHousing
 SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

  ALTER TABLE NashvilleHousing
 ADD City nvarchar(255);

 UPDATE NashvilleHousing
 SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

 SELECT OwnerAddress
 FROM NashvilleHousing;

 --Breaking out OwnerAddress in 3 different columns

 SELECT
 PARSENAME(REPLACE(OwnerAddress,',', '.' ), 3),
 PARSENAME(REPLACE(OwnerAddress,',', '.' ), 2),
 PARSENAME(REPLACE(OwnerAddress,',', '.' ), 1)
 FROM NashvilleHousing;

 --Inserting them as new columns

 ALTER TABLE NashvilleHousing
 ADD OwnerStreet nvarchar(255);

 UPDATE NashvilleHousing
 SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',', '.' ), 3);

 ALTER TABLE NashvilleHousing
 ADD OwnerCity nvarchar(255);

 UPDATE NashvilleHousing
 SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',', '.' ), 2);

 ALTER TABLE NashvilleHousing
 ADD OwnerState nvarchar(255);

 UPDATE NashvilleHousing
 SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.' ), 1);

 --Changing Yes/No to Y/N from Sold as vacant

 SELECT
DISTINCT(SoldAsVacant),
COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT
SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
 WHEN SoldAsVacant = 'N' THEN 'NO'
 ELSE SoldAsVacant
 END
 FROM NashvilleHousing;

 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
					WHEN SoldAsVacant = 'N' THEN 'NO'
					ELSE SoldAsVacant
END;

-- Removing duplicates

-- Creating cte
WITH RowNumCte AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID) row_num 
FROM NashvilleHousing
)
--Deleting duplicate rows

--DELETE
--FROM RowNumCte
--WHERE row_num > 1;

SELECT *
FROM RowNumCte
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Deleting uselss columns

SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
TaxDistrict,
PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN ConvertedSaleDate;

-------------------------------