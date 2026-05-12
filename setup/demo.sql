-- setup/demo.sql

-- 1. Create database
CREATE DATABASE IF NOT EXISTS cicd_demo;
CREATE SCHEMA IF NOT EXISTS cicd_demo.raw;

-- 2. Create table
CREATE OR REPLACE TABLE cicd_demo.raw.orders (
    order_id INT,
    customer_name STRING,
    product STRING,
    amount FLOAT,
    order_date DATE
);

-- 3. Insert sample data
INSERT INTO cicd_demo.raw.orders VALUES
(1, 'Amit', 'Pizza', 250, '2025-01-01'),
(2, 'Rahul', 'Burger', 150, '2025-01-02'),
(3, 'Sneha', 'Pizza', 300, '2025-01-02'),
(4, 'Priya', 'Pasta', 200, '2025-01-03'),
(5, 'Amit', 'Burger', 180, '2025-01-03');

-- 4. Verify
SELECT * FROM cicd_demo.raw.orders;