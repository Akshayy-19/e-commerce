-- 04_demo_queries.sql
-- Run sections individually in SQL Developer (F5 / Run Script).
-- Enable DBMS Output if you want to see the PL/SQL messages.

PROMPT 1. View customers
SELECT * FROM customers ORDER BY customer_id;

PROMPT 2. View products and current stock
SELECT product_id, product_name, unit_price, stock_qty, active_flag
FROM products
ORDER BY product_id;

PROMPT 3. Check stock using a function
SELECT product_id, product_name,
       fn_check_stock(product_id, 2) AS stock_check
FROM products
ORDER BY product_id;

PROMPT 4. Create an order, add items, check total, and record payment
DECLARE
    v_order_id NUMBER;
    v_total    NUMBER;
BEGIN
    pr_create_order(1, v_order_id);
    DBMS_OUTPUT.PUT_LINE('New order ID: ' || v_order_id);

    pr_add_order_item(v_order_id, 1, 2);
    pr_add_order_item(v_order_id, 3, 1);

    v_total := fn_order_total(v_order_id);
    DBMS_OUTPUT.PUT_LINE('Order total: ' || TO_CHAR(v_total, 'FM9999990.00'));

    pr_record_payment(v_order_id, v_total, 'UPI');
    DBMS_OUTPUT.PUT_LINE('Payment recorded.');
END;
/

PROMPT 5. View orders and customer names
SELECT o.order_id, c.customer_name, o.order_date,
       o.order_status, o.order_total, o.payment_status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

PROMPT 6. View order item details
SELECT oi.order_id, p.product_name, oi.quantity,
       oi.unit_price, oi.line_total
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
ORDER BY oi.order_id, oi.order_item_id;

PROMPT 7. View payments
SELECT payment_id, order_id, payment_date, amount, payment_mode
FROM payments
ORDER BY payment_id;

PROMPT 8. Product inventory after order
SELECT product_id, product_name, stock_qty
FROM products
ORDER BY product_id;

PROMPT 9. Revenue by product
SELECT p.product_name, SUM(oi.quantity) AS units_sold,
       SUM(oi.line_total) AS sales_amount
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY sales_amount DESC;

-- The example above inserts data. Use ROLLBACK if you want to undo the demo
-- order, payment, and inventory changes after reviewing the reports.
-- ROLLBACK;
