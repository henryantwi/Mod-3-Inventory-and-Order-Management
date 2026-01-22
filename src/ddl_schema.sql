-- ============================================
-- Inventory and Order Management System
-- DDL Script - Schema Implementation (MySQL Version)
-- ============================================

-- Drop tables if they exist (for clean re-runs)
-- Note: Must drop in reverse order of dependencies due to foreign keys
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- ============================================
-- CUSTOMERS TABLE
-- ============================================
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================
-- PRODUCTS TABLE
-- ============================================
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- CHECK constraint: Price must be non-negative (MySQL 8.0.16+)
    CONSTRAINT chk_product_price CHECK (price >= 0)
) ENGINE=InnoDB;

-- ============================================
-- INVENTORY TABLE
-- ============================================
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    quantity_on_hand INT NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- CHECK constraint: Quantity must be non-negative
    CONSTRAINT chk_inventory_quantity CHECK (quantity_on_hand >= 0)
) ENGINE=InnoDB;

-- ============================================
-- ORDERS TABLE
-- ============================================
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- CHECK constraint: Status must be valid
    CONSTRAINT chk_order_status CHECK (status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    -- CHECK constraint: Total amount must be non-negative
    CONSTRAINT chk_order_total CHECK (total_amount >= 0)
) ENGINE=InnoDB;

-- ============================================
-- ORDER_ITEMS TABLE (Bridge Table)
-- ============================================
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10,2) NOT NULL,
    -- CHECK constraint: Quantity must be positive
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    -- CHECK constraint: Price must be non-negative
    CONSTRAINT chk_order_item_price CHECK (price_at_purchase >= 0)
) ENGINE=InnoDB;


-- ============================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================

-- Inventory -> Products
ALTER TABLE inventory
    ADD CONSTRAINT fk_inventory_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE;

-- Orders -> Customers
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers (id)
    ON DELETE CASCADE;

-- Order Items -> Orders
ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE CASCADE;

-- Order Items -> Products
ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE CASCADE;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);

-- ============================================
-- INVENTORY_LOGS TABLE
-- This table keeps a history of all inventory changes
-- ============================================
DROP TABLE IF EXISTS inventory_logs;

CREATE TABLE inventory_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_type ENUM(
        'ORDER_CREATED',
        'ORDER_ITEM_ADDED',
        'ORDER_STATUS_CHANGED',
        'INVENTORY_UPDATED',
        'STOCK_DEDUCTED',
        'STOCK_RESTORED',
        'STOCK_RESTOCKED',
        'PRODUCT_ADDED'
    ) NOT NULL,
    product_id INT,
    order_id INT,
    customer_id INT,
    quantity_changed INT,
    old_quantity INT,
    new_quantity INT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- These foreign keys are optional - we allow NULLs so logs aren't deleted
-- if the related record is removed
ALTER TABLE inventory_logs
    ADD CONSTRAINT fk_inventory_logs_product
    FOREIGN KEY (product_id) REFERENCES products (id)
    ON DELETE SET NULL;

ALTER TABLE inventory_logs
    ADD CONSTRAINT fk_inventory_logs_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON DELETE SET NULL;

ALTER TABLE inventory_logs
    ADD CONSTRAINT fk_inventory_logs_customer
    FOREIGN KEY (customer_id) REFERENCES customers (id)
    ON DELETE SET NULL;

-- Speed up log lookups
CREATE INDEX idx_inventory_logs_product_id ON inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_created_at ON inventory_logs(created_at);

-- ============================================
-- TRIGGER: Auto-log inventory changes
-- ============================================

-- Clean up any old version first
DROP TRIGGER IF EXISTS trg_inventory_update_log;

DELIMITER //

