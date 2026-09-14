# Central Superstore – SQL Data Warehouse & Business Analytics

## 📌 Project Overview

This project transforms the Central Superstore transactional dataset into a structured analytical Data Warehouse using SQL Server.

The project follows a **Star Schema** design and applies advanced SQL techniques to generate business insights related to sales, profitability, customers, products, and sales trends.

---

## 🎯 Project Objectives

- Transform raw transactional data into a structured Data Warehouse.
- Build a Star Schema using Fact and Dimension tables.
- Establish Primary Key and Foreign Key relationships.
- Perform advanced SQL analysis using JOINs, CTEs, Subqueries, CASE statements, and Window Functions.
- Create reusable SQL Views and Stored Procedures for KPI reporting.
- Analyze sales, profitability, customer behavior, product performance, and sales trends.
- Improve query performance using indexes.

---

## 🏗️ Data Warehouse Architecture

The project uses a **Star Schema** consisting of:

### ⭐ Fact Table

- `FactSales`

### 📊 Dimension Tables

- `DimCustomer`
- `DimProduct`
- `DimLocation`
- `DimShipping`
- `DimDate`

The `FactSales` table acts as the central fact table and connects to the five dimension tables through Foreign Keys.

---

## 📊 Key KPIs

| KPI | Value |
|---|---:|
| Total Sales | 501,239.88 |
| Total Profit | 39,706.45 |
| Total Quantity | 8,780 |
| Profit Margin | 7.92% |

---

## 🔍 Business Analysis

The project includes analysis of:

- Sales by Category
- Profit by Category
- Sales by Region
- Top Customers
- Top Products
- Loss-Making Products
- Monthly Sales Trends
- Discount Impact on Sales and Profit
- Customer Sales Ranking
- Products with Sales Above Average

### 💡 Key Insights

- **Technology** generated the highest profit among the categories.
- **Furniture** generated strong sales but recorded an overall loss.
- **Tamara Chand** was the highest-selling customer with total sales of **18,437.14**.
- **Canon imageCLASS 2200 Advanced Copier** was the highest-selling product with total sales of **17,499.95**.
- Monthly sales trends were analyzed across the period from **2013 to 2016**.
- The analysis shows that high sales do not always mean high profitability.

---

## 🧠 SQL Techniques Used

- SELECT
- WHERE
- GROUP BY
- HAVING
- ORDER BY
- JOIN
- CASE Statements
- Common Table Expressions (CTEs)
- Subqueries
- Window Functions
- Aggregate Functions
- SQL Views
- Stored Procedures
- Indexing

---

## ⚙️ Database Objects

### 👁️ SQL View

`vw_SalesKPI`

Used to calculate the overall:

- Total Sales
- Total Profit
- Total Quantity
- Profit Margin

### 🔄 Stored Procedure

`sp_GetKPIByYear`

Used to calculate sales KPIs by year, with an optional year parameter.

---

## 🚀 Performance Optimization

Indexes were created on frequently used Foreign Key columns in the `FactSales` table to improve JOIN and query performance.

Indexed columns include:

- `DateKey`
- `CustomerKey`
- `ProductKey`
- `LocationKey`
- `ShippingKey`

---

## 🗂️ Project Structure

```text
Central-Superstore-SQL-Data-Warehouse/
│
├── README.md
│
├── sql/
│   └── Central_Superstore_Project.sql
│
├── ERD/
│   └── Central_Superstore_ERD.png
│
└── report/
    └── Central_Superstore_SQL_Report.docx
