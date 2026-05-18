-- setup/demo.sql

-- 1. Create database
CREATE DATABASE IF NOT EXISTS demo_db;
CREATE SCHEMA IF NOT EXISTS demo_db.public;

-- 2. Create table
CREATE OR REPLACE TABLE demo_db.public.orders (
    order_id INT,
    customer_name STRING,
    product STRING,
    amount FLOAT,
    order_date DATE
);

-- 3. Insert sample data
INSERT INTO demo_db.public.orders VALUES
(1, 'Amit', 'Pizza', 250, '2025-01-01'),
(2, 'Rahul', 'Burger', 150, '2025-01-02'),
(3, 'Sneha', 'Pizza', 300, '2025-01-02'),
(4, 'Priya', 'Pasta', 200, '2025-01-03'),
(5, 'Amit', 'Burger', 180, '2025-01-03');

-- 4. Verify
SELECT * FROM demo_db.public.orders;