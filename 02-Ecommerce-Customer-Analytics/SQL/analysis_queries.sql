CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
	order_approved_at DATETIME,
    order_purchase_timestamp DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
  
);
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);
ALTER TABLE orders
ADD COLUMN order_delivered_carrier_date DATETIME;
LOAD DATA LOCAL INFILE '/Users/poornavenkat/Documents/GitHub/SQL-Projects/02-Ecommerce-Customer-Analytics/data/Raw/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, @order_purchase_timestamp, @order_approved_at, 
 @order_delivered_carrier_date, @order_delivered_customer_date, @order_estimated_delivery_date)
SET 
    order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
    order_approved_at = NULLIF(@order_approved_at, ''),
    order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
    order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
    order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');

-- Analysis Query 1: Monthly Revenue Trend (FIXED)
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(p.payment_value) as total_revenue,
    AVG(p.payment_value) as avg_order_value
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;
-- Analysis Query 2: Customer Lifetime Value (FIXED)
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(p.payment_value) as lifetime_value,
        MIN(o.order_purchase_timestamp) as first_purchase,
        MAX(o.order_purchase_timestamp) as last_purchase,
        DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) as customer_lifespan_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
)
SELECT 
    CASE 
        WHEN lifetime_value > 500 THEN 'High Value'
        WHEN lifetime_value > 200 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(lifetime_value) as avg_lifetime_value,
    AVG(total_orders) as avg_orders,
    AVG(customer_lifespan_days) as avg_lifespan_days
FROM customer_metrics
GROUP BY 
    CASE 
        WHEN lifetime_value > 500 THEN 'High Value'
        WHEN lifetime_value > 200 THEN 'Medium Value'
        ELSE 'Low Value'
    END;
SELECT 
    c.customer_state,
    COUNT(DISTINCT c.customer_id) as customers,
    COUNT(DISTINCT o.order_id) as orders,
    SUM(p.payment_value) as total_revenue,
    AVG(p.payment_value) as avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;