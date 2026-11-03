/* ============================================================
   Query:     05 - Sellers with the highest late-delivery rate
   Question:  Which sellers drive late deliveries?
   Tables:    order_items, orders, sellers
   Logic:     CTE counts delivered orders and late orders per seller;
              the outer query ranks sellers by late share.
   Finding:   Among sellers with 100+ delivered orders, the top 10 have
              late rates of 15.52%-23.14% (vs 8.11% overall). The worst
              is a seller in MA at 23.14% (90 of 389 orders late).
              8 of the 10 are based in SP, 1 in MA, 1 in PR.
   Notes:     Only sellers with at least 100 delivered orders are
              ranked (small samples are noisy); 100 is a judgment call.
              Orders are counted with COUNT(DISTINCT) because an order
              can contain several items from the same seller.
              Many top sellers being in SP may simply reflect that SP
              has the most sellers; this query does not test that.
   ============================================================ */
USE olist;
GO

WITH seller_stats AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                            THEN o.order_id END) AS late_orders
    FROM order_items oi
    JOIN orders  o ON o.order_id  = oi.order_id
    JOIN sellers s ON s.seller_id = oi.seller_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
    GROUP BY s.seller_id, s.seller_state
)
SELECT TOP 10
    seller_id,
    seller_state,
    orders,
    late_orders,
    CAST(100.0 * late_orders / orders AS DECIMAL(5,2))       AS late_pct,
    RANK() OVER (ORDER BY 1.0 * late_orders / orders DESC)   AS late_rank
FROM seller_stats
WHERE orders >= 100
ORDER BY late_rank;