-- ============================================================
-- Database : food_delivery
-- Topics   : Aggregate functions, GROUP BY / HAVING, CASE,
--            transactions (COMMIT, ROLLBACK, SAVEPOINT),
--            JOINs (INNER, LEFT, RIGHT, FULL via UNION),
--            UNION / UNION ALL, EXISTS, TRUNCATE / DROP,
--            integer overflow and BIGINT
-- Tested on: MariaDB (MySQL-compatible)
-- ============================================================

CREATE DATABASE IF NOT EXISTS food_delivery;
USE food_delivery;

CREATE TABLE food_orders (
    order_id      INT PRIMARY KEY,
    customer_name VARCHAR(100),
    food_item     VARCHAR(100),
    category      VARCHAR(100),
    quantity      INT,
    amount        DECIMAL(10,2),
    order_status  VARCHAR(100)
);

INSERT INTO food_orders VALUES
    (1,  'Arun',   'Burger',  'Fast Food',   2, 300, 'Delivered'),
    (2,  'Meera',  'Pizza',   'Fast Food',   1, 450, 'Delivered'),
    (3,  'Rahul',  'Biryani', 'Main Course', 2, 500, 'Pending'),
    (4,  'Anjali', 'Pasta',   'Main Course', 1, 250, 'Delivered'),
    (5,  'Vishnu', 'Burger',  'Fast Food',   3, 450, 'Cancelled'),
    (6,  'Sneha',  'Biryani', 'Main Course', 1, 250, 'Delivered'),
    (7,  'Nikhil', 'Pizza',   'Fast Food',   2, 900, 'Delivered'),
    (8,  'Diya',   'Pasta',   'Main Course', 2, 500, 'Pending'),
    (9,  'Akhil',  'Burger',  'Fast Food',   1, 150, 'Delivered'),
    (10, 'Neha',   'Biryani', 'Main Course', 3, 750, 'Delivered');

-- ------------------------------------------------------------
-- PART 1: Sorting, aggregates, GROUP BY, HAVING, CASE
-- ------------------------------------------------------------
SELECT * FROM food_orders ORDER BY amount DESC;

SELECT COUNT(*) AS total_orders FROM food_orders;
SELECT order_status, COUNT(*) AS orders FROM food_orders GROUP BY order_status;

SELECT AVG(amount) AS average_order_amount FROM food_orders;
SELECT MAX(amount) AS highest_order FROM food_orders;
SELECT MIN(amount) AS lowest_order  FROM food_orders;

SELECT category, COUNT(*) AS total_orders
FROM food_orders
GROUP BY category;

-- HAVING filters groups (WHERE filters rows)
SELECT food_item, COUNT(*) AS order_count
FROM food_orders
GROUP BY food_item
HAVING COUNT(*) > 2;

-- CASE expression
SELECT order_id, customer_name, amount,
       CASE
           WHEN amount >= 500 THEN 'high value'
           WHEN amount >= 300 THEN 'medium value'
           ELSE 'low value'
       END AS order_category
FROM food_orders;

-- ------------------------------------------------------------
-- PART 2: Transactions
-- ------------------------------------------------------------

-- COMMIT: changes are saved permanently
START TRANSACTION;
UPDATE food_orders SET order_status = 'Delivered' WHERE order_id = 3;
COMMIT;

-- ROLLBACK: changes are undone
START TRANSACTION;
UPDATE food_orders SET amount = 100 WHERE order_id = 1;
SELECT * FROM food_orders WHERE order_id = 1;   -- shows 100
ROLLBACK;
SELECT * FROM food_orders WHERE order_id = 1;   -- back to 300

-- Update inside a transaction
START TRANSACTION;
UPDATE food_orders SET amount = 160 WHERE order_id = 1;
COMMIT;

-- SAVEPOINT: roll back only part of a transaction
START TRANSACTION;
UPDATE food_orders SET order_status = 'Delivered' WHERE order_id = 8;
SAVEPOINT sp1;
UPDATE food_orders SET amount = 160 WHERE order_id = 8;
SAVEPOINT sp2;
INSERT INTO food_orders (order_id) VALUES (11);
ROLLBACK TO sp1;     -- undoes the amount change and the new row
COMMIT;              -- keeps the status change made before sp1

