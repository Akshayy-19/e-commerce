# E-Commerce Order Management System (Beginner PL/SQL Project)

A beginner-friendly Oracle SQL and PL/SQL college project. It models customers, products, orders, order items, and payments. It demonstrates relational design, constraints, sample data, procedures, functions, triggers, and demo queries.

## Important compatibility note

This project targets **Oracle Database Free / Oracle Database 21c+** and uses standard Oracle SQL and PL/SQL. You do not need the native Oracle 26ai Windows installer specifically to study the code. You do need access to an Oracle database to execute these scripts. On Windows 11 Home, options include an Oracle Database container through Docker Desktop/WSL 2, or an Oracle-hosted learning environment if available to you.

## Project features

- Customer registration and product catalogue
- Create orders and add order items
- Automatic line totals and order totals
- Product stock validation and stock reduction when an order item is inserted
- Order status updates
- Payment recording
- Functions to calculate order totals and check stock
- Procedures to create orders, add items, and record payments
- Triggers for timestamps, stock control, and order total maintenance

## Folder structure

```text
ecommerce-order-management-plsql/
├── 01_schema.sql
├── 02_sample_data.sql
├── 03_program_units.sql
├── 04_demo_queries.sql
├── 05_optional_cleanup.sql
└── README.md
```

## Run the scripts in this order

Connect to your own practice schema in SQL Developer, SQLcl, or SQL*Plus. Do not run these scripts as SYS or SYSTEM.

1. `01_schema.sql` — creates tables, primary keys, foreign keys, and checks.
2. `02_sample_data.sql` — inserts sample customers and products, then commits.
3. `03_program_units.sql` — creates functions, procedures, and triggers.
4. `04_demo_queries.sql` — shows example calls and reports.

Run each script in a SQL worksheet using **Run Script (F5)** in SQL Developer. If using SQL*Plus/SQLcl, use `@path/to/script.sql`.

The scripts are designed for a fresh project schema. If you run `01_schema.sql` a second time, Oracle will report that the tables already exist. Use `05_optional_cleanup.sql` first if you want to reset the project. The cleanup script drops only this project's objects.

## Beginner demo walkthrough

After running scripts 1–3, run the statements in `04_demo_queries.sql` one section at a time:

- View the sample customers and products.
- Create an order for customer 1.
- Add product 1 with quantity 2.
- Check the order total using `fn_order_total`.
- Record a payment.
- Review order, item, payment, and inventory reports.

The demo script includes `ROLLBACK` around its transaction example so you can repeat it without changing the sample data permanently. To keep the example order, replace the final `ROLLBACK;` with `COMMIT;`.

## Main business rules

- An order belongs to one customer.
- An order contains one or more order items.
- Each order item refers to one product.
- Quantity must be positive; price and amounts cannot be negative.
- Adding an order item checks available stock and decreases the product's stock.
- The order total is recalculated when an order item is inserted, updated, or deleted.
- A payment cannot exceed the current order total.
- Payment status is `PENDING`, `PARTIAL`, or `PAID` based on recorded payments.

## Learning outcomes

By completing this project, you can explain:
- DDL: `CREATE TABLE`, constraints, primary keys, foreign keys.
- DML: `INSERT`, `UPDATE`, `DELETE`, `SELECT`.
- PL/SQL blocks and exception handling.
- Stored procedures and functions.
- Row-level triggers and `:NEW` / `:OLD`.
- Joins, grouping, and aggregate functions.

## Notes and limitations

This is an educational starter project, not a production commerce platform. It does not include a web interface, authentication, tax rules, shipping integrations, refunds, or concurrent-inventory locking strategy for a real store. The trigger reduces stock when an item is added; deleting an item does not automatically restore stock in this beginner version. A production system would need a more complete inventory ledger and transaction design.
