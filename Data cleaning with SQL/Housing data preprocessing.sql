-- HOUSING DATA PRE-PROCESSING
SELECT * FROM HOUSE; 

-- STANDARDIZE THE SaleDate FORMAT
ALTER TABLE HOUSE
ALTER COLUMN "SaleDate" TYPE DATE; 

-- POPULATE PROPERTY ADDRESS DATA
UPDATE HOUSE AS H1
SET "PropertyAddress" = (
    SELECT H2."PropertyAddress"
    FROM HOUSE AS H2
	JOIN HOUSE AS H1
    ON H1."ParcelID" = H2."ParcelID" AND H1."UniqueID " <> H2."UniqueID "
    ORDER BY H2."UniqueID " DESC
    LIMIT 1
)
WHERE "PropertyAddress" IS NULL;

SELECT * FROM HOUSE
WHERE "PropertyAddress" IS NULL;

-- Breaking PropertyAddress into Individuals Columns (Address, City)
ALTER TABLE HOUSE
	ADD COLUMN PropertSplitAddress VARCHAR(200),
	ADD COLUMN PropertySplitCity VARCHAR(200);
UPDATE HOUSE SET 
	PropertSplitAddress = SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress")-1),
	PropertySplitCity = SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress")+1, LENGTH("PropertyAddress"))
	OwnerSplitAddress = SUBSTRING("OwnerAddress, 1, POSITION");
	
-- Breaking OwnerAddress into Individuals Columns (Address, City, State)
ALTER TABLE HOUSE
	ADD COLUMN OwnerSplitAddress VARCHAR(200),
	ADD COLUMN OwnerSplitCity VARCHAR(200),
	ADD COLUMN OwnerSplitState VARCHAR(200);
UPDATE HOUSE SET
	OwnerSplitAddress = SPLIT_PART("OwnerAddress", ',', 1),
	OwnerSplitCity = SPLIT_PART("OwnerAddress", ',', 2),
	OwnerSplitState = SPLIT_PART("OwnerAddress", ',', 3);

-- Standardization -> Change Y and N to Yes and No in the "SoldAsVacant" field
UPDATE HOUSE SET "SoldAsVacant" = 
	CASE
		WHEN "SoldAsVacant" = 'Y' THEN 'YES'
		WHEN "SoldAsVacant" = 'N' THEN 'NO'
		ELSE "SoldAsVacant"
	END; 

SELECT DISTINCT("SoldAsVacant"), count("SoldAsVacant") AS "SUM_SoldAsVacant" FROM HOUSE GROUP BY "SoldAsVacant"; 


-- Identifying and Removing Duplicate Rows

CREATE TEMP TABLE RowNum AS
	SELECT *, ROW_NUMBER() OVER (PARTITION BY 
	"ParcelID", "PropertyAddress", "SalePrice", "SaleDate", "LegalReference"
	ORDER BY "UniqueID ") AS row_num
	FROM HOUSE

SELECT * FROM RowNum WHERE row_num > 1; 

DELETE FROM RowNum WHERE row_num > 1; 





