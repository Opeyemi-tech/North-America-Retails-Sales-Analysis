# North America Retails Sales Optimization Analysis
## Project Overview
North America Retail is a large company with multiple locations, offering a wide range of products to different customers. They focus on great customer service and making shopping easy and enjoyable.
As a data analyst, my job is to analyze the company's data to uncover insights on profitability, business performance, products, and customer behavior. The dataset includes details on products, customers, sales, profits, and returns.
By the end of the analysis, I'll identify areas for improvement and suggest strategies to make the business more efficient and profitable.


## Data Source:
The dataset used is a flat file named Retail-supply-chain-analysis (Retail-supply-chain-analysis.csv) provided by North America Retail gotten from @mydataclique (A data community)

## Tool Used
- SQL

## Data Cleaning and Preparation Process
- Imported the dataset
- Thorough inspection of the dataset
- Split the dataset into Facts and Dimensions tables
- Created an ERD

## Goal of the Analysis
1. What was the average delivery days for different product subcategories?
2. What was the average delivery days for each Segment?
3. What are the top 5 fastest delivered products and the top 5 slowest delivered products?
4. Which product category generates the most profit?
5. Which segment generates the most profit?
6. Which top 5 customers contribute the most profit?
7. What is the total number of products by sub categories?

## Data Analysis
#### 1. What were the average delivery days for different product subcategories?
```sql
-- What is the average delivery days for different product categories? To get this, we need to make use of the datediff function
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
GROUP BY Sub_Category; /** Therefore, the average delivery days for the different Sub categories are:
Chairs = 32, Bookcases = 32, Furnishings = 34, Tables = 36**/
```
###
#### 2. What was the average delivery days for each Segment?
```sql
SELECT
	Segment,
	AVG( DATEDIFF(DAY, Order_Date, Ship_Date)) AS Avg_Delivery_Days
FROM
	Order_Facts
GROUP BY Segment
ORDER BY Avg_Delivery_Days DESC;
/** Therefore, the average delivery days for the different Sgements are:
Corporate = 35, Home Office = 32, Consumer = 34 **/
```
#### 3. What are the top 5 fastest delivered products and the top 5 slowest delivered products?
```sql
SELECT
TOP 5
	DP.Product_Name,
	DATEDIFF(DAY, Ordf.Order_Date, Ordf.Ship_Date) AS Avg_Delivery_Days
FROM Order_Facts AS Ordf
LEFT JOIN DimProduct AS DP
ON Ordf.ProductKey = DP.ProductKey
ORDER BY Avg_Delivery_Days;
```
##### The bottom 5 delivered products
```sql
SELECT
TOP 5
	DP.Product_Name,
	DATEDIFF(DAY, Ordf.Order_Date, Ordf.Ship_Date) AS Avg_Delivery_Days
FROM Order_Facts AS Ordf
LEFT JOIN DimProduct AS DP
ON Ordf.ProductKey = DP.ProductKey
ORDER BY Avg_Delivery_Days DESC;
```

#### 4. Which product category generates the most profit?
```sql
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
```
#### 5. Which product sub category generates the most profit?
```sql
SELECT
	Segment,
	ROUND(SUM(Profit), 2) AS Most_SGM_Profit
FROM
	Order_Facts
WHERE Profit > 0
GROUP BY Segment
ORDER BY Most_SGM_Profit DESC; -- the Consumer segment generated the most profit
```
#### 6. Which top 5 Customers generate the most profit?
```sql
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
```
#### 7. Total number of products by Sub Category
```sql
SELECT
	Sub_Category,
	COUNT(DISTINCT Product_Name) AS TotalProducts
FROM
	DimProduct
GROUP BY Sub_Category
ORDER BY TotalProducts DESC; /* The total number of products by sub_category are as follows:
Furnishings, Chairs, Bookcases, Tables */
```
## Findings/Results
##### Average Delivery Days by Product Sub-Category
The longer delivery times for Tables and Furnishings may indicate supply chain inefficiencies or higher demand. Optimizing logistics or inventory management in these categories could improve delivery speed and customer satisfaction.
##### Average Delivery Days by Customer Segment
Corporate orders are experiencing longer delivery times due to bulk purchases and or special handling requirements. Optimizing logistics for corporate clients could improve efficiency, while maintaining fast delivery for Home Office customers helps retain their satisfaction.
##### Fastest and Slowest Delivered Products
- Top 5 Fastest-Delivered Products: These items have significantly shorter delivery times, ensuring quick customer fulfillment.
- Bottom 5 Slowest-Delivered Products: These take the longest to ship, potentially causing delays and dissatisfaction.
###### Analyzing why certain products experience delays—whether due to supply chain issues, warehouse inefficiencies, or high demand—can help improve delivery speed. Addressing these bottlenecks will lead to better customer satisfaction and operational efficiency.

##### Most Profitable Product Sub-Category
Invest more in Chairs, Furnishings, Bookcases, Tables, because these high-profit sub-categories could boost overall profitability.
##### Most Profitable Customer Segment
The Consumer segment is the most profitable, indicating a strong customer base. This makes it a key focus for marketing efforts and retention strategies to drive continued growth.
##### Most Profitable Customer Segment
The most profitable customers include Laura Armstrong, Joe Elijah, Seth Vernon, Quincy Jones, and Maria Etezadi. They are valuable to the business, and offering them personalized deals or loyalty programs could encourage repeat purchases.
##### Total Number of Products by Sub-Category
The highest number of products are in Furnishings, Chairs, Bookcases, and Tables. A diverse product range in these categories indicates strong demand, but it may also suggest the need for inventory optimization.

## Key Recommendations
- Delivery Time Optimization: Focus on reducing delays in the slowest sub-categories and corporate segment.
- Profit Maximization: Invest more in high-profit sub-categories and strengthen relationships with top customers.
- Customer Focus: Since the Consumer segment drives the most profit, targeted marketing efforts here could yield significant growth.
