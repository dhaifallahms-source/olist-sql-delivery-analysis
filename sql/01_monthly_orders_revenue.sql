/* ============================================================
   Query:     01 - Monthly orders and revenue
   Question:  How did order volume and revenue evolve over time?
   Tables:    orders, order_items
   Logic:     Join orders to their items, keep delivered orders,
              group by purchase month.
   Finding:   Peak month is 2017-11 (7,289 orders, ~987.8K revenue),
              consistent with the Black Friday season. After that,
              monthly revenue stays between ~726K and ~978K through
              2018-08. 2016 is negligible (platform launch).
   Notes:     Revenue = SUM(price), freight excluded.
              COUNT(DISTINCT order_id) because one order has many items.
   ============================================================ */
USE olist;
GO

SELECT
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS month,
    COUNT(DISTINCT o.order_id)                    AS orders,
    CAST(SUM(oi.price) AS DECIMAL(12,2))          AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY month;