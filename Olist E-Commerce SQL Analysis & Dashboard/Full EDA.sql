----------------------------------------------------------
-- Understanding and modifying the data
----------------------------------------------------------

-- As product categories are in Portuguese, they will first be translated into English to make the querying
-- process easier. Fortunately, translations have been provided in the 'product_category_name_translation' 
-- table and it only takes a few simple commands to create a new column and populate it with the matching
-- category names in English.
ALTER TABLE products ADD product_category_name_english NVARCHAR(255);

UPDATE products
SET product_category_name_english = ct.product_category_name_english
FROM products p
JOIN product_category_name_translation ct
	ON p.product_category_name =  ct.product_category_name;

ALTER TABLE products DROP COLUMN product_category_name;

-- In this dataset each customer has only made a single order
SELECT customer_id, COUNT(order_id)
FROM orders
GROUP BY customer_id
ORDER BY 2 DESC;

-- And no customer has not placed an order
SELECT COUNT(*)
FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM orders);

----------------------------------------------------------
-- Looking at products
----------------------------------------------------------

-- Number of different products
SELECT COUNT(DISTINCT product_id)
FROM products;

-- Different product categories
SELECT DISTINCT product_category_name_english
FROM products;

-- Number of products belonging to each category
SELECT product_category_name_english AS Category, COUNT(*) AS "Product Count"
FROM products
GROUP BY product_category_name_english
ORDER BY 2 DESC;

-- Percentage of products belonging to each category
SELECT product_category_name_english AS Category, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM products) AS Percentage
FROM products
GROUP BY product_category_name_english
ORDER BY 2 DESC;

-- Average dimensions of a product
SELECT AVG(product_weight_g) AS " Weight", AVG(product_length_cm) AS "Length", AVG(product_height_cm) AS "Height", AVG(product_width_cm) AS "Width"
FROM products;

-- Top 20 best selling products ranked
SELECT TOP 20 product_id, COUNT(product_id) AS "No. Orders", RANK() OVER (ORDER BY COUNT(product_id) DESC) AS "Ranking"
FROM order_items
GROUP BY product_id
ORDER BY COUNT(product_id) DESC;

----------------------------------------------------------
-- Looking at orders
----------------------------------------------------------

-- Total number of orders placed
SELECT COUNT(*) AS "Total Orders"
FROM orders;

-- Number of orders by order status
SELECT order_status, COUNT(*)
FROM orders
GROUP BY order_status;

-- Total value of each order
SELECT o.order_id, o.customer_id, op.payment_value
FROM orders o
JOIN order_payments op
	ON o.order_id = op.order_id;

-- Total orders by year
SELECT YEAR(order_purchase_timestamp) AS "Year", COUNT(order_id) AS "Orders"
FROM orders 
GROUP BY YEAR(order_purchase_timestamp);

-- Total orders by year and month
SELECT YEAR(order_purchase_timestamp) AS "Year", DATENAME(MONTH, order_purchase_timestamp) AS "Month", COUNT(order_id) AS "Orders"
FROM orders 
GROUP BY YEAR(order_purchase_timestamp), DATENAME(MONTH, order_purchase_timestamp)
ORDER BY 1, 2;

-- Average Time (in days) between the order being placed and the order being delivered 
SELECT AVG(DATEDIFF(SECOND, order_purchase_timestamp, order_delivered_customer_date) / 60.0 / 60.0 / 24.0)
FROM orders
WHERE order_status = 'delivered';

-- Average Time (in days) difference between the estimated delivery date and the actual delivery date
SELECT AVG(DATEDIFF(SECOND, order_estimated_delivery_date, order_delivered_customer_date) / 60.0 / 60.0 / 24.0)
FROM orders
WHERE order_status = 'delivered';

-- Total order by year
SELECT YEAR(o.order_purchase_timestamp) AS "Year", SUM(op.payment_value) AS "Revenue"
FROM orders o
JOIN order_payments op
	ON o.order_id = op.order_id
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY 2 DESC;

