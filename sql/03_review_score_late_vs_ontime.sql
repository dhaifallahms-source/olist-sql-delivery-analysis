/* ============================================================
   Query:     03 - Review score: late vs on-time deliveries
   Question:  Do late deliveries lower customer review scores?
   Tables:    orders, order_reviews
   Logic:     Flag each delivered order as late / on-time, join
              its reviews, compare average score and count.
   Finding:   Late orders average 2.57 stars vs 4.29 for on-time
              orders (a gap of ~1.7 points). 54.0% of late-order
              reviews score 1-2 stars vs 9.2% for on-time orders.
   Notes:     Delivered orders with a delivery date only. An order
              can have more than one review row, so counts and
              averages are per review, not per order. This shows an
              association, not proof that lateness alone causes the
              low scores.
   ============================================================ */
USE olist;
GO

SELECT
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 'Late' ELSE 'On time' END                      AS delivery_status,
    COUNT(*)                                                  AS reviews,
    CAST(AVG(CAST(r.review_score AS FLOAT)) AS DECIMAL(4,2))  AS avg_score,
    CAST(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,2))                          AS pct_low_scores
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
              THEN 'Late' ELSE 'On time' END;