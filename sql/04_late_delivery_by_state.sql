/* ============================================================
   Query:     04 - Late delivery rate by customer state
   Question:  Which customer states suffer the most late deliveries?
   Tables:    orders, customers
   Logic:     Join delivered orders to the customer's state, compute
              late share per state, keep states with enough orders.
   Finding:   Late-delivery rates are highest in MA (19.67%, 717 orders),
              CE (15.32%) and BA (14.04%), versus 8.11% overall. All
              top-10 states are above the overall rate. RJ stands out
              by volume: 13.47% late on 12,350 delivered orders
              (1,664 late).
   Notes:     States with fewer than 500 delivered orders are excluded
              (HAVING) so small samples do not distort the ranking;
              500 is a judgment call. State = the customer's state
              (where the order is shipped), so a late delivery may
              reflect seller distance, not only the state itself.
   ============================================================ */
USE olist;
GO

SELECT TOP 10
    c.customer_state                                                AS state,
    COUNT(*)                                                        AS delivered_orders,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END)                                     AS late_orders,
    CAST(100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                          THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS late_pct
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 500
ORDER BY late_pct DESC;