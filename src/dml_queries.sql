-- ============================================
-- Inventory and Order Management System
-- DML Script - Sample Data, Queries, Views & Stored Procedures (MySQL Version)
-- ============================================

-- ============================================
-- SECTION 1: SAMPLE DATA INSERTION
-- ============================================

-- Insert Customers
INSERT INTO customers (full_name, email, phone, shipping_address) VALUES
('Kwame Mensah', 'kwame.mensah@email.com', '+233-24-123-4567', '12 Independence Ave, Accra, GA'),
('Akosua Agyapong', 'akosua.a@email.com', '+233-20-987-6543', '45 Ashanti Rd, Kumasi, AS'),
('Kofi Osei', 'kofi.osei@email.com', '+233-54-111-2222', '89 Market Circle, Takoradi, WR'),
('Abena Boateng', 'abena.b@email.com', '+233-27-333-4444', '23 Spintex Rd, Accra, GA'),
('Yaw Asante', 'yaw.asante@email.com', '+233-26-555-6666', '67 KNUST Campus, Kumasi, AS'),
('Esi Darko', 'esi.darko@email.com', '+233-50-777-8888', '10 Cape Coast Castle Rd, Cape Coast, CR'),
('Kojo Appiah', 'kojo.appiah@email.com', '+233-23-999-0000', '55 Tema Harbour Rd, Tema, GA'),
('Ama Owusu', 'ama.owusu@email.com', '+233-24-222-3333', '34 East Legon, Accra, GA'),
('Kwabena Yeboah', 'kwabena.y@email.com', '+233-55-444-5555', '78 Sunyani High St, Sunyani, BA'),
('Adwoa Frimpong', 'adwoa.f@email.com', '+233-20-666-7777', '90 Koforidua Central, Koforidua, ER'),
('Emmanuel Tetteh', 'emmanuel.t@email.com', '+233-27-888-9999', '12 Osu Oxford St, Accra, GA'),
('Grace Addo', 'grace.addo@email.com', '+233-26-000-1111', '45 Tamale Main Rd, Tamale, NR');

-- Insert Products
INSERT INTO products (name, category, price) VALUES
-- Electronics
('Laptop Pro 15', 'Electronics', 1299.99),
('Wireless Mouse', 'Electronics', 29.99),
('USB-C Hub', 'Electronics', 49.99),
('Bluetooth Headphones', 'Electronics', 149.99),
('Smart Watch', 'Electronics', 299.99),
('Tablet 10 inch', 'Electronics', 449.99),
('Wireless Keyboard', 'Electronics', 79.99),
('Monitor 27 inch', 'Electronics', 399.99),
-- Apparel
('Cotton T-Shirt', 'Apparel', 24.99),
('Denim Jeans', 'Apparel', 59.99),
('Winter Jacket', 'Apparel', 129.99),
('Running Shoes', 'Apparel', 89.99),
('Baseball Cap', 'Apparel', 19.99),
('Wool Sweater', 'Apparel', 79.99),
-- Books
('Python Programming Guide', 'Books', 44.99),
('Data Science Handbook', 'Books', 54.99),
('SQL Mastery', 'Books', 39.99),
('Machine Learning Basics', 'Books', 49.99),
('Web Development 101', 'Books', 34.99),
('Cloud Computing Essentials', 'Books', 59.99);

-- Insert Inventory (one record per product)
INSERT INTO inventory (product_id, quantity_on_hand) VALUES
(1, 50), (2, 200), (3, 150), (4, 100), (5, 75),
(6, 60), (7, 120), (8, 40), (9, 300), (10, 250),
(11, 80), (12, 180), (13, 400), (14, 90), (15, 100),
(16, 85), (17, 110), (18, 95), (19, 130), (20, 70);

