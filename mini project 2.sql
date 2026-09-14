USE  [mini];
GO
SELECT COUNT(*) AS Total_Rows
FROM [dbo].[Central_Superstore (1)];

SELECT TOP 5 *
FROM [dbo].[Central_Superstore (1)];

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Central_Superstore (1)'
ORDER BY ORDINAL_POSITION;  


-----------------------------------------------DimCustomer
CREATE TABLE DimCustomer
(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID NVARCHAR(50),
    Customer_Name NVARCHAR(150),
    Segment NVARCHAR(50)
);

INSERT INTO DimCustomer
(
    Customer_ID,
    Customer_Name,
    Segment
)
SELECT DISTINCT
    Customer_ID,
    Customer_Name,
    Segment
FROM [dbo].[Central_Superstore (1)];

SELECT *
FROM DimCustomer; 
---------------------------------------------------DimProduct
CREATE TABLE DimProduct
(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    Product_ID NVARCHAR(50),
    Product_Name NVARCHAR(200),
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(50)
); 

INSERT INTO DimProduct
(
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
)
SELECT DISTINCT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
FROM [dbo].[Central_Superstore (1)]; 

SELECT *
FROM DimProduct;
------------------------------------------DimLocation
CREATE TABLE DimLocation
(
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    Country NVARCHAR(50),
    City NVARCHAR(50),
    State NVARCHAR(50),
    Postal_Code INT,
    Region NVARCHAR(50)
); 

INSERT INTO DimLocation
(
    Country,
    City,
    State,
    Postal_Code,
    Region
)
SELECT DISTINCT
    Country,
    City,
    State,
    Postal_Code,
    Region
FROM [dbo].[Central_Superstore (1)]; 

SELECT *
FROM DimLocation; 
----------------------------------DimShipping

CREATE TABLE DimShipping
(
    ShippingKey INT IDENTITY(1,1) PRIMARY KEY,
    Ship_Mode NVARCHAR(50)
); 

INSERT INTO DimShipping
(
    Ship_Mode
)
SELECT DISTINCT
    Ship_Mode
FROM [dbo].[Central_Superstore (1)];

SELECT *
FROM DimShipping; 

----------------------------DimDate
CREATE TABLE DimDate
(
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName NVARCHAR(20)
); 

INSERT INTO DimDate
(
    DateKey,
    FullDate,
    Year,
    Quarter,
    Month,
    MonthName
)
SELECT DISTINCT
    CONVERT(INT, FORMAT(Order_Date, 'yyyyMMdd')) AS DateKey,
    Order_Date AS FullDate,
    YEAR(Order_Date) AS Year,
    DATEPART(QUARTER, Order_Date) AS Quarter,
    MONTH(Order_Date) AS Month,
    DATENAME(MONTH, Order_Date) AS MonthName
FROM [dbo].[Central_Superstore (1)]
WHERE Order_Date IS NOT NULL; 

SELECT *
FROM DimDate
ORDER BY FullDate; 

----------------------------------------------------
--FactSales


CREATE TABLE FactSales
(
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,

    Row_ID INT,
    Order_ID NVARCHAR(50),

    DateKey INT,
    CustomerKey INT,
    ProductKey INT,
    LocationKey INT,
    ShippingKey INT,

    Sales DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(18,2)
); 

INSERT INTO FactSales
(
    Row_ID,
    Order_ID,
    DateKey,
    CustomerKey,
    ProductKey,
    LocationKey,
    ShippingKey,
    Sales,
    Quantity,
    Discount,
    Profit
)
SELECT
    s.Row_ID,
    s.Order_ID,

    d.DateKey,
    c.CustomerKey,
    p.ProductKey,
    l.LocationKey,
    sh.ShippingKey,

    s.Sales,
    s.Quantity,
    s.Discount,
    s.Profit

FROM [dbo].[Central_Superstore (1)] s

JOIN DimDate d
    ON s.Order_Date = d.FullDate

JOIN DimCustomer c
    ON s.Customer_ID = c.Customer_ID
    AND s.Customer_Name = c.Customer_Name
    AND s.Segment = c.Segment

JOIN DimProduct p
    ON s.Product_ID = p.Product_ID
    AND s.Product_Name = p.Product_Name
    AND s.Category = p.Category
    AND s.Sub_Category = p.Sub_Category

JOIN DimLocation l
    ON s.Country = l.Country
    AND s.City = l.City
    AND s.State = l.State
    AND s.Postal_Code = l.Postal_Code
    AND s.Region = l.Region

JOIN DimShipping sh
    ON s.Ship_Mode = sh.Ship_Mode;


SELECT COUNT(*) AS Total_Fact_Rows
FROM FactSales; 

---

ALTER TABLE FactSales
ADD CONSTRAINT FK_FactSales_Date
FOREIGN KEY (DateKey)
REFERENCES DimDate(DateKey);

ALTER TABLE FactSales
ADD CONSTRAINT FK_FactSales_Customer
FOREIGN KEY (CustomerKey)
REFERENCES DimCustomer(CustomerKey);

ALTER TABLE FactSales
ADD CONSTRAINT FK_FactSales_Product
FOREIGN KEY (ProductKey)
REFERENCES DimProduct(ProductKey);

ALTER TABLE FactSales
ADD CONSTRAINT FK_FactSales_Location
FOREIGN KEY (LocationKey)
REFERENCES DimLocation(LocationKey);

ALTER TABLE FactSales
ADD CONSTRAINT FK_FactSales_Shipping
FOREIGN KEY (ShippingKey)
REFERENCES DimShipping(ShippingKey); 


----------------------------------------------------------------------------------------
--Query 1 — Total Sales
SELECT 
    SUM(Sales) AS Total_Sales
