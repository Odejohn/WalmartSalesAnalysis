CREATE DATABASE IF NOT EXISTS WalmartSales;
USE WalmartSales;
 
 CREATE TABLE sales (
  invoice_id VARCHAR(30) NOT NULL PRIMARY KEY, 
  branch VARCHAR(5) NOT NULL,
  city VARCHAR(30) NOT NULL, 
  customer VARCHAR(30) NOT NULL,
  gender VARCHAR(10) NOT NULL, 
  product_line VARCHAR(100) NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL, 
  quantity INT NOT NULL,
  VAT FLOAT(6, 4) NOT NULL,
  total DECIMAL(12, 4) NOT NULL, 
  date DATETIME NOT NULL,
  time TIME NOT NULL,
  payment_method VARCHAR(15) NOT NULL,
  cogs DECIMAL (10, 2) NOT NULL,
  gross_margine_pct FLOAT(11, 9),
  gross_income DECIMAL(12, 4) NOT NULL, 
  rating FLOAT(2, 1)
  ); 
 
 
 
 -- Add the time_of_day column
 ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- For this to work turn off safe mode for update
-- Edit > Preferences > SQL Edito > scroll down and toggle safe mode
-- Reconnect to MySQL: Query > Reconnect to server
UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add day_name column
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- Add month_name column
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

--  -----------------------------------------------------------------------------------------------------------------------------

-- How many unique cities does data have?
SELECT DISTINCT city FROM sales;

-- In which cities each branch
SELECT DISTINCT city,branch FROM sales;

-- How many unique product lines does the data have?
SELECT DISTINCT product_linem FROM sales;

-- What is the most common payment method
SELECT payment_method, COUNT(payment_method) as count
FROM sales
GROUP BY payment_method
ORDER BY count DESC;

-- What is the most selling product line
SELECT product_line, SUM(quantity) as no_sold FROM sales
GROUP BY product_line 
ORDER BY no_sold DESC;

-- What is the total revenue by month
SELECT month_name AS month, SUM(total) as revenue FROM sales
GROUP BY month_name 
ORDER BY revenue DESC;

-- What month had the largest COGS?
SELECT month_name AS month, SUM(cogs) as total_COGS FROM sales
GROUP BY month_name 
ORDER BY total_COGS DESC
LIMIT 1;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) as revenue FROM sales
GROUP BY product_line
ORDER BY  revenue DESC;

-- What city had the largest revenue?
SELECT city, SUM(total) as revenue FROM sales
GROUP BY city
ORDER BY  revenue DESC;

-- What product line had the largest VAT?
SELECT product_line, AVG(VAT) as total_VAT FROM sales
GROUP BY product_line
ORDER BY  total_VAT DESC;

/* 
Fetch each product line and add a column to those product 
line showing "Good", "Bad". Good if its greater than average sales
*/
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > (SELECT AVG(quantity) FROM sales) THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch had average product sold more than total average product sold?
SELECT branch, AVG(quantity) as qty
FROM sales
GROUP BY  branch
HAVING qty > (SELECT AVG(quantity) FROM sales);


-- What is the most common product line by gender
SELECT product_line, COUNT(gender) AS No_per_gender
FROM sales
GROUP BY gender, product_line
ORDER BY No_per_gender DESC;


-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- -------------------------------------------------------------------
-- --------------------------SALES------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Which of the customer types bring most revenue?
SELECT customer, SUM(total) AS revenue
FROM sales
GROUP BY customer
ORDER BY revenue DESC;


-- Which city  has the largest tax percent/VAT (Value Added Tax)?
SELECT city, AVG(VAT) AS VAT
FROM sales
GROUP BY  city
ORDER BY  VAT DESC;

-- Which customer type pays the most in VAT?
SELECT customer, AVG(VAT) AS VAT
FROM sales 
GROUP BY customer
ORDER BY VAT DESC;


-- -------------------------------------------------------------------
-- --------------------------CUSTOMER---------------------------------

-- How many unique customer types does the data have?
SELECT DISTINCT(customer)
FROM sales; 
-- or
SELECT COUNT(DISTINCT(customer)) 
FROM sales; 

-- How many unique payment methods does the data have?
SELECT DISTINCT(payment_method)
FROM sales;
-- or 
SELECT COUNT(DISTINCT(payment_method))
FROM sales; 

-- What is the most common customer type?
SELECT customer, COUNT(customer) AS total_customer
FROM sales
GROUP BY customer
ORDER BY total_customer DESC;

-- Which customer type buys the more?
SELECT customer, AVG(quantity) AS avg_bought
FROM sales
GROUP BY customer
ORDER BY avg_bought DESC;

-- what is the gender of most of the customers?
SELECT gender, COUNT(gender) AS no_of_customer
FROM sales
GROUP BY gender
ORDER BY no_of_customer DESC;

-- What is the gender distribution per branch?
SELECT gender, COUNT(gender) AS no_of_customer
FROM sales
WHERE branch = "A" -- type what branch you want to know
GROUP BY gender
ORDER BY no_of_customer DESC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day 
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A" -- type what branch you want to know
GROUP BY time_of_day 
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg rating?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales 
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales 
WHERE branch = "A"   -- type what branch you want to know
GROUP BY day_name
ORDER BY avg_rating DESC;
