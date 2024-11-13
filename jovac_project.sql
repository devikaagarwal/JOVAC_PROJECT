--Visualizing data
select * from raw_viewership rv 

--1. Checking for Duplicate Values
SELECT 
    "User Id", 
    "Viewership Date", 
    "Total Viewership on NBA App (In Minutes)",
    COUNT(*) AS duplicate_count
FROM 
    raw_viewership rv 
GROUP BY 
    "User Id", 
    "Viewership Date", 
    "Total Viewership on NBA App (In Minutes)"
HAVING 
    COUNT(*) > 1;
   
--2. Creating a Common Table Expression (CTE) for Selecting Duplicate Values
WITH DuplicateRecords AS (
    SELECT 
        "User Id", 
        "Viewership Date", 
        "Total Viewership on NBA App (In Minutes)",
        COUNT(*) AS duplicate_count
    FROM 
        raw_viewership
    GROUP BY 
        "User Id", 
        "Viewership Date", 
        "Total Viewership on NBA App (In Minutes)"
    HAVING 
        COUNT(*) > 1
)
SELECT * FROM DuplicateRecords;



--3. Creating a CTE for Detecting Outliers
WITH Stats AS (
    SELECT 
        AVG("Total Viewership on NBA App (In Minutes)") AS mean_value,
        STDDEV("Total Viewership on NBA App (In Minutes)") AS stddev_value
    FROM 
        raw_viewership rv 
),
Outliers AS (
    SELECT 
        "User Id", 
        "Viewership Date", 
        "Total Viewership on NBA App (In Minutes)"
    FROM 
        raw_viewership rv , Stats
    WHERE 
        ABS("Total Viewership on NBA App (In Minutes)" - mean_value) > 1.5 * stddev_value
)
SELECT * FROM Outliers;


--4. Selecting Rows with Outliers
SELECT 
    "User Id", 
    "Viewership Date", 
    "Total Viewership on NBA App (In Minutes)"
FROM 
    raw_viewership
WHERE 
    ABS("Total Viewership on NBA App (In Minutes)" - (SELECT AVG("Total Viewership on NBA App (In Minutes)") FROM raw_viewership)) > 
    1.5 * (SELECT STDDEV("Total Viewership on NBA App (In Minutes)") FROM raw_viewership);


--5. Deleting Outliers
DELETE FROM raw_viewership 
WHERE 
    ABS("Total Viewership on NBA App (In Minutes)" - (SELECT AVG("Total Viewership on NBA App (In Minutes)") FROM raw_viewership)) > 
    1.5 * (SELECT STDDEV("Total Viewership on NBA App (In Minutes)") FROM raw_viewership);

   
--6. Mean Imputation
WITH Stats AS (
    SELECT 
        AVG("Total Viewership on NBA App (In Minutes)") AS mean_value
    FROM 
        raw_viewership rv 
)
UPDATE raw_viewership 
SET "Total Viewership on NBA App (In Minutes)" = (SELECT mean_value FROM Stats)
WHERE 
    ABS("Total Viewership on NBA App (In Minutes)" - (SELECT AVG("Total Viewership on NBA App (In Minutes)") FROM raw_viewership )) > 
    1.5 * (SELECT STDDEV("Total Viewership on NBA App (In Minutes)") FROM raw_viewership );
   
  
 --7. Checking if Rows are Updated
WITH Stats AS (
    SELECT AVG("Total Viewership on NBA App (In Minutes)") AS mean_value
    FROM raw_viewership rv 
)
SELECT * 
FROM raw_viewership rv , Stats
WHERE 
    ABS("Total Viewership on NBA App (In Minutes)" - mean_value) < 1;

   
--8. Altering the Table Column   
ALTER TABLE raw_viewership 
ALTER COLUMN "Viewership Date" TYPE DATE USING to_date("Viewership Date", 'DD-MM-YYYY');

   