-- Insert Orders (various dates and statuses)
INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
-- Customer 1 orders
(1, '2025-01-15', 1379.97, 'Delivered'),
(1, '2025-03-20', 179.98, 'Delivered'),
(1, '2025-06-10', 299.99, 'Shipped'),
-- Customer 2 orders
(2, '2025-02-10', 449.99, 'Delivered'),
(2, '2025-04-15', 84.98, 'Delivered'),
(2, '2025-07-01', 129.99, 'Shipped'),
-- Customer 3 orders
(3, '2025-01-25', 1349.98, 'Delivered'),
(3, '2025-05-12', 149.99, 'Delivered'),
-- Customer 4 orders
(4, '2025-03-05', 539.97, 'Delivered'),
(4, '2025-06-20', 89.99, 'Shipped'),
-- Customer 5 orders
(5, '2025-02-28', 1599.97, 'Delivered'),
(5, '2025-04-10', 104.97, 'Delivered'),
-- Customer 6 orders
(6, '2025-01-10', 299.99, 'Delivered'),
(6, '2025-05-25', 459.98, 'Delivered'),
(6, '2025-08-01', 79.99, 'Pending'),
-- Customer 7 orders
(7, '2025-03-15', 749.97, 'Delivered'),
(7, '2025-06-05', 44.99, 'Shipped'),
-- Customer 8 orders
(8, '2025-02-20', 179.98, 'Delivered'),
(8, '2025-07-10', 399.99, 'Pending'),
-- Customer 9 orders
(9, '2025-04-01', 1299.99, 'Delivered'),
(9, '2025-05-30', 114.97, 'Delivered'),
-- Customer 10 orders
(10, '2025-01-20', 449.99, 'Delivered'),
(10, '2025-06-15', 209.97, 'Shipped'),
-- Customer 11 orders
(11, '2025-02-15', 339.98, 'Delivered'),
(11, '2025-04-25', 59.99, 'Delivered'),
-- Customer 12 orders
(12, '2025-03-10', 899.97, 'Delivered'),
(12, '2025-05-20', 149.98, 'Delivered');

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
-- Order 1: Laptop + Mouse + Hub
(1, 1, 1, 1299.99), (1, 2, 1, 29.99), (1, 3, 1, 49.99),
-- Order 2: Headphones + Mouse
(2, 4, 1, 149.99), (2, 2, 1, 29.99),
-- Order 3: Smart Watch
(3, 5, 1, 299.99),
-- Order 4: Tablet
(4, 6, 1, 449.99),
-- Order 5: T-Shirt + Jeans
(5, 9, 2, 24.99), (5, 10, 1, 59.99),
-- Order 6: Winter Jacket
(6, 11, 1, 129.99),
-- Order 7: Laptop + Hub
(7, 1, 1, 1299.99), (7, 3, 1, 49.99),
-- Order 8: Headphones
(8, 4, 1, 149.99),
-- Order 9: Tablet + Running Shoes
(9, 6, 1, 449.99), (9, 12, 1, 89.99),
-- Order 10: Running Shoes
(10, 12, 1, 89.99),
-- Order 11: Laptop + Smart Watch
(11, 1, 1, 1299.99), (11, 5, 1, 299.99),
-- Order 12: Python Book + SQL Book + Data Science Book
(12, 15, 1, 44.99), (12, 17, 1, 39.99), (12, 16, 1, 19.99),
-- Order 13: Smart Watch
(13, 5, 1, 299.99),
-- Order 14: Monitor + Jeans
(14, 8, 1, 399.99), (14, 10, 1, 59.99),
-- Order 15: Keyboard
(15, 7, 1, 79.99),
-- Order 16: Tablet + Smart Watch
(16, 6, 1, 449.99), (16, 5, 1, 299.99),
-- Order 17: Python Book
(17, 15, 1, 44.99),
-- Order 18: Headphones + Mouse
(18, 4, 1, 149.99), (18, 2, 1, 29.99),
-- Order 19: Monitor
(19, 8, 1, 399.99),
-- Order 20: Laptop
(20, 1, 1, 1299.99),
-- Order 21: SQL Book + Python Book + ML Book
(21, 17, 1, 39.99), (21, 15, 1, 44.99), (21, 18, 1, 29.99),
-- Order 22: Tablet
(22, 6, 1, 449.99),
-- Order 23: Sweater + Headphones
(23, 14, 1, 79.99), (23, 4, 1, 149.99),
-- Order 24: Smart Watch + Keyboard
(24, 5, 1, 299.99), (24, 7, 1, 39.99),
-- Order 25: Jeans
(25, 10, 1, 59.99),
-- Order 26: Monitor + Tablet + Hub
(26, 8, 1, 399.99), (26, 6, 1, 449.99), (26, 3, 1, 49.99),
-- Order 27: T-Shirt (3) + Cap (2)
(27, 9, 3, 24.99), (27, 13, 2, 19.99);


-- ============================================
-- SECTION 2: BUSINESS KPIs (Standard SELECT Queries)
-- ============================================

-- -----------------------------------------------
-- KPI 1: Total Revenue
-- Calculate total revenue from all 'Shipped' or 'Delivered' orders
-- -----------------------------------------------
SELECT    
    SUM(total_amount) AS total_revenue
FROM orders
WHERE status IN ('Shipped', 'Delivered');



-- KPI 2: Top 10 Customers by Total Spending
-- Find the top 10 customers showing Customer Name and Total Amount Spent

SELECT 
    c.full_name AS customer_name,
    SUM(o.total_amount) AS total_amount_spent
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.status IN ('Shipped', 'Delivered')
GROUP BY c.id
ORDER BY total_amount_spent DESC
LIMIT 10;



