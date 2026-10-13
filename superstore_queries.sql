-- Superstore Sales Analysis - SQL Queries
-- Database: MySQL | Table: superstore | View: v_sales

-- VIEW: Clean dates and calculated fields
CREATE VIEW v_sales AS
SELECT *,
  STR_TO_DATE(Order_Date, '%d/%m/%Y') AS order_dt,
  STR_TO_DATE(Ship_Date, '%d/%m/%Y') AS ship_dt,
  YEAR(STR_TO_DATE(Order_Date, '%d/%m/%Y')) AS order_year,
  MONTH(STR_TO_DATE(Order_Date, '%d/%m/%Y')) AS order_month,
  DATEDIFF(STR_TO_DATE(Ship_Date, '%d/%m/%Y'), STR_TO_DATE(Order_Date, '%d/%m/%Y')) AS delivery_days
FROM superstore;

-- Q1: Sales by Region with % share
SELECT Region, 
  ROUND(SUM(Sales),0) AS sales, 
  ROUND(100.0*SUM(Sales)/(SELECT SUM(Sales) FROM superstore),1) AS pct
FROM superstore 
GROUP BY Region 
ORDER BY sales DESC;
-- Result: West 31.4%, East 29.6%, Central 21.8%, South 17.2%

-- Q2: Top 5 customers by sales
SELECT Customer_Name, ROUND(SUM(Sales),0) AS sales 
FROM superstore 
GROUP BY Customer_ID, Customer_Name 
ORDER BY sales DESC 
LIMIT 5;
-- Result: Sean Miller $25,043 is top customer

-- Q3: Year-over-year growth using LAG()
WITH y AS (
  SELECT order_year AS yr, SUM(Sales) AS s 
  FROM v_sales GROUP BY order_year
)
SELECT yr, ROUND(s,0) AS sales, 
  ROUND(100.0*(s-LAG(s) OVER (ORDER BY yr))/LAG(s) OVER (ORDER BY yr),1) AS yoy_pct 
FROM y;
-- Result: 2016: -4.3%, 2017: +30.6%, 2018: +20.3%

-- Q4: Bottom 3 sub-categories
SELECT Sub_Category, ROUND(SUM(Sales),0) AS sales 
FROM superstore GROUP BY Sub_Category ORDER BY sales ASC LIMIT 3;
-- Result: Fasteners $3,002, Labels $12,348, Envelopes $16,128

-- Q5: Average delivery days by ship mode
SELECT Ship_Mode, ROUND(AVG(delivery_days),2) AS avg_days 
FROM v_sales GROUP BY Ship_Mode ORDER BY avg_days;
-- Result: Same Day 0.04, First Class 2.18, Second Class 3.25, Standard 5.01

-- Q6: Late deliveries (>5 days) by ship mode
SELECT Ship_Mode, COUNT(*) AS late_lines, 
  ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM superstore s2 WHERE s2.Ship_Mode=v.Ship_Mode),1) AS pct_of_mode 
FROM v_sales v WHERE delivery_days > 5 GROUP BY Ship_Mode;
-- Result: Standard Class 1785 lines (30.5%)

-- Q7: Revenue concentration by customer quintile
WITH c AS (SELECT Customer_ID, SUM(Sales) AS s FROM superstore GROUP BY Customer_ID), 
r AS (SELECT s, NTILE(5) OVER (ORDER BY s DESC) AS quintile FROM c)
SELECT quintile, ROUND(100.0*SUM(s)/(SELECT SUM(s) FROM c),1) AS pct_of_sales 
FROM r GROUP BY quintile ORDER BY quintile;
-- Result: Top 20% customers = 48.5% of sales

-- Q8: Strongest months
SELECT order_month, ROUND(SUM(Sales),0) AS sales 
FROM v_sales GROUP BY order_month ORDER BY sales DESC LIMIT 3;
-- Result: November, December, September

-- Q9: Top category per region using RANK()
SELECT Region, Category, ROUND(s,0) AS sales
FROM (SELECT Region, Category, SUM(Sales) AS s,
  RANK() OVER (PARTITION BY Region ORDER BY SUM(Sales) DESC) AS rk 
  FROM superstore GROUP BY Region, Category) ranked
WHERE rk = 1;
-- Result: Technology leads in all 4 regions

-- Q10: Volume vs value growth
SELECT order_year, COUNT(DISTINCT Order_ID) AS orders, 
  ROUND(SUM(Sales)/COUNT(DISTINCT Order_ID),1) AS avg_order_value 
FROM v_sales GROUP BY order_year;
-- Result: Orders +75% but avg order value fell $506 -> $434 (volume-driven growth)