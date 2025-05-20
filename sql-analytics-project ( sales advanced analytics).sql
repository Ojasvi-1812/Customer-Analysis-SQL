-- Data Warehouse Analytics

-- Create TABLE

CREATE TABLE gold_customers
	( 
	customer_key INT,
	customer_id INT,
	customer_number VARCHAR(25),
	first_name VARCHAR(25),
	last_name VARCHAR(25),
	country VARCHAR(25),
	marital_status VARCHAR(25),
	gender VARCHAR(25),
	birth_sate DATE,
	create_date DATE
	);

SELECT * FROM gold_customers;

CREATE TABLE gold_products
	( 
	product_key INT,
	product_id INT,
	product_number VARCHAR(50),
	product_name VARCHAR(50),
	category_id VARCHAR(50),
	category VARCHAR(50),
	sub_category VARCHAR(50),
	maintainance VARCHAR(50),
	cost INT,
	product_line VARCHAR(50),
	start_date DATE
	);

SELECT * 
FROM gold_products;

CREATE TABLE sales
	( 
	order_no VARCHAR(10),
	product_key INT,
	customer_key INT,
	order_date DATE,
	shipping_date DATE,
	due_date DATE,
	sales_amount INT,
	quantity INT,
	price INT
	);

SELECT * FROM sales;


-- ANALYZING SALES TRENDS

-- Yearly Trend
SELECT 
	order_year,
	total_sale,
	customers,
	total_quantity
FROM
	(SELECT
		EXTRACT (YEAR FROM order_date) AS order_year,
		SUM(sales_amount) AS total_sale,
		Count ( DISTINCT customer_key) as customers,
		SUM( quantity) AS total_quantity
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY 1
	) AS yearly_record
ORDER BY order_year;


-- Monthly Trend  
SELECT 
	order_month,
	total_sale,
	customers,
	total_quantity
FROM
	(SELECT
		EXTRACT (MONTH FROM order_date) AS order_month,
		SUM(sales_amount) AS total_sale,
		Count ( DISTINCT customer_key) as customers,
		SUM( quantity) AS total_quantity
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY 1,2
	) AS monthly_record
ORDER BY order_month;

-- Best Performative Months in terms of Revenue
SELECT 
	order_month,
	total_sale,
	customers,
	total_quantity
FROM
	(SELECT
		EXTRACT (MONTH FROM order_date) AS order_month,
		SUM(sales_amount) AS total_sale,
		Count ( DISTINCT customer_key) as customers,
		SUM( quantity) AS total_quantity
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY 1
	) AS monthly_record
ORDER BY total_sale DESC;



-- Strategic Implications Required
SELECT 
	order_year,
	order_month,
	total_sale,
	customers,
	total_quantity
FROM
	(SELECT
		EXTRACT (YEAR FROM order_date) AS order_year,
		EXTRACT (MONTH FROM order_date) AS order_month,
		SUM(sales_amount) AS total_sale,
		Count ( DISTINCT customer_key) as customers,
		SUM( quantity) AS total_quantity
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY 1,2
	) AS monthly_record
ORDER BY total_sale DESC;


-- OR USE DATETRUNC (comes with timestamp)
SELECT 
	orderdate,
	total_sale,
	customers,
	total_quantity
FROM
	(SELECT
		DATE_TRUNC('month', order_date) AS orderdate,
		SUM(sales_amount) AS total_sale,
		COUNT(DISTINCT customer_key) as customers,
		SUM( quantity) AS total_quantity
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY 1
	) AS monthly_record
ORDER BY total_sale DESC;


-- OR TO AVOID TIMESTAMP ( NO dates - just month and year)
SELECT 
	orderdate,
	total_sale,
	customers,
	total_quantity
FROM
	(SELECT
		TO_CHAR(order_date,'YYYY-MM') AS orderdate,
		SUM(sales_amount) AS total_sale,
		COUNT(DISTINCT customer_key) as customers,
		SUM( quantity) AS total_quantity
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY 1
	) AS monthly_record
ORDER BY total_sale DESC;


-- CUMULATIVE ANALYSIS

--Cumulative Total Sales each month & each year
SELECT
	orderdate,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY order_year ORDER BY orderdate) AS running_total_sales
FROM
(
	SELECT
		TO_CHAR(order_date,'YYYY-MM') AS orderdate,
		EXTRACT (YEAR FROM order_date) AS order_year,
		SUM(sales_amount) AS total_sales
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY orderdate, order_year
	ORDER BY orderdate
);


-- To find Moving Average
SELECT
	orderdate,
	total_sales,
	SUM(total_sales) OVER (ORDER BY orderdate) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY orderdate) AS moving_avg_price
FROM
(
	SELECT
		TO_CHAR(order_date,'YYYY-MM') AS orderdate,
		EXTRACT (YEAR FROM order_date) AS order_year,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM sales
	WHERE order_date IS NOT NULL
	GROUP BY orderdate, order_year
	ORDER BY orderdate
);

--PERFORMANCE ANALYSIS

--Analyzing performance of products by comparinf each product's sales to average sales 
WITH yearly_product_sales
AS (
	SELECT 
		EXTRACT(YEAR FROM s.order_date) AS order_year,
		p.product_name,
		SUM(s.sales_amount) AS nto
	FROM sales s
		LEFT JOIN gold_products p
		ON s.product_key = p.product_key
		WHERE s.order_date IS NOT NULL
	GROUP BY order_year,p.product_name
	ORDER BY order_year
  )