-- KPI 3: Best-Selling Products
-- List the top 5 best-selling products by quantity sold

SELECT 
    p.name AS product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status IN ('Shipped', 'Delivered')
GROUP BY p.id, p.name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 5;


-- KPI 4: Monthly Sales Trend
-- Show total sales revenue for each month

SELECT 
    DATE_FORMAT(order_date, '%M %Y') AS month_name, 
    SUM(total_amount) AS monthly_revenue
FROM orders
WHERE status IN ('Shipped', 'Delivered')
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- SECTION 3: ANALYTICAL QUERIES (Window Functions)


-- -----------------------------------------------
-- Analytical Query 1: Sales Rank by Category
-- For each product category, rank products by total sales revenue
-- -----------------------------------------------
SELECT
    p.category,
    p.name AS product_name,
    SUM(oi.quantity * oi.price_at_purchase) AS total_sales_revenue,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(oi.quantity * oi.price_at_purchase) DESC
    ) AS rank_in_category
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status IN ('Shipped', 'Delivered')
GROUP BY p.category, p.id
ORDER BY p.category, rank_in_category;



-- Analytical Query 2: Customer Order Frequency
-- Show customers with the date of their previous order alongside their current order

SELECT 
    c.full_name AS customer_name,
    o.id AS order_id,
    o.order_date AS current_order_date,
    LAG(o.order_date) OVER (
        PARTITION BY c.id 
        ORDER BY o.order_date
    ) AS previous_order_date,
    DATEDIFF(o.order_date, LAG(o.order_date) OVER (
        PARTITION BY c.id 
        ORDER BY o.order_date
    )) AS days_since_last_order
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
ORDER BY c.full_name, o.order_date;


-- ============================================
-- SECTION 4: PERFORMANCE OPTIMIZATION
-- ============================================

-- -----------------------------------------------
-- View: CustomerSalesSummary
-- Pre-calculates total amount spent by each customer for simplified analytics
-- -----------------------------------------------
CREATE OR REPLACE VIEW CustomerSalesSummary AS
SELECT 
    c.id AS customer_id,
    c.full_name AS customer_name,
    c.email,
    COUNT(DISTINCT o.id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_amount_spent,
    COALESCE(AVG(o.total_amount), 0) AS average_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id 
    AND o.status IN ('Shipped', 'Delivered')
GROUP BY c.id, c.full_name, c.email;

-- Example usage of the view:
-- SELECT * FROM CustomerSalesSummary ORDER BY total_amount_spent DESC;


-- -----------------------------------------------
-- Stored Procedure: ProcessNewOrder
-- Takes a customer ID and a JSON array of items like:
-- '[{"product_id": 1, "quantity": 2}, {"product_id": 3, "quantity": 1}]'
-- 
-- What it does:
-- - Checks customer exists, validates stock for all items
-- - Creates the order and deducts inventory
-- - Logs everything to inventory_logs
-- - Rolls back if anything goes wrong
-- -----------------------------------------------
DROP PROCEDURE IF EXISTS ProcessNewOrder;

DELIMITER //

CREATE PROCEDURE ProcessNewOrder(
    IN p_customer_id INT,
    IN p_order_items JSON
)
BEGIN
    DECLARE v_new_order_id INT;
    DECLARE v_total_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_item_count INT;
    DECLARE v_current_index INT DEFAULT 0;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_product_price DECIMAL(10,2);
    DECLARE v_product_name VARCHAR(255);
    DECLARE v_available_stock INT;
    DECLARE v_item_total DECIMAL(10,2);
    
    -- If anything fails, roll back and re-throw the error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Make sure this customer actually exists
    IF NOT EXISTS (SELECT 1 FROM customers WHERE id = p_customer_id) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;
    
    -- How many items are we processing?
    SET v_item_count = JSON_LENGTH(p_order_items);
    
    IF v_item_count = 0 OR v_item_count IS NULL THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Order items array is empty or invalid';
    END IF;
    
    -- Loop through items first to validate everything before making changes
    WHILE v_current_index < v_item_count DO
        -- Pull out this item's product_id and quantity
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_current_index, '].product_id')));
        SET v_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_current_index, '].quantity')));
        
        -- Can't order zero or negative quantities
        IF v_quantity IS NULL OR v_quantity <= 0 THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Invalid quantity: must be a positive integer';
        END IF;
        
        -- Make sure the product is real
        IF NOT EXISTS (SELECT 1 FROM products WHERE id = v_product_id) THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'One or more products do not exist';
        END IF;
        
        -- Grab the product's name and price
        SELECT name, price INTO v_product_name, v_product_price
        FROM products 
        WHERE id = v_product_id;
        
        -- Lock this inventory row so nobody else can modify it mid-transaction)
        SELECT quantity_on_hand INTO v_available_stock
        FROM inventory 
        WHERE product_id = v_product_id
        FOR UPDATE;
        
        IF v_available_stock IS NULL THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'No inventory record found for one or more products';
        END IF;
        
        -- Do we have enough in stock?
        IF v_available_stock < v_quantity THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Insufficient stock for one or more products';
        END IF;
        
        -- Running total
        SET v_total_amount = v_total_amount + (v_product_price * v_quantity);
        
        SET v_current_index = v_current_index + 1;
    END WHILE;
    
    -- All validated! Now create the order
    INSERT INTO orders (customer_id, order_date, total_amount, status)
    VALUES (p_customer_id, CURDATE(), v_total_amount, 'Pending');
    
    -- Grab the ID of the order we just created
    SET v_new_order_id = LAST_INSERT_ID();
    
    -- Record that we created this order
    INSERT INTO inventory_logs (log_type, order_id, customer_id, message)
    VALUES ('ORDER_CREATED', v_new_order_id, p_customer_id, 
            CONCAT('New order #', v_new_order_id, ' created with ', v_item_count, ' item(s), total: $', v_total_amount));
    
    -- Now actually process each item - deduct stock and create order_items
    SET v_current_index = 0;
    WHILE v_current_index < v_item_count DO
        -- Get this item's details again
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_current_index, '].product_id')));
        SET v_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_current_index, '].quantity')));
        
        -- Get product price
        SELECT price INTO v_product_price FROM products WHERE id = v_product_id;
        
        -- Deduct from inventory (this fires our logging trigger automatically)
        UPDATE inventory 
        SET quantity_on_hand = quantity_on_hand - v_quantity,
            last_updated = CURRENT_TIMESTAMP
        WHERE product_id = v_product_id;
        
        -- Add the line item to the order
        INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
        VALUES (v_new_order_id, v_product_id, v_quantity, v_product_price);
        
        -- Log that we added this item
        INSERT INTO inventory_logs (log_type, product_id, order_id, customer_id, quantity_changed, message)
        VALUES ('ORDER_ITEM_ADDED', v_product_id, v_new_order_id, p_customer_id, v_quantity,
                CONCAT('Added ', v_quantity, ' unit(s) of product #', v_product_id, ' to order #', v_new_order_id));
        
        SET v_current_index = v_current_index + 1;
    END WHILE;
    
    -- Commit transaction
    COMMIT;
    
    -- All done - send back the order summary
    SELECT 
        v_new_order_id AS order_id,
        v_item_count AS items_count,
        v_total_amount AS total_amount,
        'Order successfully created!' AS message;
    
