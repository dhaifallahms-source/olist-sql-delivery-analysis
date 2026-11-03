/* ============================================================
   Query:     06 - Repeat purchase after a late first order
   Question:  Are customers whose first order arrived late less
              likely to buy again?
   Tables:    orders, customers
   Logic:     CTE ranks each real customer's orders by purchase date
              (ROW_NUMBER); first delivered orders are flagged late /
              on-time; a customer counts as "repeat" if they have any
              later order. Compare repeat rates between the two groups.
   Finding:   Customers whose first order arrived late repurchased at
              2.52% (191 of 7,588) vs 3.14% (2,686 of 85,660) for those
              with an on-time first order: a gap of ~0.6 points (about
              20% lower in relative terms). A two-proportion z-test
              gives z = -2.99 (p ~ 0.003), so the gap is unlikely to be
              chance, but it is small in practical terms. Repeat
              purchase is rare overall (~3%).
   Notes:     A real customer is customer_unique_id (customer_id is
              per order). Only customers whose first order was
              delivered with a delivery date are included. "Repeat"
              means any later order, whatever its status. The z-test
              is in 06b_repeat_purchase_ztest.sql (pooled variance).
              It shows an association, not that lateness causes lower
              repurchase.
   ============================================================ */
USE olist;
GO

WITH ranked AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_status,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id
                           ORDER BY o.order_purchase_timestamp) AS order_seq,
        COUNT(*)     OVER (PARTITION BY c.customer_unique_id)   AS total_orders
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
),
first_orders AS (
    SELECT
        customer_unique_id,
        total_orders,
        CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
             THEN 'Late' ELSE 'On time' END AS first_order_status
    FROM ranked
    WHERE order_seq = 1
      AND order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT
    first_order_status,
    COUNT(*)                                                      AS customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)             AS repeat_customers,
    CAST(100.0 * SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,2))                              AS repeat_pct
FROM first_orders
GROUP BY first_order_status;