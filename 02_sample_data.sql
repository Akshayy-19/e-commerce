-- 02_sample_data.sql
-- Sample data for the E-Commerce Order Management System.

INSERT INTO customers (customer_name, email, phone, city)
VALUES ('Aarav Sharma', 'aarav@example.com', '9876500001', 'Ludhiana');

INSERT INTO customers (customer_name, email, phone, city)
VALUES ('Meera Gupta', 'meera@example.com', '9876500002', 'Chandigarh');

INSERT INTO customers (customer_name, email, phone, city)
VALUES ('Kabir Singh', 'kabir@example.com', '9876500003', 'Amritsar');

INSERT INTO products (product_name, category, unit_price, stock_qty)
VALUES ('Wireless Mouse', 'Electronics', 599.00, 25);

INSERT INTO products (product_name, category, unit_price, stock_qty)
VALUES ('USB Keyboard', 'Electronics', 899.00, 18);

INSERT INTO products (product_name, category, unit_price, stock_qty)
VALUES ('Notebook Pack', 'Stationery', 149.00, 50);

INSERT INTO products (product_name, category, unit_price, stock_qty)
VALUES ('Water Bottle', 'Lifestyle', 299.00, 30);

COMMIT;

PROMPT Sample customers and products inserted.
