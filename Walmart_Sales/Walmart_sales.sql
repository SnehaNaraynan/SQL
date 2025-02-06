
SELECT * FROM walmart;

-- EDA

SELECT COUNT (*) FROM walmart;

-- 1) WHAT ARE PAYMENT METHODS ARE THE CUSTOMERS USING?

SELECT DISTINCT payment_method FROM walmart;

-- 2) WHAT IS THE TRANSCATION COUNT IN EACH OF THE PAYMENT TYPES?
SELECT payment_method,
COUNT (*)
FROM walmart
GROUP BY payment_method
ORDER BY COUNT DESC;

-- 3) Total number of Branches
SELECT COUNT(DISTINCT branch)
FROM walmart;

SELECT MAX(quantity) FROM walmart;

SELECT MIN(quantity) FROM walmart;

-- BUSINESS ANALYSIS

-- 1) NUMBER OF QUANTITY SOLD FOR EACH PAYMENT METHOD

SELECT payment_method,
COUNT (*) as no_of_payments,
SUM(quantity) as quantity_sold
FROM walmart
GROUP BY payment_method;

-- 2) What is the highest-rated category in each branch, displaying the branch, category
-- and avg rating
SELECT *
FROM
( SELECT 
	branch,
	category,
	AVG(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart 
GROUP BY 1,2
)
WHERE rank = 1;

-- 3) Identify the busiest day for each branch based on the number of transactions
-- To do this 'date' needs to be copnverted from text to date type

SELECT date,
TO_DATE(date,'DD/MM/YY') as formated_date
FROM walmart;

-- create a day column from the day
SELECT date,
TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') as Day
FROM walmart;

SELECT * FROM 
	(SELECT branch,
	TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') as Day,
	COUNT (*) as no_of_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1,2
	)
WHERE rank=1;

-- COUNT(*) counts the total number of rows (transactions) that belong to each combination of branch and Day.

-- 4) Determine the average, minimum, and maximum rating of products for each city.
--List the city, average_rating, min_rating, and max_rating

SELECT city,
category,
AVG(rating) as avg_rating, 
MIN(rating) as min_rating,
MAX(rating) as max_rating
FROM walmart
GROUP BY 1,2;

-- 5) Calculate the total profit for each category by considering total_profit as
--(unit_price * quantity * profit_margin). 
--List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) as revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1
ORDER BY 3 DESC;

-- 6) Determine the most common payment method for each Branch. 
--Display Branch and the preferred_payment_method.
SELECT * FROM 
(
SELECT branch,
payment_method,
COUNT (*) AS total_transcations,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE rank = 1;

-- 7) Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices

SELECT branch,
CASE 
WHEN EXTRACT (HOUR FROM(time::time)) <12 THEN 'Morning'
WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 and 17 THEN 'Afternoon'
ELSE 'Evening'
END shift,
COUNT (*)
from walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- 8) Identify 5 branch with highest decrease ratio in
-- revevenue compare to last year (current year 2023 and last year 2022)

--rev dec ratio rdr = Last_yr_rev-current_yr_rev/Last_yr_rev * 100
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) as formated_date
FROM walmart;

-- 2022
WITH revenue_2022
AS
(SELECT branch,
SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY'))= 2022
group by 1),
revenue_2023
AS
(
SELECT branch,
SUM(total) as revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY'))= 2023
group by 1
)
SELECT 
last_year.branch,
last_year.revenue as ly_rev,
curr_year.revenue as cr_rev,
ROUND((last_year.revenue - curr_year.revenue)::numeric/
last_year.revenue::numeric *100, 2) as RDR
FROM revenue_2022 as last_year
JOIN 
revenue_2023 as curr_year
ON last_year.branch= curr_year.branch
WHERE last_year.revenue > curr_year.revenue
ORDER BY 4 DESC
LIMIT 5;

