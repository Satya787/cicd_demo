-- setup/demo.sql

-- 1. Create database
CREATE DATABASE IF NOT EXISTS CICD_DEMO;
CREATE SCHEMA IF NOT EXISTS CICD_DEMO.raw;

-- 2. Create table
CREATE OR REPLACE TABLE CICD_DEMO.raw.orders (
    order_id INT,
    customer_name STRING,
    product STRING,
    amount FLOAT,
    order_date DATE
);

-- 3. Insert sample data
INSERT INTO CICD_DEMO.raw.orders VALUES
(1, 'Amit', 'Pizza', 250, '2025-01-01'),
(2, 'Rahul', 'Burger', 150, '2025-01-02'),
(3, 'Sneha', 'Pizza', 300, '2025-01-02'),
(4, 'Priya', 'Pasta', 200, '2025-01-03'),
(5, 'Amit', 'Burger', 180, '2025-01-03');

-- 4. Verify
SELECT * FROM CICD_DEMO.raw.orders;