-- Number of items in each order 
SELECT order_id, COUNT(*)
FROM order_items
GROUP BY order_id;

-- Number of items in each order ranked (1 being the most items) 
SELECT order_id, COUNT(*) AS order_items, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) ranked
FROM order_items
GROUP BY order_id;

----------------------------------------------------------
-- Looking at order payments
----------------------------------------------------------

-- Different payment types and the number of orders placed using them
SELECT payment_type, COUNT(*) AS "Orders"
FROM order_payments
GROUP BY payment_type;

-- Highest number of payment installments made for a single order
SELECT MAX(payment_installments) 
FROM order_payments;

-- Average payment value
SELECT AVG(payment_value)
FROM order_payments;

-- Order payments greater than the average payment value
SELECT *
FROM order_payments
WHERE payment_value > (SELECT AVG(payment_value) FROM order_payments);

-- Categorising payment size by payment value
SELECT *,
CASE
	WHEN payment_value < 300 THEN 'Small'
	WHEN payment_value BETWEEN 300 AND 700 THEN 'Medium'
	ELSE 'Large'
END AS "Cost Bracket"
FROM order_payments;

-- Most expensive payments made using the voucher payment method
SELECT *
FROM order_payments
WHERE payment_type = 'voucher' 
AND payment_value = (SELECT MAX(payment_value)
					FROM order_payments 
					WHERE payment_type = 'voucher')

-- Most expensive order for each payment type
SELECT order_id, payment_type, payment_value
FROM (
	SELECT order_id, payment_type, payment_value, RANK() OVER (PARTITION BY payment_type ORDER BY payment_value DESC) rnk 
	FROM order_payments
	) sub
WHERE rnk = 1 AND payment_type <> 'not_defined'
ORDER BY payment_value DESC;

----------------------------------------------------------
-- Looking at sellers
----------------------------------------------------------

-- Total number of sellers
SELECT COUNT(*)
FROM sellers;

-- Total number of sellers in each state
SELECT seller_state, COUNT(*)
FROM sellers
GROUP BY seller_state
ORDER BY 2 DESC;

-- Which seller has sold the most items (in terms of quantity)?
SELECT TOP 1 s.*, COUNT(oi.seller_id) AS "Quantity Sold"
FROM sellers s
JOIN order_items oi
	ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_zip_code_prefix, s.seller_city, s.seller_state
ORDER BY 2 DESC;

-- Total value of sales made by sellers
SELECT seller_id, CONCAT('$', SUM(payment_value)) AS "Total Value"
FROM order_items oi
JOIN orders o
	ON oi.order_id = o.order_id
JOIN order_payments op
	ON o.order_id = op.order_id
GROUP BY seller_id;

----------------------------------------------------------
-- Looking at customers
----------------------------------------------------------

-- All states which customers have ordered from
SELECT DISTINCT customer_state
FROM customers;

-- Total number of customers from each city
SELECT customer_city, customer_state, COUNT(*)
FROM customers
GROUP BY customer_city, customer_state;

-- From which state were the most orders placed?
SELECT TOP 1 c.customer_state, COUNT(o.order_id) AS state_orders
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY state_orders DESC;

-- Total revenue by state
SELECT c.customer_state, COUNT(o.order_id) AS state_orders, SUM(op.payment_value) AS state_revenue
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_payments op
	ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY 2 DESC;

-- Total spent by each customer ranked
SELECT c.customer_id, SUM(op.payment_value) AS "Total Spent", DENSE_RANK() OVER (ORDER BY SUM(op.payment_value) DESC) ranked
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_payments op
	ON o.order_id = op.order_id
GROUP BY c.customer_id;

-- Find the customer which placed the most expensive individual order
SELECT c.*, o.order_id, op.payment_value
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_payments op
	ON o.order_id = op.order_id
WHERE op.payment_value = (SELECT MAX(payment_value) FROM order_payments)
