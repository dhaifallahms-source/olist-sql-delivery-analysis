/* ============================================================
   Query:     02 - Late delivery rate
   Question:  What share of delivered orders arrive after the
              estimated delivery date?
   Tables:    orders
   Logic:     Compare actual delivery date to the promised date;
              late = actual > estimated.
   Finding:   Of 96,470 delivered orders, 7,826 (8.11%) arrived after
              the estimated date; ~92% were on time or early.
   Notes:     Delivered orders with a delivery date only; rows with
              NULL dates would silently drop out of the comparison,
              so the filter is explicit.
   ============================================================ */
USE olist;
GO

SELECT
    COUNT(*)                                                              AS delivered_orders,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
             THEN 1 ELSE 0 END)                                           AS late_orders,
    CAST(100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                          THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2))  AS late_pct
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;