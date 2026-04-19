-- =====================================================================
-- SQLite Analytics Coding Challenge
-- Author  : Jasper (jtfour2004@gmail.com)
-- Database: bais_sqlite_lab.db
-- Tool    : SQLite 3 via the sqlite3 CLI (works the same in VS Code
--           with the SQLTools SQLite driver or any GUI viewer).
-- Notes   : Each task is wrapped in clear "-- TASK N" banners so you
--           can run them one at a time. Indentation and aliases are
--           kept simple (c/o/oi/p/e/d) so the joins are easy to read.
--
-- Validation: I spot-checked results by (1) summing line totals
--             (quantity * unit_price) across the whole order_items
--             table and confirming it matched the sum of the per-
--             category totals in Task 2, and (2) verifying that the
--             Task 3 department averages match a separate
--             "SELECT department_id, AVG(salary) ... GROUP BY
--             department_id" query.
-- =====================================================================
 
 
-- ---------------------------------------------------------------------
-- TASK 1 — Top 5 Customers by Total Spend
-- Logic : line_total = quantity * unit_price. Roll those up from
--         order_items to orders to customers, then rank.
-- Status filter: NONE (see INSIGHTS.md — this reports lifetime spend
--         "booked," including Pending/Cancelled/Shipped/Delivered).
-- ---------------------------------------------------------------------
SELECT
    c.first_name || ' ' || c.last_name         AS customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spend
FROM customers   AS c
JOIN orders      AS o  ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id   = o.id
GROUP BY c.id, c.first_name, c.last_name
ORDER BY total_spend DESC
LIMIT 5;
 
 
-- ---------------------------------------------------------------------
-- TASK 2 — Total Revenue by Product Category (all orders)
-- Logic : sum line totals grouped by the product's category.
-- ---------------------------------------------------------------------
SELECT
    p.category                                 AS category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products    AS p
JOIN order_items AS oi ON oi.product_id = p.id
GROUP BY p.category
ORDER BY revenue DESC;
 
 
-- ---------------------------------------------------------------------
-- TASK 2 (variant) — Revenue by Category, "Delivered" orders only
-- Logic : same as above but add a row-level WHERE on order status
--         (WHERE filters rows BEFORE aggregation; HAVING would filter
--         groups AFTER aggregation, which isn't what we want here).
-- ---------------------------------------------------------------------
SELECT
    p.category                                 AS category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue_delivered
FROM products    AS p
JOIN order_items AS oi ON oi.product_id = p.id
JOIN orders      AS o  ON o.id          = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY revenue_delivered DESC;
 
 
-- ---------------------------------------------------------------------
-- TASK 3 — Employees Earning Above Their Department Average
-- Logic : Build a small subquery with one row per department giving
--         that department's average salary, then join it back to
--         employees and keep only rows where salary > dept avg.
--         (A correlated subquery or a window function would also
--         work — I used a join-to-subquery for readability.)
-- ---------------------------------------------------------------------
SELECT
    e.first_name,
    e.last_name,
    d.name                          AS department,
    e.salary                        AS employee_salary,
    ROUND(dept_avg.avg_salary, 2)   AS department_average
FROM employees   AS e
JOIN departments AS d ON d.id = e.department_id
JOIN (
    SELECT department_id,
           AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) AS dept_avg ON dept_avg.department_id = e.department_id
WHERE e.salary > dept_avg.avg_salary
ORDER BY d.name ASC, e.salary DESC;
 
 
-- ---------------------------------------------------------------------
-- TASK 4 — Cities with the Most Loyal (Gold) Customers
-- Logic : Count customers whose loyalty_level = 'Gold', grouped by
--         city. Tie-break alphabetically by city.
-- ---------------------------------------------------------------------
SELECT
    city,
    COUNT(*) AS gold_customer_count
FROM customers
WHERE loyalty_level = 'Gold'
GROUP BY city
ORDER BY gold_customer_count DESC, city ASC;
 
 
-- ---------------------------------------------------------------------
-- TASK 4 (extension) — Loyalty distribution by city
-- Logic : Conditional counts (CASE WHEN ... THEN 1 ELSE 0 END) bucket
--         customers into Gold / Silver / Bronze columns per city.
-- ---------------------------------------------------------------------
SELECT
    city,
    SUM(CASE WHEN loyalty_level = 'Gold'   THEN 1 ELSE 0 END) AS gold,
    SUM(CASE WHEN loyalty_level = 'Silver' THEN 1 ELSE 0 END) AS silver,
    SUM(CASE WHEN loyalty_level = 'Bronze' THEN 1 ELSE 0 END) AS bronze,
    COUNT(*)                                                  AS total_customers
FROM customers
GROUP BY city
ORDER BY gold DESC, city ASC;
 