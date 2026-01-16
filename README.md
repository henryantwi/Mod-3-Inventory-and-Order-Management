# Inventory and Order Management System

A comprehensive MySQL database solution for an e-commerce company's inventory and order management system. This project demonstrates database design, schema implementation (DDL), and advanced SQL querying (DML) to solve realistic business problems.

## Table of Contents

- [Project Overview](#project-overview)
- [Database Design](#database-design)
- [Schema Implementation](#schema-implementation)
- [KPI Queries & Analytics](#kpi-queries--analytics)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Usage Examples](#usage-examples)

---

## Project Overview

This project is a capstone for the SQL module, covering the complete database lifecycle from design to analysis. It includes:

- **Database Design**: Normalized relational schema (3NF) based on business requirements
- **Schema Implementation**: DDL scripts with tables, relationships, and constraints
- **Advanced Querying**: Complex SQL queries including joins, aggregations, window functions, and stored procedures
- **Performance Optimization**: Views and stored procedures for reusable, performant query logic

---

## Database Design

### Entity-Relationship Diagram

The database consists of 6 interconnected tables following a normalized design:



### Relationships

| Relationship | Type | Description |
|-------------|------|-------------|
| Customers → Orders | One-to-Many | A customer can place many orders |
| Orders → Order Items | One-to-Many | An order can contain multiple items |
| Products → Order Items | One-to-Many | A product can appear in multiple order items |
| Products → Inventory | One-to-One | Each product has one inventory record |
| Inventory → Inventory Logs | One-to-Many | Inventory changes are logged automatically via triggers |

---

## Schema Implementation

### Tables Created

#### 1. Customers Table
```sql
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. Products Table
```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_product_price CHECK (price >= 0)
);
```

#### 3. Inventory Table
```sql
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    quantity_on_hand INT NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_inventory_quantity CHECK (quantity_on_hand >= 0)
);
```

#### 4. Orders Table
```sql
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_order_status CHECK (status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT chk_order_total CHECK (total_amount >= 0)
);
```

#### 5. Order Items Table (Bridge Table)
```sql
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (price_at_purchase >= 0)
);
```

#### 6. Inventory Logs Table (Audit Table)
```sql
CREATE TABLE inventory_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_type VARCHAR(50) NOT NULL,
    product_id INT,
    order_id INT,
    customer_id INT,
    quantity_changed INT,
    old_quantity INT,
    new_quantity INT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### SQL Triggers

| Trigger | Event | Description |
|---------|-------|-------------|
| `trg_inventory_update_log` | AFTER UPDATE on inventory | Automatically logs all inventory quantity changes |

### Data Integrity Features

| Feature | Implementation |
|---------|---------------|
| **Primary Keys** | AUTO_INCREMENT on all ID fields |
| **Foreign Keys** | ON DELETE CASCADE for referential integrity |
| **NOT NULL** | Required fields: full_name, email, product name, order_date |
| **UNIQUE** | Customer email, inventory product_id |
| **CHECK Constraints** | Non-negative prices, quantities; valid order status |

### Performance Indexes

```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);
```

---

## KPI Queries & Analytics

### Business KPIs

#### KPI 1: Total Revenue
Calculates total revenue from all 'Shipped' or 'Delivered' orders.
```sql
SELECT SUM(total_amount) AS total_revenue
FROM orders
WHERE status IN ('Shipped', 'Delivered');
```

#### KPI 2: Top 10 Customers by Spending
```sql
SELECT 
    c.full_name AS customer_name,
    SUM(o.total_amount) AS total_amount_spent
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.status IN ('Shipped', 'Delivered')
GROUP BY c.id, c.full_name
ORDER BY total_amount_spent DESC
LIMIT 10;
```

#### KPI 3: Best-Selling Products
```sql
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
```

#### KPI 4: Monthly Sales Trend
```sql
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    DATE_FORMAT(order_date, '%M %Y') AS month_name,
    SUM(total_amount) AS monthly_revenue,
    COUNT(*) AS total_orders
FROM orders
WHERE status IN ('Shipped', 'Delivered')
GROUP BY DATE_FORMAT(order_date, '%Y-%m'), DATE_FORMAT(order_date, '%M %Y')
ORDER BY month;
```

### Analytical Queries (Window Functions)

#### Sales Rank by Category
Uses `RANK() OVER (PARTITION BY...)` to rank products within each category by revenue.
```sql
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
GROUP BY p.category, p.id, p.name
ORDER BY p.category, rank_in_category;
```

#### Customer Order Frequency
Uses `LAG()` window function to show previous order dates alongside current orders.
```sql
SELECT 
    c.full_name AS customer_name,
    o.id AS order_id,
    o.order_date AS current_order_date,
    LAG(o.order_date) OVER (PARTITION BY c.id ORDER BY o.order_date) AS previous_order_date,
    DATEDIFF(o.order_date, LAG(o.order_date) OVER (PARTITION BY c.id ORDER BY o.order_date)) AS days_since_last_order
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
ORDER BY c.full_name, o.order_date;
```

### Performance Optimization

#### CustomerSalesSummary View
Pre-calculates customer analytics for simplified reporting.
```sql
CREATE VIEW CustomerSalesSummary AS
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
```

#### ProcessNewOrder Stored Procedure
Handles bulk order creation with JSON array input and transaction management:
- ✅ Accepts multiple products via JSON array
- ✅ Uses `IF EXISTS` for efficient customer validation
- ✅ Validates all products exist and have sufficient stock
- ✅ Updates inventory on success (triggers automatic logging)
- ✅ Creates order and order items
- ✅ Logs all actions to `inventory_logs` table
- ❌ Rolls back entire transaction on any failure

**JSON Input Format:**
```json
[{"product_id": 1, "quantity": 2}, {"product_id": 3, "quantity": 1}]
```

**Examples:**
```sql
-- Single product order
CALL ProcessNewOrder(1, '[{"product_id": 2, "quantity": 5}]');

-- Multiple products in one order
CALL ProcessNewOrder(1, '[{"product_id": 2, "quantity": 2}, {"product_id": 3, "quantity": 1}]');
```

---

## Getting Started

### Prerequisites

- Docker and Docker Compose
- MySQL client (optional, for direct access)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/henryantwi/Mod-3-Inventory-and-Order-Management.git
   cd Inventory_and_Order_Management_System
   ```

2. **Start the database services**
   ```bash
   docker-compose up -d
   ```

3. **Access phpMyAdmin**
   - URL: http://localhost:8080
   - Server: mysql
   - Username: inventory_user
   - Password: inventory_pass

4. **Run the SQL scripts**
   - Execute `src/ddl_schema.sql` to create tables
   - Execute `src/dml_queries.sql` to insert sample data and create views/procedures

### Environment Variables

You can customize the database configuration:

| Variable | Default | Description |
|----------|---------|-------------|
| MYSQL_ROOT_PASSWORD | rootpassword | MySQL root password |
| MYSQL_DATABASE | inventory_db | Database name |
| MYSQL_USER | inventory_user | Application user |
| MYSQL_PASSWORD | inventory_pass | Application password |

---

## Project Structure

```
Inventory_and_Order_Management_System/
├── docker-compose.yml      # MySQL & phpMyAdmin container setup
├── .gitignore              # Git ignore patterns
├── README.md               # Project documentation
└── src/
    ├── ddl_schema.sql      # Database schema (CREATE TABLE statements)
    └── dml_queries.sql     # Sample data, queries, views & stored procedures
```

---

## Usage Examples

### Query the CustomerSalesSummary View
```sql
SELECT * FROM CustomerSalesSummary 
ORDER BY total_amount_spent DESC 
LIMIT 5;
```

### Process a New Order (Bulk Orders Supported)
```sql
-- Single product order
CALL ProcessNewOrder(1, '[{"product_id": 2, "quantity": 5}]');

-- Multiple products in one order
CALL ProcessNewOrder(1, '[{"product_id": 2, "quantity": 2}, {"product_id": 3, "quantity": 1}, {"product_id": 4, "quantity": 1}]');

-- This will fail (insufficient stock)
CALL ProcessNewOrder(1, '[{"product_id": 1, "quantity": 1000}]');

-- This will fail (invalid customer)
CALL ProcessNewOrder(999, '[{"product_id": 1, "quantity": 1}]');
```

### View Inventory Logs
```sql
-- View recent inventory changes
SELECT * FROM inventory_logs ORDER BY id DESC LIMIT 10;

-- View logs for a specific order
SELECT * FROM inventory_logs WHERE order_id = 28;
```

### Check Low Stock Alerts
```sql
SELECT 
    p.name AS product_name,
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
```

---

## Sample Data Overview

| Entity | Count | Description |
|--------|-------|-------------|
| Customers | 12 | Ghanaian customers with various addresses |
| Products | 20 | Electronics (8), Apparel (6), Books (6) |
| Inventory | 20 | Stock records for all products |
| Orders | 27 | Various statuses: Pending, Shipped, Delivered |
| Order Items | 45+ | Product-order associations |
| Inventory Logs | Dynamic | Audit trail of inventory changes |

---

## Technologies Used

- **Database**: MySQL 8.0
- **Administration**: phpMyAdmin
- **Containerization**: Docker & Docker Compose
- **Version Control**: Git

---

## License

This project is part of a data engineering educational module.
