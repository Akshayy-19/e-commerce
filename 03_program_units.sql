-- 03_program_units.sql
-- Functions, procedures, and triggers.
-- Run after 01_schema.sql and 02_sample_data.sql.

CREATE OR REPLACE FUNCTION fn_check_stock (
    p_product_id IN products.product_id%TYPE,
    p_quantity   IN NUMBER
) RETURN VARCHAR2
IS
    v_stock products.stock_qty%TYPE;
BEGIN
    SELECT stock_qty
      INTO v_stock
      FROM products
     WHERE product_id = p_product_id
       AND active_flag = 'Y';

    IF p_quantity <= 0 THEN
        RETURN 'INVALID QUANTITY';
    ELSIF v_stock >= p_quantity THEN
        RETURN 'AVAILABLE';
    ELSE
        RETURN 'INSUFFICIENT STOCK';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'PRODUCT NOT FOUND OR INACTIVE';
END;
/

CREATE OR REPLACE FUNCTION fn_order_total (
    p_order_id IN orders.order_id%TYPE
) RETURN NUMBER
IS
    v_total NUMBER(12,2);
BEGIN
    SELECT NVL(SUM(line_total), 0)
      INTO v_total
      FROM order_items
     WHERE order_id = p_order_id;

    RETURN v_total;
END;
/

CREATE OR REPLACE PROCEDURE pr_create_order (
    p_customer_id IN customers.customer_id%TYPE,
    p_order_id    OUT orders.order_id%TYPE
)
IS
    v_customer_count NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_customer_count
      FROM customers
     WHERE customer_id = p_customer_id;

    IF v_customer_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Customer does not exist.');
    END IF;

    INSERT INTO orders (customer_id)
    VALUES (p_customer_id)
    RETURNING order_id INTO p_order_id;
END;
/

CREATE OR REPLACE PROCEDURE pr_add_order_item (
    p_order_id   IN orders.order_id%TYPE,
    p_product_id IN products.product_id%TYPE,
    p_quantity   IN NUMBER
)
IS
    v_price   products.unit_price%TYPE;
    v_status  VARCHAR2(40);
BEGIN
    IF p_quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Quantity must be greater than zero.');
    END IF;

    v_status := fn_check_stock(p_product_id, p_quantity);
    IF v_status <> 'AVAILABLE' THEN
        RAISE_APPLICATION_ERROR(-20003, v_status);
    END IF;

    SELECT unit_price
      INTO v_price
      FROM products
     WHERE product_id = p_product_id;

    INSERT INTO order_items
        (order_id, product_id, quantity, unit_price, line_total)
    VALUES
        (p_order_id, p_product_id, p_quantity, v_price, p_quantity * v_price);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20004,
            'This product is already in the order. Use a different product or update the existing line.');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Order or product was not found.');
END;
/

CREATE OR REPLACE PROCEDURE pr_record_payment (
    p_order_id     IN orders.order_id%TYPE,
    p_amount       IN NUMBER,
    p_payment_mode IN VARCHAR2
)
IS
    v_total       orders.order_total%TYPE;
    v_paid        NUMBER(12,2);
    v_mode        VARCHAR2(20) := UPPER(TRIM(p_payment_mode));
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Payment amount must be greater than zero.');
    END IF;

    SELECT order_total
      INTO v_total
      FROM orders
     WHERE order_id = p_order_id
       FOR UPDATE;

    SELECT NVL(SUM(amount), 0)
      INTO v_paid
      FROM payments
     WHERE order_id = p_order_id;

    IF v_paid + p_amount > v_total THEN
        RAISE_APPLICATION_ERROR(-20007, 'Payment exceeds the remaining order balance.');
    END IF;

    INSERT INTO payments (order_id, amount, payment_mode)
    VALUES (p_order_id, p_amount, v_mode);

    IF v_paid + p_amount = v_total THEN
        UPDATE orders SET payment_status = 'PAID' WHERE order_id = p_order_id;
    ELSIF v_paid + p_amount > 0 THEN
        UPDATE orders SET payment_status = 'PARTIAL' WHERE order_id = p_order_id;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008, 'Order does not exist.');
END;
/

-- Set timestamps consistently when an order is inserted.
CREATE OR REPLACE TRIGGER trg_orders_bi
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF :NEW.order_date IS NULL THEN
        :NEW.order_date := SYSDATE;
    END IF;
    IF :NEW.order_status IS NULL THEN
        :NEW.order_status := 'NEW';
    END IF;
    IF :NEW.payment_status IS NULL THEN
        :NEW.payment_status := 'PENDING';
    END IF;
    IF :NEW.order_total IS NULL THEN
        :NEW.order_total := 0;
    END IF;
END;
/

-- Validate stock and reduce it when an order item is inserted.
CREATE OR REPLACE TRIGGER trg_order_items_bi
BEFORE INSERT ON order_items
FOR EACH ROW
DECLARE
    v_stock products.stock_qty%TYPE;
    v_active products.active_flag%TYPE;
BEGIN
    SELECT stock_qty, active_flag
      INTO v_stock, v_active
      FROM products
     WHERE product_id = :NEW.product_id
       FOR UPDATE;

    IF v_active <> 'Y' THEN
        RAISE_APPLICATION_ERROR(-20010, 'Product is inactive.');
    END IF;

    IF :NEW.quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Quantity must be greater than zero.');
    END IF;

    IF v_stock < :NEW.quantity THEN
        RAISE_APPLICATION_ERROR(-20012, 'Insufficient stock for this product.');
    END IF;

    :NEW.line_total := :NEW.quantity * :NEW.unit_price;

    UPDATE products
       SET stock_qty = stock_qty - :NEW.quantity
     WHERE product_id = :NEW.product_id;
END;
/

-- Recalculate the order total after an item is inserted, updated, or deleted.

CREATE OR REPLACE TRIGGER trg_order_items_aiud
AFTER INSERT OR UPDATE OR DELETE ON order_items
BEGIN
    UPDATE orders o
    SET order_total = (
        SELECT NVL(SUM(oi.line_total), 0)
        FROM order_items oi
        WHERE oi.order_id = o.order_id
    );
END;
/


PROMPT Functions, procedures, and triggers created.