END //

DELIMITER ;


-- ============================================
-- USAGE EXAMPLES FOR STORED PROCEDURE
-- ============================================

-- Example 1: Single product order (uncomment to run)
# CALL ProcessNewOrder(1, '[{"product_id": 2, "quantity": 5}]');  -- Customer 1 orders 5 Wireless Mice

-- Example 2: Multiple products in one order (uncomment to run)
# CALL ProcessNewOrder(1, '[{"product_id": 2, "quantity": 2}, {"product_id": 3, "quantity": 1}, {"product_id": 4, "quantity": 1}]');

-- Example 3: This would fail due to insufficient stock (uncomment to test)
# CALL ProcessNewOrder(1, '[{"product_id": 1, "quantity": 1000}]');  -- Attempting to order 1000 laptops

-- Example 4: This would fail due to invalid customer (uncomment to test)
# CALL ProcessNewOrder(999, '[{"product_id": 1, "quantity": 1}]');  -- Invalid customer ID

-- View recent inventory logs
# SELECT * FROM inventory_logs ORDER BY id DESC LIMIT 20;


-- ============================================
-- BONUS: Additional Useful Queries
-- ============================================

-- -----------------------------------------------
-- Low Stock Alert: Products with inventory below threshold
-- -----------------------------------------------
SELECT 
    p.name AS product_name,
    p.category,
    i.quantity_on_hand AS current_stock,
    CASE 
        WHEN i.quantity_on_hand < 50 THEN 'Critical'
        WHEN i.quantity_on_hand < 100 THEN 'Low'
        ELSE 'Adequate'
    END AS stock_status
FROM products p
INNER JOIN inventory i ON p.id = i.product_id
WHERE i.quantity_on_hand < 100
ORDER BY i.quantity_on_hand;


-- Revenue by Category----------------------------

-- -----------------------------------------------
SELECT 
    p.category,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items_sold
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status IN ('Shipped', 'Delivered')
GROUP BY p.category
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- Order Status Summary
-- -----------------------------------------------
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_value
FROM orders
GROUP BY status
ORDER BY order_count DESC;
