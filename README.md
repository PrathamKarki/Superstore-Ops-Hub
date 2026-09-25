# Superstore Ops Hub

Oracle PL/SQL retail operations system built from the Tableau Superstore dataset.

The project demonstrates how a retail sales feed can be loaded into Oracle staging, merged into business tables, used to update inventory, and analyzed using sql and pl/sql

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
INVENTORY
 ↓
PRC_APPLY_STOCK
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

The procedure:

- Finds order items where STOCK_APPLIED_FLAG = 'N'
- Groups sales quantities by product
- Checks the available inventory
- Subtracts the sold quantity from inventory
- Changes the processed order items to STOCK_APPLIED_FLAG = 'Y'

The procedure processes only order items where:
```text
STOCK_APPLIED_FLAG = 'N'
```
after processing, the flag changes to:
```text
STOCK_APPLIED_FLAG = 'Y'
```


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
Seed INVENTORY
   ↓
PRC_APPLY_STOCK
   ↓
INVENTORY
   ↓
REPORTS & ANALYTICS
```

## Idempotency

The project demonstrates idempotent processing at multiple stages.

For example, running `PRC_MERGE_SALES` again:

- Updates existing customers/products/orders
- Does not duplicate existing order items
- Does not duplicate return records

`PRC_APPLY_STOCK` processes only order items whose `STOCK_APPLIED_FLAG = 'N'`.

After processing, those order items are marked as 
`STOCK_APPLIED_FLAG = 'Y'`, preventing the same sale from reducing inventory again.


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
│   ├── 05_demo/
│
├── docs/
│
├── README.md
│
└── .gitignore
```

## Reports & Analytics
The project contains five analytical reports:

- Sales and profit by category
- Top 10 products by sales and profit
- Monthly sales and profit trends
- Customer Gold/Silver/Bronze segmentation
- Monthly category sales ranking


The reports uses Oracle SQL features including:

- CTEs
- Aggregations
- Joins
- Subqueries
- Window functions
- Ranking
- PL/SQL functions 

## Project Goals

This project demonstrates practical Oracle SQL and PL/SQL concepts through a retail operations workflow.

Key concepts include:

- Staging tables
- Data validation
- `MERGE`
- Primary and foreign keys
- Constraints
- Stored Procedures
- PL/SQL functions
- Explicit cursors
- Exception handling
- Idempotent processing
- Inventory processing
- CTEs
- Window functions
- Analytical SQL