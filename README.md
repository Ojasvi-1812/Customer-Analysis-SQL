# Customer-Analysis-SQL

## 📊 Overview

This project leverages SQL for advanced analytics on a sales dataset, simulating a data warehouse environment. It explores sales trends, customer behavior, product performance, segmentation, and other business intelligence metrics to support strategic decision-making.

## 🏗️ Project Structure

The project follows a modular SQL script that includes:

### 1. **Data Modeling**
- **Tables Created:**
  - `gold_customers`: Stores customer details including demographics.
  - `gold_products`: Contains product catalog information.
  - `sales`: Tracks transactional sales data.

### 2. **Sales Trends Analysis**
- **Yearly and Monthly Trends**: Sales, quantity sold, and unique customers analyzed over time.
- **Best Months by Revenue**: Identifies peak revenue periods.
- **Strategic Views**: Combines year and month for detailed revenue trends.
- **Cumulative & Moving Averages**: Running totals and average sales used for forecasting.

### 3. **Performance Analysis**
- **Product Performance**: Compares product sales against their historical averages and prior year.
- **Category Contribution**: Identifies which product categories drive most revenue.

### 4. **Segmentation**
- **Product Segmentation**: Groups products based on price brackets.
- **Customer Segmentation**: Classifies customers as VIP, Regular, or New based on spend and order history.

### 5. **Customer Analytics Dashboard**
- A materialized customer report built using a SQL view (`report_customer`) to showcase:
  - Demographics (age groups)
  - Customer segmentation
  - Recency
  - Average order value
  - Monthly spend
  - Total sales, products purchased, and order count

## 💡 Key Insights Enabled
- Identification of best performing months and products
- Customer lifetime value estimation
- Behavioral segmentation for targeting
- Strategic planning based on historical trends

## 🧰 Tools Used
- PostgreSQL / SQL
- Data Warehousing Concepts
- Window Functions & Aggregations
- CTEs (Common Table Expressions)
- Date Functions

## 📁 File
- `sql-analytics-project (sales advanced analytics).sql`: Full SQL code including DDL, DML, and analytical queries.

## 🚀 How to Use
1. Set up your PostgreSQL environment.
2. Run the DDL statements to create tables.
3. Populate tables with data (if available).
4. Execute analysis queries step-by-step or modularly.
5. Use `report_customer` view to extract KPIs for business dashboards.

## 🙋‍♀️ Author
**Ojasvi** – Aspiring Data Analyst passionate about transforming raw data into actionable insights.

---

⭐️ If you found this project insightful, feel free to star this repo!