SELECT 
	order_year,
	product_name,
	nto,
	AVG(nto) OVER( PARTITION BY product_name) AS avg_sales,
	nto  - AVG(nto) OVER( PARTITION BY product_name) AS diff_avg,
	CASE WHEN 	nto  - AVG(nto) OVER( PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN 	nto  - AVG(nto) OVER( PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END avg_change,
	LAG(nto) OVER( PARTITION BY product_name ORDER BY order_year) AS py_sales,
	nto - LAG(nto) OVER( PARTITION BY product_name ORDER BY order_year) AS diff_py, 
	CASE WHEN 	nto  - LAG(nto) OVER( PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Inc'
		 WHEN 	nto  - LAG(nto) OVER( PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Dec'
	 ELSE 'No change'
END py_sales
FROM yearly_product_sales
ORDER BY product_name, order_year;


--PART TO WHOLE

-- what categories contribute the most to overall sales?
WITH category_sales
AS(
	SELECT 
		category,
		SUM(sales_amount) AS nto
	FROM sales s 
		LEFT JOIN gold_products p
			ON s.product_key = p.product_key
	GROUP BY category
)
SELECT 
	category,
	nto,
	SUM(nto) OVER() AS overall_sales,
	CONCAT(ROUND((nto )/SUM(nto) OVER()*100,2),'%') AS percent_of_total
FROM category_sales
ORDER BY category;

-- DATA SEGMENTATION

-- Segment products into cost ranges and 
-- count how many products falls into each segmengt
WITH product_segment
AS( 
	SELECT 
		product_key,
		product_name,
		cost,
		CASE WHEN cost <100 THEN 'BELOW 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END cost_range
	FROM gold_products
	)
SELECT 	
	cost_range,
	COUNT( product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;

-- Group customers into segments based on their spending behaviour
-- VIP : 12 months of history & min spent = 5000
-- Regular : 12 months of history & max spent = 5000
-- new : Less than 12 months of history
-- calculate total no. of customers ine ach group

WITH customer_spending
AS(
	SELECT 
		c.customer_key,
		SUM(sales_amount) AS total_spend,
		MIN(S.order_date) AS first_order,
		MAX(S.order_date) AS last_order,
	(EXTRACT(YEAR FROM AGE(MAX(s.order_date), MIN(s.order_date))) * 12 + 
	     EXTRACT(MONTH FROM AGE(MAX(s.order_date), MIN(s.order_date)))) AS lifespan
	FROM sales s
	LEFT JOIN gold_customers c
	ON  s.customer_key = c.customer_key
	WHERE s.order_date IS NOT NULL
	GROUP BY c.customer_key
	)
SELECT
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM 
(
	SELECT 
		 customer_key,
		 total_spend,
		 lifespan,
		 CASE WHEN lifespan >= 12 AND total_spend > 5000 THEN 'VIP'
		 	  WHEN lifespan >= 12 AND total_spend < 5000 THEN 'Regular'
			  ELSE 'New' 
		 END customer_segment
		 FROM customer_spending 	
)
GROUP BY customer_segment
ORDER BY total_customers DESC;

======================================
-- BUILD CUSTOMER REPORT
======================================

-- Key Customer Metrics and behaviour
-- Gather essential fields
-- Segment customers into categories and age groups
-- Aggregates metrics:
	--total orders, total sals, total products, total wuantity sold, liffespan(in months)
-- Calculate KPI's:
	-- recency( months since last order)
	--avg order value
	--avg monthly spend


--Creating Base Data
CREATE VIEW report_customer AS    
WITH base_query
AS( 
	SELECT 
		s.order_no,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		c.birth_sate,
		CONCAT(c.first_name,' ',c.last_name) AS customer_name
	FROM sales s
	LEFT JOIN gold_customers c
	ON s.customer_key= c.customer_key
	WHERE order_date IS NOT NULL
 )
 , customer_aggregation
 AS(
	 SELECT
	 	 customer_key,
		 customer_number,
		 customer_name,
		 EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_sate)) AS age,
		 COUNT(DISTINCT order_no) AS total_orders,
		 COUNT(DISTINCT product_key) AS total_products,
		 SUM (sales_amount) AS total_sales,
		 SUM (quantity) AS total_quantity,
		 MIN(order_date) AS first_order,
		 MAX(order_date) AS last_order,
		(EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 + 
		     EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))) AS lifespan
	FROM base_query
	GROUP BY 
		 customer_key,
		 customer_number,
		 customer_name,
		 age
	)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE WHEN AGE<20 THEN 'under 20'
		 WHEN AGE BETWEEN 20 AND 29 THEN '20-29'
		 WHEN AGE BETWEEN 30 AND 39 THEN '30-39'
		 WHEN AGE BETWEEN 40 AND 49 THEN '40-49'
		 ELSE '50 & Above'
	END AS age_group,
	CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			 ELSE 'New' 
	END AS customer_segment,
	last_order,
	(EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order)) * 12 +
	 EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order))) AS recency,
	total_sales,
	total_quantity,
	total_products,
	-- avg order value
	CASE WHEN  total_sales=0 THEN 0
	ELSE total_sales/total_orders 
	END AS avg_order_value,
	-- avg montghly spend
	CASE WHEN  lifespan=0 THEN total_sales
	ELSE total_sales/lifespan
	END AS avg_monthly_spend
FROM customer_aggregation;





