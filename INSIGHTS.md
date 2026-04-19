INSIGHTS — SQLite Analytics Challenge
Results below come from running challenge.sql against bais_sqlite_lab.db using the SQLite 3 CLI. All currency figures are in dollars and rounded to two decimals; counts are raw.
Task 1 — Top 5 customers by lifetime spend

Jacob Foster leads at $8,722.67, followed closely by Ethan Gomez at $8,206.19. Together those two account for ~44% of total booked revenue ($38,801.19).
The top five customers (Jacob Foster, Ethan Gomez, Sophia Ahmed, Lucas Hale, Emma Young) combine for $31,248.51, roughly 81% of total revenue — a heavy Pareto concentration worth flagging for the retention team.
I deliberately did not filter by order status. The task says "lifetime spend" and didn't specify realized revenue, so Pending/Shipped/Cancelled orders are included. If we wanted only money-in-the-door revenue, we'd restrict to status = 'Delivered' (see Task 2 variant for how that changes the picture — total drops from $38,801 to $22,773, a ~41% haircut).

Task 2 — Revenue by category

Electronics dominates at $25,364.23 (~65% of total revenue). Furniture is second at $12,712.00 (~33%). Together they make up ~98% of revenue — Grocery and Stationery are rounding-error categories in this dataset.
Restricting to Delivered orders only: Electronics = $13,616.93, Furniture = $8,750.00, Grocery = $260.82, Stationery = $144.90. The ranking does not change between the "all orders" and "Delivered-only" views, which suggests cancellations / pending orders are spread across categories rather than concentrated in one.

Task 3 — Employees earning above their department's average

Exactly 5 employees (one per department) earn more than their department's average. The biggest spread is in Sales: Alice Nguyen earns $72,000 vs. a department average of $61,000 — about 18% above the team mean. The tightest spread is in Operations: Kira Patel at $61,000 vs. $60,500, essentially at parity.
Maya Bennett (IT) has the highest absolute salary in the results at $112,000, reflecting that IT is the highest-paid department overall ($105,333 avg).

Task 4 — Cities with the most Gold customers

All four Gold customers live in Tampa. No other city has any Gold customers at all, so Tampa is the clear center of gravity for the loyalty program in this snapshot.
The loyalty distribution extension shows a very clean geographic pattern: Tampa is entirely Gold; St. Petersburg, Sarasota, and Brandon are Silver-only; Orlando, Clearwater, and Lakeland are Bronze-only. With a sample of only 10 customers this is almost certainly an artifact of the small dataset, but operationally it would still justify concentrating premium-tier marketing spend in Tampa and Silver-tier upsell campaigns in St. Pete / Sarasota / Brandon.

Methodology notes

"Line total" was computed as quantity * unit_price at the order_items level (not products.price), so any per-order discounting is respected.
Department averages in Task 3 come from a subquery that groups employees by department_id — this keeps the query readable without needing a window function.
Totals were sanity-checked: summing per-category revenue in Task 2 reproduces the overall SUM(quantity * unit_price) from order_items ($38,801.19).