FROM FactSales;

--Query 2 — Total Profit
SELECT 
    SUM(Profit) AS Total_Profit
FROM FactSales;
--Query 3 — Total Quantity
SELECT 
    SUM(Quantity) AS Total_Quantity
FROM FactSales; 
---Query 4 — Profit Margin
SELECT 
    SUM(Profit) AS Total_Profit,
    SUM(Sales) AS Total_Sales,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percentage
FROM FactSales; 
--Query 5 — Sales by Category 
SELECT
    p.Category,
    SUM(f.Sales) AS Total_Sales
FROM FactSales f
JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY Total_Sales DESC;

---Query 6 — Profit by Category

SELECT
    p.Category,
    SUM(f.Profit) AS Total_Profit
FROM FactSales f
JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY Total_Profit DESC; 

---Query 7 — Sales by Region
SELECT
    l.Region,
    SUM(f.Sales) AS Total_Sales
FROM FactSales f
JOIN DimLocation l
    ON f.LocationKey = l.LocationKey
GROUP BY l.Region
ORDER BY Total_Sales DESC; 
-------Query 8 — Top 10 Customers
SELECT TOP 10
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,
    SUM(f.Sales) AS Total_Sales
FROM FactSales f
JOIN DimCustomer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Segment
ORDER BY Total_Sales DESC;

---Query 9 — Top 10 Products by Sales
SELECT TOP 10
    p.Product_ID,
    p.Product_Name,
    p.Category,
    SUM(f.Sales) AS Total_Sales
FROM FactSales f
JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category
ORDER BY Total_Sales DESC;

----Query 10 — Loss-Making Products 
SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,
    SUM(f.Sales) AS Total_Sales,
    SUM(f.Profit) AS Total_Profit
FROM FactSales f
JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category
HAVING SUM(f.Profit) < 0
ORDER BY Total_Profit ASC;

---Query 11 — CASE Statemen
SELECT
    f.SalesKey,
    f.Sales,
    f.Profit,
    CASE
        WHEN f.Profit > 0 THEN 'Profitable'
        WHEN f.Profit < 0 THEN 'Loss'
        ELSE 'Break Even'
    END AS Profit_Status
FROM FactSales f;

----Query 12 — CTE
WITH MonthlySales AS
(
    SELECT
        d.Year,
        d.Month,
        d.MonthName,
        SUM(f.Sales) AS Total_Sales
    FROM FactSales f
    JOIN DimDate d
        ON f.DateKey = d.DateKey
    GROUP BY
        d.Year,
        d.Month,
        d.MonthName
)
SELECT *
FROM MonthlySales
ORDER BY Year, Month; 

-----Query 13

WITH CustomerSales AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        SUM(f.Sales) AS Total_Sales
    FROM FactSales f
    JOIN DimCustomer c
        ON f.CustomerKey = c.CustomerKey
    GROUP BY
        c.Customer_ID,
        c.Customer_Name
)
SELECT
    Customer_ID,
    Customer_Name,
    Total_Sales,
    RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank
FROM CustomerSales
ORDER BY Sales_Rank;

----------Query 14 — Subquery
---- Products with sales higher than the average product sales
SELECT
    p.Product_ID,
    p.Product_Name,
    SUM(f.Sales) AS Total_Sales
FROM FactSales f
JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY
    p.Product_ID,
    p.Product_Name
HAVING SUM(f.Sales) >
(
    SELECT AVG(ProductSales)
    FROM
    (
        SELECT
            SUM(Sales) AS ProductSales
        FROM FactSales
        GROUP BY ProductKey
    ) x
)
ORDER BY Total_Sales DESC;
-----
--Query 15 — Discount Impact Analysis
-- Analyze sales and profit based on discount level

SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.20 THEN 'Low Discount'
        WHEN Discount <= 0.50 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS Discount_Level,

    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit

FROM FactSales

GROUP BY
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.20 THEN 'Low Discount'
        WHEN Discount <= 0.50 THEN 'Medium Discount'
        ELSE 'High Discount'
    END

ORDER BY Total_Sales DESC; 

------ـ 15 Queries
-- Create a view for overall sales KPIs

CREATE VIEW vw_SalesKPI
AS
SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percentage
FROM FactSales; 

SELECT *
FROM vw_SalesKPI;

------Query 16 — Stored Procedure
-- Create a stored procedure to calculate sales KPIs by year
CREATE PROCEDURE sp_GetKPIByYear
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.Year,
        SUM(f.Sales) AS Total_Sales,
        SUM(f.Profit) AS Total_Profit,
        SUM(f.Quantity) AS Total_Quantity,
        ROUND(
            (SUM(f.Profit) / NULLIF(SUM(f.Sales), 0)) * 100,
            2
        ) AS Profit_Margin_Percentage
    FROM FactSales f
    JOIN DimDate d
        ON f.DateKey = d.DateKey
    WHERE @Year IS NULL
       OR d.Year = @Year
    GROUP BY d.Year
    ORDER BY d.Year;
END;
EXEC sp_GetKPIByYear;
EXEC sp_GetKPIByYear @Year = 2016;

----Query 17 — Create Indexes
-- Create indexes to improve JOIN and query performance

CREATE INDEX IX_FactSales_DateKey
ON FactSales(DateKey);

CREATE INDEX IX_FactSales_CustomerKey
ON FactSales(CustomerKey);

CREATE INDEX IX_FactSales_ProductKey
ON FactSales(ProductKey);

CREATE INDEX IX_FactSales_LocationKey
ON FactSales(LocationKey);

CREATE INDEX IX_FactSales_ShippingKey
ON FactSales(ShippingKey);