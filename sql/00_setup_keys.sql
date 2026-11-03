/* ============================================================
   Script:    00 - Primary and foreign keys
   Purpose:   Add keys to the imported Olist tables so the data
              model (and the ERD) is explicit.
   Run:       Once, after importing the CSV files into database olist.
   Notes:     order_reviews has no primary key because review_id is
              not unique in this dataset. geolocation and
              category_translation are joined by JOIN only.
   ============================================================ */
USE olist;
GO

-- Primary keys
ALTER TABLE customers      ADD CONSTRAINT pk_customers      PRIMARY KEY (customer_id);
ALTER TABLE sellers        ADD CONSTRAINT pk_sellers        PRIMARY KEY (seller_id);
ALTER TABLE products       ADD CONSTRAINT pk_products       PRIMARY KEY (product_id);
ALTER TABLE orders         ADD CONSTRAINT pk_orders         PRIMARY KEY (order_id);
ALTER TABLE order_items    ADD CONSTRAINT pk_order_items    PRIMARY KEY (order_id, order_item_id);
ALTER TABLE order_payments ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential);
GO

-- Foreign keys
ALTER TABLE orders         ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE order_items    ADD CONSTRAINT fk_items_orders     FOREIGN KEY (order_id)    REFERENCES orders(order_id);
ALTER TABLE order_items    ADD CONSTRAINT fk_items_products   FOREIGN KEY (product_id)  REFERENCES products(product_id);
ALTER TABLE order_items    ADD CONSTRAINT fk_items_sellers    FOREIGN KEY (seller_id)   REFERENCES sellers(seller_id);
ALTER TABLE order_reviews  ADD CONSTRAINT fk_reviews_orders   FOREIGN KEY (order_id)    REFERENCES orders(order_id);
ALTER TABLE order_payments ADD CONSTRAINT fk_payments_orders  FOREIGN KEY (order_id)    REFERENCES orders(order_id);
GO
