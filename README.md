# Superstore Ops Hub

Oracle PL/SQL retail operations system built from the Tableau Superstore dataset.

The project demonstrates how a retail sales feed can be loaded into Oracle staging, merged into business tables, used to update inventory, and automatically generate reorder requests.

## Architecture

```text
CSV
 ↓
STG_SUPERSTORE
 ↓
PRC_MERGE_SALES
 ↓
CUSTOMERS
PRODUCTS
ORDERS
ORDER_ITEMS
RETURNS
 ↓
PRC_APPLY_STOCK
 ↓
INVENTORY
 ↓
PRC_GENERATE_REORDER
 ↓
REORDER_REQUESTS
 ↓
REPORTS & ANALYTICS
```

## Dataset

The project uses approximately about 2,000-row subset of the Tableau Sample Superstore dataset.

The CSV is loaded into the staging table before the PL/SQL processing begins.

```text
data/
└── stg_superstore_2k.csv
```

## Database Structure

### Staging

- `STG_SUPERSTORE`

Used as the landing area for incoming sales data.

### Business Tables

- `CUSTOMERS`
- `PRODUCTS`
- `ORDERS`
- `ORDER_ITEMS`
- `RETURNS`

### Operations Tables

- `INVENTORY`
- `REORDER_REQUESTS`

## PL/SQL Components

### `PRC_MERGE_SALES`

Master sales-load procedure.

Loads and synchronizes data from `STG_SUPERSTORE` into:

1. `CUSTOMERS`
2. `PRODUCTS`
3. `ORDERS`
4. `ORDER_ITEMS`
5. `RETURNS`

The procedure uses `MERGE` statements so the same staging feed can be processed again without creating duplicate master/transaction records.

### `PRC_APPLY_STOCK`

Applies unprocessed order quantities to inventory.

Uses `STOCK_APPLIED_FLAG` on `ORDER_ITEMS` to prevent the same sale from reducing inventory more than once.

### `FN_REORDER_QTY`

Calculates the quantity required to restore inventory to the target stock level.

```text
Reorder Quantity = Target Stock - Current Stock
```

The current target stock is 100 units.

### `PRC_GENERATE_REORDER`

Checks inventory levels against reorder points.

For products at or below the reorder point, the procedure:

- Calculates reorder quantity
- Determines reorder priority
- Creates an `OPEN` reorder request
- Skips products that already have an `OPEN` request

This prevents duplicate open reorder requests.

## Data Flow

The main operational flow is:

```text
Sales CSV
   ↓
STG_SUPERSTORE
   ↓
PRC_MERGE_SALES
   ↓
Business Tables
   ↓
PRC_APPLY_STOCK
   ↓
INVENTORY
   ↓
PRC_GENERATE_REORDER
   ↓
REORDER_REQUESTS
```

## Idempotency

The project demonstrates idempotent processing at multiple stages.

For example, running `PRC_MERGE_SALES` again:

- Updates existing customers/products/orders
- Does not duplicate existing order items
- Does not duplicate return records

`PRC_APPLY_STOCK` processes only order items whose `STOCK_APPLIED_FLAG = 'N'`.

`PRC_GENERATE_REORDER` checks for an existing `OPEN` request before creating another one.

## Project Structure

```text
Superstore-Ops-Hub/
│
├── data/
│   └── stg_superstore_2k.csv
│
├── sql/
│   ├── 01_schema/
│   ├── 02_load/
│   ├── 03_plsql/
│   ├── 04_reports/
│   
│
├── docs/
│
├── README.md
│
└── .gitignore
```

## Reports & Analytics

The reporting layer  provides business insights such as:

- Sales and profit by category
- Top 10 products by sales and profit
- Monthly sales and profit trends
- Customer Gold/Silver/Bronze segmentation
- Monthly category sales ranking
- Inventory and reorder monitoring

The reports  uses Oracle SQL features including:

- CTEs
- Aggregations
- Joins
- Subqueries
- Window functions
- Ranking
- PL/SQL functions where appropriate

## Project Goals

This project demonstrates practical Oracle SQL and PL/SQL concepts through a retail operations workflow.

Key concepts include:

- Staging tables
- `MERGE`
- Primary and foreign keys
- Constraints
- Procedures
- Functions
- Explicit cursors
- Exception handling
- Idempotent processing
- Inventory processing
- Reorder automation
- CTEs
- Window functions
- Analytical SQL