SELECT * FROM food_orders;

-- ------------------------------------------------------------
-- PART 3: JOINs, UNION, EXISTS
-- ------------------------------------------------------------
CREATE TABLE food_payments (
    payment_id     INT PRIMARY KEY,
    order_id       INT,
    payment_method VARCHAR(30),
    payment_amount DECIMAL(10,2),
    payment_status VARCHAR(30)
);

-- Payment 109 refers to order 11, which does not exist in food_orders.
-- Orders 5 and 8 have no payment. This is used to demonstrate the joins.
INSERT INTO food_payments VALUES
    (101, 1,  'UPI',         300, 'Paid'),
    (102, 2,  'Credit Card', 450, 'Paid'),
    (103, 3,  'Cash',        500, 'Pending'),
    (104, 4,  'UPI',         250, 'Paid'),
    (105, 6,  'Debit Card',  250, 'Paid'),
    (106, 7,  'UPI',         900, 'Paid'),
    (107, 9,  'Cash',        150, 'Paid'),
    (108, 10, 'Credit Card', 750, 'Paid'),
    (109, 11, 'UPI',         400, 'Paid');

-- INNER JOIN: only orders that have a payment (8 rows)
SELECT f.order_id, f.customer_name, f.food_item, p.payment_method, p.payment_amount
FROM food_orders f
INNER JOIN food_payments p ON f.order_id = p.order_id;

-- LEFT JOIN: all orders, with NULL where there is no payment (10 rows)
SELECT f.order_id, f.customer_name, f.food_item, p.payment_method, p.payment_amount
FROM food_orders f
LEFT JOIN food_payments p ON f.order_id = p.order_id;

-- RIGHT JOIN: all payments, with NULL where the order does not exist
SELECT f.order_id, f.customer_name, f.food_item, p.payment_method, p.payment_amount
FROM food_orders f
RIGHT JOIN food_payments p ON f.order_id = p.order_id;

-- FULL OUTER JOIN (MySQL/MariaDB has none, so LEFT JOIN UNION RIGHT JOIN) (11 rows)
SELECT f.order_id, f.customer_name, f.food_item, p.payment_method, p.payment_amount
FROM food_orders f
LEFT JOIN food_payments p ON f.order_id = p.order_id
UNION
SELECT f.order_id, f.customer_name, f.food_item, p.payment_method, p.payment_amount
FROM food_orders f
RIGHT JOIN food_payments p ON f.order_id = p.order_id;

-- UNION removes duplicates, UNION ALL keeps them
SELECT customer_name AS name FROM food_orders WHERE order_status = 'Delivered'
UNION
SELECT customer_name AS name FROM food_orders WHERE amount >= 500;

SELECT customer_name AS name FROM food_orders WHERE order_status = 'Delivered'
UNION ALL
SELECT customer_name AS name FROM food_orders WHERE amount >= 500;

-- EXISTS (correlated subquery): orders that have at least one payment
SELECT f.order_id, f.customer_name, f.food_item
FROM food_orders f
WHERE EXISTS (SELECT 1 FROM food_payments p WHERE f.order_id = p.order_id);

-- ------------------------------------------------------------
-- PART 4: Data types, TRUNCATE and DROP
-- ------------------------------------------------------------
CREATE TABLE sample (
    sample_id     INT PRIMARY KEY,
    phone_no      INT,
    date_of_birth DATE
);

-- Fails with ERROR 1264: a 10-digit number is out of range for INT.
-- INSERT INTO sample VALUES (1, 9876543210, '2000-01-01');

-- Fix: change the column to BIGINT
ALTER TABLE sample MODIFY phone_no BIGINT;
INSERT INTO sample VALUES (1, 9876543210, '2000-01-01');   -- fictional number
SELECT * FROM sample;

-- Dates must be in YYYY-MM-DD format ('17-08-2009' is rejected).

TRUNCATE TABLE sample;   -- removes all rows, keeps the table
SELECT * FROM sample;    -- empty set

DROP TABLE sample;       -- removes the table itself
