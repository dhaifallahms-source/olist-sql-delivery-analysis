/* ============================================================
   Query:     07 - Where to fix delivery first (state priority)
   Question:  Which customer states should be fixed first to
              reduce late deliveries the most?
   Tables:    orders, customers
   Logic:     Per customer state: delivered orders, late orders,
              late rate, and each state's share of ALL late orders.
              Ranking by late order count (volume), not only by rate.
   Finding:   SP produces the most late orders (2,387; 30.50% of all
              late orders) despite a below-average late rate (5.89% vs
              8.11% overall). RJ combines a high rate (13.47%) with high
              volume (1,664 late orders; 21.26% of the total). Together
              SP and RJ account for ~51.8% of all late deliveries.
              MA (highest rate in Query 04) has only 141 late orders and
              does not reach the top 10 by volume.
   Notes:     A state with a high late rate but few orders adds little
              to the total; a high-volume state with a moderate rate
              can matter more. Ranking by late_orders captures this.
              Customer state is where the order is shipped, so lateness
              may reflect seller distance as well as the state itself.
              pct_of_all_late is computed over ALL states, not only
              the top 10 shown.
   ============================================================ */
USE olist;
GO

WITH state_stats AS (
    SELECT
        c.customer_state                                           AS state,
        COUNT(*)                                                   AS delivered_orders,
        SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                 THEN 1 ELSE 0 END)                                AS late_orders
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY c.customer_state
)
SELECT TOP 10
    state,
    delivered_orders,
    late_orders,
    CAST(100.0 * late_orders / delivered_orders AS DECIMAL(5,2))        AS late_pct,
    CAST(100.0 * late_orders / SUM(late_orders) OVER () AS DECIMAL(5,2)) AS pct_of_all_late,
    RANK() OVER (ORDER BY late_orders DESC)                             AS priority_rank
FROM state_stats
ORDER BY priority_rank;