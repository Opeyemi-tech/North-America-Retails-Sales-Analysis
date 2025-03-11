USE NORTHAMERICA_RETAILS_SALES
SELECT
	*
FROM
	[Sales Retails];
-- To create the Customer Dimension Table
SELECT
	*
INTO
	DimCustomer
FROM
	(SELECT
		Customer_ID, 
		Customer_Name
	FROM
		[Sales Retails]) AS DimC;

SELECT
	* 
FROM
	DimCustomer;
-- To remove duplicates from the DimCustomer Table
---STEP ONE
WITH CTE_DimC AS
	(SELECT 
		Customer_ID, 
		Customer_Name,
		ROW_NUMBER() OVER (PARTITION BY Customer_ID, Customer_Name ORDER BY Customer_ID ASC) AS RowNum
	FROM
		DimCustomer)
-- STEP TWO
DELETE FROM CTE_DimC
WHERE RowNum > 1;

-- To Create Location Create our Location Dimension Table
SELECT
	*
FROM
	[Sales Retails];
SELECT
	*
INTO
	DimLocation
FROM
	(SELECT
		Postal_Code, 
		Country,
		State,
		City,
		Region
	FROM
		[Sales Retails]) AS DimL;

SELECT
	* 
FROM
	DimLocation;
-- To remove duplicates from the DimLocation Table
---STEP ONE
WITH CTE_DimL AS
	(SELECT 
		Postal_Code, 
		Country,
		State,
		City,
		Region,
		ROW_NUMBER() OVER (PARTITION BY Postal_Code, Country, State, City, Region ORDER BY Postal_Code ASC) AS RowNumb
	FROM
		DimLocation)
-- STEP TWO
DELETE FROM CTE_DimL
WHERE RowNumb > 1;

-- To Create our Product Dimensions Table
SELECT
	*
FROM
	[Sales Retails];
SELECT
	*
INTO
	DimProduct
FROM
	(SELECT
		Product_ID, 
		Category,
		Sub_Category,
		Product_Name
	FROM
		[Sales Retails]) AS DimP;

SELECT
	* 
FROM
	DimProduct;
-- To remove duplicates from the DimLocation Table
---STEP ONE
WITH CTE_DimP AS
	(SELECT 
		Product_ID, 
		Category,
		Sub_Category
		Product_Name,
		ROW_NUMBER() OVER (PARTITION BY Product_ID, Category, Sub_Category, Product_Name ORDER BY Product_ID ASC) AS Row_Num
	FROM
		DimProduct)
-- STEP TWO
DELETE FROM CTE_DimP
WHERE Row_Num > 1;

-- To Create OrdersFacts Table
SELECT
	*
INTO
	Order_Facts
FROM
	(SELECT
		Order_ID,
		Order_Date,
		Ship_Date,
		Ship_Mode,
		Customer_ID,
		Segment,
		Postal_Code,
		Retail_Sales_People,
		Product_ID,
		Returned,
		Sales,
		Quantity,
		Discount,
		Profit
	FROM
		[Sales Retails]) AS ORDFS;
		
-- Removing Duplicates
WITH CTE_Factstable
AS
	(SELECT *,
	ROW_NUMBER()
	OVER(PARTITION BY
		Order_ID,
		Order_Date,
		Ship_Date,
		Ship_Mode,
		Customer_ID,
		Segment,
		Postal_Code,
		Retail_Sales_People,
		Product_ID,
		Returned,
		Sales,
		Quantity,
		Discount,
		Profit
	ORDER BY Order_ID ASC) AS RowFacts
FROM
	Order_Facts)

DELETE FROM
	CTE_Factstable
WHERE
	RowFacts >1;

SELECT
	*
FROM
	Order_Facts;

	/** There was a duplicate in the Product_ID in the DimProduct table, therefore, there's need for the creation of Surrogate Key**/
ALTER TABLE DimProduct
ADD ProductKey INT IDENTITY (1,1);

-- There's need therefore to update the Order_Facts table.
--Step 1: 
ALTER TABLE Order_Facts
ADD ProductKey INT;
--Step 2:
UPDATE Order_Facts
SET ProductKey = DimProduct.ProductKey
FROM Order_Facts
JOIN DimProduct
ON Order_facts.Product_ID = DimProduct.Product_ID

