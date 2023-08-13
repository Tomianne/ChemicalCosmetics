--Checking that dataset imported correctly
Select *
From PortfolioProject1.dbo.ChemicalsInCosmetics

-- Data Cleaning and Transformation

--1 - Date Standardization

Select InitialDateReported, CONVERT(Date, initialdatereported) AS Initialdatereported2
From PortfolioProject1.dbo.ChemicalsInCosmetics

ALTER TABLE ChemicalsInCosmetics
ADD Initialdatereported2 Date

UPDATE ChemicalsInCosmetics
SET Initialdatereported2 = CONVERT(Date, initialdatereported)

ALTER TABLE ChemicalsInCosmetics
ADD DiscontinuedDate2 Date

UPDATE ChemicalsInCosmetics
SET DiscontinuedDate2 = CONVERT(Date, DiscontinuedDate)

ALTER TABLE ChemicalsInCosmetics
ADD ChemicalCreatedAt2 Date

UPDATE ChemicalsInCosmetics
SET ChemicalCreatedAt2 = CONVERT(Date, ChemicalCreatedAt)

ALTER TABLE ChemicalsInCosmetics
ADD ChemicalUpdatedAt2 Date

UPDATE ChemicalsInCosmetics
SET ChemicalUpdatedAt2 = CONVERT(Date, ChemicalUpdatedAt)

--2 Populating Null Values in InitialDateReported
Select *
From PortfolioProject1.dbo.ChemicalsInCosmetics
Where InitialDateReported is null
--66,485 rows have InitialDateReported as Null

Select *
From PortfolioProject1.dbo.ChemicalsInCosmetics
Where InitialDateReported2 = ChemicalCreatedAt2
AND InitialDateReported2 is not null
Order by InitialDateReported2

UPDATE ChemicalsInCosmetics
SET InitialDateReported2 = ChemicalCreatedAt2
WHERE InitialDateReported2 is null

--ANALYSIS

--1 Most Used Chemicals in Cosmetics and Personal Care Products

Select PrimaryCategory
From PortfolioProject1.dbo.ChemicalsInCosmetics
Group by PrimaryCategory

SELECT ChemicalName, COUNT ('ChemicalName') AS Total
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE PrimaryCategory = 'Personal Care Products'
GROUP BY ChemicalName
ORDER BY Total DESC;

--2 The Company that Used the Most Reported Chemical (Titanium Dioxide) in their Personal Care Product

SELECT CompanyName, COUNT ('ChemicalName') AS Total
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE ChemicalName = 'Titanium dioxide' AND PrimaryCategory = 'Personal Care Products'
GROUP BY CompanyName
ORDER BY Total DESC

-- 3 Brands that had chemicals that were removed and discontinued
SELECT BrandName, ChemicalName
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE DiscontinuedDate is not Null AND ChemicalDateRemoved is not Null
GROUP BY ChemicalName, BrandName
Order by BrandName

--4 Brands that had chemicals mostly reported in 2018.

SELECT BrandName, COUNT('ChemicalName') AS Total
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE DATEPART(YEAR, InitialDateReported2) = 2018
GROUP BY BrandName
ORDER BY Total DESC

-- 5 The period between the creation of the removed chemicals and when they were actually removed

SELECT CompanyName, ProductName, BrandName, PrimaryCategory, ChemicalName, ChemicalCreatedAt2, ChemicalDateRemoved,
		(DATEDIFF(WEEK, ChemicalCreatedAt2, ChemicalDateRemoved)) AS Duration
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE ChemicalCreatedAt2 is not null AND ChemicalDateRemoved is not Null
GROUP BY CompanyName, ProductName, BrandName, PrimaryCategory, ChemicalName, ChemicalCreatedAt2, ChemicalDateRemoved,
			(DATEDIFF(WEEK, ChemicalCreatedAt2, ChemicalDateRemoved))

--6 Were the discontinued chemicals in bath products removed?
SELECT CompanyName, BrandName, ProductName, ChemicalName, DiscontinuedDate2, ChemicalDateRemoved
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE PrimaryCategory = 'Bath Products'AND DiscontinuedDate2 IS NOT NULL

SELECT COUNT (*)
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE PrimaryCategory = 'Bath Products'AND DiscontinuedDate2 IS NOT NULL
--349 bath products were discontinued. 
SELECT COUNT (*)
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE PrimaryCategory = 'Bath Products'AND DiscontinuedDate2 IS NOT NULL AND ChemicalDateRemoved is not null
--Only 42 of the discontinued products had the chemicals removed


--7 How long the removed chemicals in baby products were used
--SELECT CompanyName, BrandName, ProductName, ChemicalName, ChemicalCreatedAt2, ChemicalDateRemoved, ChemicalCreatedAt
--FROM PortfolioProject1.dbo.ChemicalsInCosmetics
--WHERE PrimaryCategory = 'Baby Products'

--8. The Relationship between Chemicals that were mostly reported and Chemicals mostly discontinued
SELECT COUNT (*)
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE MostRecentDateReported is not null
--112,870 records

SELECT COUNT (*)
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
WHERE DiscontinuedDate2 is not null
--Only 8,630 chemicals were discontinued.

SELECT ChemicalName, COUNT (MostRecentDateReported) AS ReportedCount, COUNT (DiscontinuedDate2) AS DiscontinuedCount
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
GROUP BY ChemicalName
ORDER BY ReportedCount DESC
--No, Most recent reported does not equate most discontinued. Only Titanium dioxide maintained the same position as the 
--most reported and the most discontinued.

--9 The relationship between CSF and chemicals used in the most manufactured sub categories
SELECT CSF, SubCategory, ChemicalName, COUNT ("CSF") AS CSFCount
FROM PortfolioProject1.dbo.ChemicalsInCosmetics
GROUP BY CSF, SubCategory, ChemicalName
ORDER BY CSFCount Desc
--Visualising top 100 by CSF Count