-- Step 1: Create and select database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Step 2: Drop table if exists
DROP TABLE IF EXISTS raw_orders;

-- Step 3: Create table
CREATE TABLE raw_orders (
    order_id INT,
    customer_email VARCHAR(100),
    product_name VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10,2),
    order_date DATE,
    status VARCHAR(50)
);

-- Step 4: Insert sample data
INSERT INTO raw_orders (order_id, customer_email, product_name, quantity, unit_price, order_date, status) VALUES
(101, 'john.doe@gmail.com', 'Laptop', 1, 75000.00, '2024-01-10', 'delivered'),
(101, 'john.doe@gmail.com', 'Laptop', 1, 75000.00, '2024-01-11', 'delivered'),
(102, 'jane.doe#gmail.com', 'Mobile', 2, 20000.00, '2024-02-15', 'shipped'),
(103, 'alice@gmail.com', 'Tablet', -1, 15000.00, '2024-03-01', 'pending'),
(104, 'bob@gmail.com', 'Monitor', 1, NULL, '2024-03-05', 'delivered'),
(105, 'charlie@gmail.com', 'Keyboard', 1, 1500.00, '2030-01-01', 'pending'),
(106, 'invalid_email', 'Mouse', -2, 500.00, '2035-05-20', 'cancelled'),
(107, 'emma.watson@gmail.com', 'Headphones', 2, 3000.00, '2024-02-20', 'delivered'),
(108, 'noah@gmail.com', 'Speaker', 1, -5000.00, '2024-01-25', 'shipped'),
(109, NULL, 'Camera', 1, 25000.00, '2024-02-10', 'delivered');

-- Step 5: Cleaning logic (UPDATED as per constraints)
WITH deduplicated AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_date) AS rn
    FROM raw_orders
),

cleaned AS (
    SELECT
        order_id,
        customer_email,

        -- ✅ Email validation: contains '@'
        CASE 
            WHEN customer_email LIKE '%@%' THEN 1 ELSE 0
        END AS is_valid_email,

        product_name,

        -- ✅ Quantity > 0
        CASE 
            WHEN quantity > 0 THEN quantity
            ELSE NULL
        END AS quantity,

        -- ✅ Price must not be NULL
        CASE 
            WHEN unit_price IS NOT NULL THEN unit_price
            ELSE NULL
        END AS unit_price,

        -- ✅ Date must be <= 2024-12-31
        CASE 
            WHEN order_date <= '2024-12-31' THEN order_date
            ELSE NULL
        END AS order_date,

        status,

        -- ✅ is_clean flag (ALL conditions)
        CASE 
            WHEN 
                customer_email LIKE '%@%'
                AND quantity > 0
                AND unit_price IS NOT NULL
                AND order_date <= '2024-12-31'
            THEN 1 ELSE 0
        END AS is_clean

    FROM deduplicated
    WHERE rn = 1
)

-- Final output
SELECT *
FROM cleaned
ORDER BY order_id ASC;