-- Since there's a surrogate key, we do not need the Product_ID column again and should be dropped
ALTER TABLE DimProduct
DROP COLUMN Product_ID;

ALTER TABLE Order_Facts
DROP COLUMN Product_ID;

/** There was a duplicate in the Product_ID in the Order_Facts table, therefore, there's need for the creation of Surrogate Key**/
ALTER TABLE Order_Facts
ADD Row_ID INT IDENTITY (1,1);

-- Exploratory Analysis
-- What is the average delivery days for different product category? To get this, we need to make use of the datediff function
SELECT
	*
FROM
	Order_Facts;
SELECT
	* 
FROM
	DimProduct;
SELECT
	DP.Sub_Category,
	AVG( DATEDIFF(DAY, Ordf.Order_Date, Ordf.Ship_Date)) AS Avg_Delivery_Days
FROM Order_Facts AS Ordf
LEFT JOIN DimProduct AS DP
ON Ordf.ProductKey = DP.ProductKey
GROUP BY Sub_Category; /** Therefore, the average dellivery days for the different Sub categories are:
Chairs = 32, Bookcases = 32, Furnishings = 34, Tables = 36**/

--What was the average delivery days for Segments?

SELECT
	Segment,
	AVG( DATEDIFF(DAY, Order_Date, Ship_Date)) AS Avg_Delivery_Days
FROM
	Order_Facts
GROUP BY Segment
ORDER BY Avg_Delivery_Days DESC;
/** Therefore, the average dellivery days for the different Sgements are:
Corporate = 35, Home Office = 32, Consumer = 34 **/

-- What are the top 5 delivered Products and the bottom 5 delivered products?
SELECT
TOP 5
	DP.Product_Name,
	DATEDIFF(DAY, Ordf.Order_Date, Ordf.Ship_Date) AS Avg_Delivery_Days
FROM Order_Facts AS Ordf
LEFT JOIN DimProduct AS DP
ON Ordf.ProductKey = DP.ProductKey
ORDER BY Avg_Delivery_Days;
----- The bottom 5 delivered products
SELECT
TOP 5
	DP.Product_Name,
	DATEDIFF(DAY, Ordf.Order_Date, Ordf.Ship_Date) AS Avg_Delivery_Days
FROM Order_Facts AS Ordf
LEFT JOIN DimProduct AS DP
ON Ordf.ProductKey = DP.ProductKey
ORDER BY Avg_Delivery_Days DESC;

-- Which product sub category generates the most profit?
SELECT
	DP.Sub_Category,
	ROUND(SUM(Profit), 2) AS Most_SC_Profit
FROM
	Order_Facts AS ORF
LEFT JOIN
	DimProduct AS DP
ON ORF.ProductKey = DP.ProductKey
WHERE Profit > 0
GROUP BY DP.Sub_Category
ORDER BY Most_SC_Profit DESC;

-- Which product sub category generates the most profit?
SELECT
	Segment,
	ROUND(SUM(Profit), 2) AS Most_SGM_Profit
FROM
	Order_Facts
WHERE Profit > 0
GROUP BY Segment
ORDER BY Most_SGM_Profit DESC; -- the Consumer segment generated the most profit

--Which top 5 Customers generates the most profit?

SELECT * FROM DimCustomer
SELECT * FROM Order_Facts
SELECT
TOP 5 
	(DC.Customer_Name),
	ROUND(SUM(ORF.Profit), 2) AS TP
FROM
	DimCustomer AS DC
LEFT JOIN Order_Facts AS ORF
ON DC.Customer_ID = ORF.Customer_ID
WHERE Profit > 0
GROUP BY DC.Customer_Name
ORDER BY TP DESC; -- The top 5 customers are Laura Armstrong, Joe Elijah, Seth Vernon, Quincy Jones, Maria Etezadi

-- Total number of products by Sub Category
SELECT
	Sub_Category,
	COUNT(DISTINCT Product_Name) AS TotalProducts
FROM
	DimProduct
GROUP BY Sub_Category
ORDER BY TotalProducts DESC; /* The total number of products by sub_category are as follows:
Furnishings, Chairs, Bookcases, Tables */
