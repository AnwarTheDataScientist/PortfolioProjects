
-- Data Cleaning nashvilleHousing
/*
Cleaning Data in SQL Queries
*/


SELECT * FROM Data_cleaning_project2.`nashville _housing_data`;
ALTER TABLE Data_cleaning_project2.`nashville _housing_data`
RENAME TO nashvilleHousing;

---------------------------------------------------------------------------------


-- Standardize Date Format


SELECT SaleDate FROM nashvilleHousing;

SELECT DATE_FORMAT(SaleDate,'%y-%m-%d') FROM nashvilleHousing;

ALTER TABLE nashvilleHousing
CHANGE COLUMN SaleDate SaleDate DATE;


-- If it doesn't Update properly --


SELECT *,STR_TO_DATE(SaleDate,'%m/%d/%y') 
FROM nashvilleHousing;

UPDATE nashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate,'%m/%d/%y') ;


--------------------------------------------------------------------------------


-- Data isn't inserted properly into database --

-- Replacing Blank cells with  NULLS in PropertyAddress Column ----


UPDATE nashvilleHousing
SET PropertyAddress = NULLIF(TRIM(both '()' FROM PropertyAddress),'');

SELECT * FROM nashvilleHousing
WHERE PropertyAddress IS NULL;


----------------------------------------------------------------------------------------------------------------


-- Papulate Address Property Data----------


SELECT *
FROM nashvilleHousing
-- Where PropertyAddress is null
ORDER BY ParcelID;


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,NULLIF(b.PropertyAddress,a.PropertyAddress)
FROM nashvilleHousing a
INNER JOIN nashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashvilleHousing a
INNER JOIN nashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = NULLIF(b.PropertyAddress,a.PropertyAddress) 
WHERE a.PropertyAddress IS NULL;


-----------------------------------------------------------------------------------------------------------------------



-- Breaking Down Address into Individual Columns (Address ,city, State)--------------



SELECT PropertyAddress FROM nashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,Instr(PropertyAddress,',')-1) AS Address,
SUBSTRING(PropertyAddress,Instr(PropertyAddress,',')+1, LENGTH(PropertyAddress)) AS Address
FROM nashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)) AS Address,
LOCATE(',',PropertyAddress)
FROM nashvilleHousing;

ALTER TABLE nashvilleHousing
ADD COLUMN PropertySplitAddress VARCHAR(255);

UPDATE nashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,Instr(PropertyAddress,',')-1) ;


ALTER TABLE nashvilleHousing
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE nashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,Instr(PropertyAddress,',')+1, LENGTH(PropertyAddress));

SELECT 
SUBSTRING_index(OwnerAddress,',',1) ,
SUBSTRING_INDEX(substring_index(OwnerAddress,',',2),',',-1) ,
SUBSTRING_index(OwnerAddress,',',-1)
FROM nashvilleHousing;

ALTER TABLE nashvilleHousing
ADD COLUMN OwnerSplitAddress VARCHAR(255);

UPDATE nashvilleHousing
SET OwnerSplitAddress = SUBSTRING_index(OwnerAddress,',',1) ;

ALTER TABLE nashvilleHousing
ADD COLUMN OwnerSplitCity VARCHAR(255);

UPDATE nashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(substring_index(OwnerAddress,',',2),',',-1);

ALTER TABLE nashvilleHousing
ADD COLUMN OwnerSlpitState VARCHAR(255);

UPDATE nashvilleHousing
SET OwnerSlpitState = SUBSTRING_index(OwnerAddress,',',-1) ;


SELECT * FROM nashvilleHousing;



----------------------------------------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No in "Sold as Vacant" field------------------



SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM nashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM nashvilleHousing;

UPDATE nashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END ;

SELECT * FROM nashvilleHousing;



------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates--

/*
SELECT * FROM nashvilleHousing

WITH ROW_NUM_CTE AS( 
SELECT *,
ROW_NUMBER() over(
PARTITION BY   ParcelID,
               PropertyAddress,
               SaleDate,
               SalePrice,
               LegalReference
               ORDER BY UniqueID
               )
               AS RowNumber
FROM nashvilleHousing
)

SELECT *
FROM ROW_NUM_CTE
WHERE RowNumber > 1

-- It didn't work 
*/


-----------------------



-- DELETING DUPLICATES BY USING WINDOW ROW_NUMBER---------------------



DELETE FROM nashvilleHousing
WHERE UniqueID IN (
SELECT UniqueID 
FROM (
SELECT UniqueID,
ROW_NUMBER() over(
PARTITION BY   ParcelID,
               PropertyAddress,
               SaleDate,
               SalePrice,
               LegalReference
               ORDER BY UniqueID
               )
               AS RowNumber
FROM nashvilleHousing
) t
WHERE RowNumber > 1
);



-----------------------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns



SELECT * FROM nashvilleHousing;

ALTER TABLE nashvilleHousing
DROP COLUMN PropertyAddress,
DROP COLUMN	OwnerAddress,
DROP COLUMN TaxDistrict;

















