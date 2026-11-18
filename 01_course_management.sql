-- ============================================================
-- Database : course_management
-- Topics   : DDL (CREATE / ALTER / RENAME), UPDATE, filtering
--            (AND, OR, NOT, BETWEEN, IN, LIKE, IS NULL),
--            DISTINCT, aliases, string function, ORDER BY,
--            LIMIT / OFFSET
-- Tested on: MariaDB (MySQL-compatible)
-- ============================================================

CREATE DATABASE IF NOT EXISTS course_management;
USE course_management;

-- ------------------------------------------------------------
-- PART 1: Table basics and ALTER TABLE
-- ------------------------------------------------------------
CREATE TABLE courses (
    course_id   INT PRIMARY KEY,
    course_name VARCHAR(50),
    trainer     VARCHAR(50),
    duration    INT,
    payment     DECIMAL(10,2),
    location    VARCHAR(100)
);

INSERT INTO courses (course_id, course_name, trainer, duration, payment) VALUES
    (101, 'Python Fullstack', 'Arjun', 7, 67900.00),
    (102, 'Java Fullstack',   'Sanu',  6, 25000.00),
    (103, 'Maths',            'Soph',  8,  2690.00);

-- UPDATE: fill in the location for each course
UPDATE courses SET location = 'Kochi' WHERE course_id = 101;
UPDATE courses SET location = 'Tvm'   WHERE course_id = 102;
UPDATE courses SET location = 'Ktd'   WHERE course_id = 103;

SELECT * FROM courses;

-- ALTER TABLE: add a column, then drop it
ALTER TABLE courses ADD sample INT;
ALTER TABLE courses DROP COLUMN sample;

-- RENAME the table
ALTER TABLE courses RENAME TO student_courses;
DESC student_courses;

-- MODIFY a column's data type
ALTER TABLE student_courses MODIFY duration BIGINT;
DESC student_courses;

-- ------------------------------------------------------------
-- PART 2: customer_orders - filtering and sorting practice
-- ------------------------------------------------------------
CREATE TABLE customer_orders (
    order_id       INT PRIMARY KEY,
    customer_name  VARCHAR(50),
    product_name   VARCHAR(50),
    category       VARCHAR(50),
    amount         DECIMAL(10, 2),
    quantity       INT,
    city           VARCHAR(50),
    payment_status VARCHAR(50),
    coupon_code    VARCHAR(50)
);

INSERT INTO customer_orders VALUES
    (101, 'Arun',   'Laptop',       'Electronics', 45000, 1, 'Kochi',      'Paid',      'SAVE10'),
    (102, 'Meera',  'Headphones',   'Electronics',  2500, 2, 'Trivandrum', 'Pending',   NULL),
    (103, 'Rahul',  'Office Chair', 'Furniture',    8500, 1, 'Kochi',      'Paid',      NULL),
    (104, 'Anu',    'Smartphone',   'Electronics', 32000, 1, 'Calicut',    'Cancelled', 'R500'),
    (105, 'Vishnu', 'Desk',         'Furniture',   12000, 1, 'Kochi',      'Pending',   'SAVE10'),
    (106, 'Sneha',  'Keyboard',     'Accessories',  1000, 3, 'Trivandrum', 'Paid',      NULL),
    (107, 'Nikhil', 'Monitor',      'Electronics', 10000, 2, 'Calicut',    'Paid',      NULL),
    (108, 'Divya',  'Mouse',        'Accessories',   900, 2, 'Kochi',      'Cancelled', NULL),
    (109, 'Akhil',  'Tablet',       'Electronics', 20000, 1, 'Trivandrum', 'Pending',   'SAVE10'),
    (110, 'Neha',   'Bookshelf',    'Furniture',    7500, 2, 'Calicut',    'Paid',      NULL);

-- AND
SELECT * FROM customer_orders WHERE city = 'Kochi' AND amount > 10000;

-- OR
SELECT * FROM customer_orders
WHERE payment_status = 'Pending' OR payment_status = 'Cancelled';

-- NOT
SELECT * FROM customer_orders WHERE NOT payment_status = 'Paid';

-- BETWEEN
SELECT * FROM customer_orders WHERE amount BETWEEN 5000 AND 20000;

-- IN / NOT IN
SELECT * FROM customer_orders WHERE city IN ('Kochi', 'Calicut');
SELECT * FROM customer_orders WHERE city NOT IN ('Kochi', 'Calicut');

-- LIKE: starts with, ends with, contains, second letter
SELECT * FROM customer_orders WHERE customer_name LIKE 'A%';
SELECT * FROM customer_orders WHERE customer_name LIKE '%a';
SELECT * FROM customer_orders WHERE product_name  LIKE '%book%';
SELECT * FROM customer_orders WHERE customer_name LIKE '_e%';

-- NULL handling
SELECT * FROM customer_orders WHERE coupon_code IS NULL;
SELECT * FROM customer_orders WHERE coupon_code IS NOT NULL;

-- Combining conditions
SELECT * FROM customer_orders
WHERE category = 'Electronics' AND amount BETWEEN 20000 AND 70000;

SELECT * FROM customer_orders
WHERE payment_status = 'Pending'
   OR (payment_status = 'Paid' AND amount > 30000);

-- NOTE: NOT IN ('Electronics' OR 'Furniture') is a mistake, because the OR
-- is evaluated before IN and the result is wrong (empty). Correct form:
SELECT * FROM customer_orders WHERE category NOT IN ('Electronics', 'Furniture');

-- DISTINCT
SELECT DISTINCT city FROM customer_orders;
SELECT DISTINCT category, city FROM customer_orders;

-- Column and table aliases
SELECT order_id AS order_no FROM customer_orders;
SELECT order_id AS order_no, customer_name AS customer FROM customer_orders;
SELECT * FROM customer_orders AS orders;

-- String function: LENGTH
SELECT customer_name, LENGTH(customer_name) AS name_length FROM customer_orders;
SELECT customer_name FROM customer_orders WHERE LENGTH(customer_name) > 4;

-- LIMIT, OFFSET, ORDER BY
SELECT * FROM customer_orders LIMIT 3;
SELECT * FROM customer_orders ORDER BY amount DESC LIMIT 3;
SELECT * FROM customer_orders ORDER BY order_id LIMIT 3 OFFSET 3;
SELECT DISTINCT category AS product_category
FROM customer_orders ORDER BY product_category;
SELECT * FROM customer_orders ORDER BY amount DESC;