-- Whenever inventory quantities change, this trigger captures the before/after values
-- Uses session variables to determine the context of the change:
-- @inventory_context = 'ORDER_DEDUCTION' -> STOCK_DEDUCTED
-- @inventory_context = 'ORDER_RESTORATION' -> STOCK_RESTORED
-- @inventory_context = 'MANUAL_RESTOCK' -> STOCK_RESTOCKED
-- NULL/other -> INVENTORY_UPDATED
CREATE TRIGGER trg_inventory_update_log
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    DECLARE v_log_type VARCHAR(50);
    DECLARE v_message TEXT;
    
    -- Determine log type based on context
    SET v_log_type = CASE @inventory_context
        WHEN 'ORDER_DEDUCTION' THEN 'STOCK_DEDUCTED'
        WHEN 'ORDER_RESTORATION' THEN 'STOCK_RESTORED'
        WHEN 'MANUAL_RESTOCK' THEN 'STOCK_RESTOCKED'
        ELSE 'INVENTORY_UPDATED'
    END;
    
    -- Build appropriate message based on context
    SET v_message = CASE @inventory_context
        WHEN 'ORDER_DEDUCTION' THEN CONCAT('Deducted ', OLD.quantity_on_hand - NEW.quantity_on_hand, ' unit(s) for order #', IFNULL(@current_order_id, 'N/A'), ', stock: ', OLD.quantity_on_hand, ' -> ', NEW.quantity_on_hand)
        WHEN 'ORDER_RESTORATION' THEN CONCAT('Restored ', NEW.quantity_on_hand - OLD.quantity_on_hand, ' unit(s) from cancelled order #', IFNULL(@current_order_id, 'N/A'), ', stock: ', OLD.quantity_on_hand, ' -> ', NEW.quantity_on_hand)
        WHEN 'MANUAL_RESTOCK' THEN CONCAT('Restocked ', NEW.quantity_on_hand - OLD.quantity_on_hand, ' unit(s), stock: ', OLD.quantity_on_hand, ' -> ', NEW.quantity_on_hand)
        ELSE CONCAT('Inventory changed from ', OLD.quantity_on_hand, ' to ', NEW.quantity_on_hand)
    END;
    
    INSERT INTO inventory_logs (log_type, product_id, order_id, customer_id, quantity_changed, old_quantity, new_quantity, message)
    VALUES (
        v_log_type, 
        NEW.product_id,
        @current_order_id,
        @current_customer_id,
        OLD.quantity_on_hand - NEW.quantity_on_hand, 
        OLD.quantity_on_hand, 
        NEW.quantity_on_hand, 
        v_message
    );
END //

-- When an order's status changes, log the transition
CREATE TRIGGER trg_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO inventory_logs (log_type, order_id, customer_id, message)
        VALUES (
            'ORDER_STATUS_CHANGED',
            NEW.id,
            NEW.customer_id,
            CONCAT('Order #', NEW.id, ' status changed: ', OLD.status, ' -> ', NEW.status)
        );
    END IF;
END //

-- When a new product is added, automatically create an inventory record with 0 stock
CREATE TRIGGER trg_auto_create_inventory
AFTER INSERT ON products
FOR EACH ROW
BEGIN
    INSERT INTO inventory (product_id, quantity_on_hand)
    VALUES (NEW.id, 0);
    
    INSERT INTO inventory_logs (log_type, product_id, new_quantity, message)
    VALUES (
        'PRODUCT_ADDED',
        NEW.id,
        0,
        CONCAT('New product "', NEW.name, '" added, inventory initialized to 0')
    );
END //

-- When a new order is created, log it automatically
DROP TRIGGER IF EXISTS trg_order_created //

CREATE TRIGGER trg_order_created
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO inventory_logs (log_type, order_id, customer_id, message)
    VALUES (
        'ORDER_CREATED',
        NEW.id,
        NEW.customer_id,
        CONCAT('New order #', NEW.id, ' created, total: $', NEW.total_amount)
    );
END //

-- When an order item is added, log it automatically
DROP TRIGGER IF EXISTS trg_order_item_added //

CREATE TRIGGER trg_order_item_added
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    INSERT INTO inventory_logs (log_type, product_id, order_id, customer_id, quantity_changed, message)
    VALUES (
        'ORDER_ITEM_ADDED',
        NEW.product_id,
        NEW.order_id,
        @current_customer_id,
        NEW.quantity,
        CONCAT('Added ', NEW.quantity, ' unit(s) of product #', NEW.product_id, ' to order #', NEW.order_id)
    );
END //

DELIMITER ;

