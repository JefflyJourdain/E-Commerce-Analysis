# 🛒 E-Commerce Operations Analytics — ETL Pipeline & Dashboard

> **Status:** ✅ Completed — Live on Power BI Service with daily scheduled refresh

An end-to-end data analytics project built on a synthetic e-commerce operations dataset. The project covers a full modern data stack: a **Python ETL pipeline** extracting data via the Kaggle API and loading directly into **Azure SQL**, advanced **T-SQL** data cleaning and modelling, and a **Power BI** executive dashboard with live cloud deployment.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Dataset](#dataset)
- [ETL Pipeline](#etl-pipeline)
- [SQL — Data Cleaning & Modelling](#sql--data-cleaning--modelling)
- [Power BI Dashboard](#power-bi-dashboard)
- [Key Findings](#key-findings)
- [Project Structure](#project-structure)

---

## Project Overview

This project analyzes the operational and financial performance of a multi-channel e-commerce business, covering revenue, margin, return rates, and channel behaviour across product categories and customer segments. The goal was to build a production-grade analytics pipeline, from raw data ingestion to a live, refreshing dashboard, rather than a static one-time analysis.


**Business Questions addressed:**
- Which product categories and subcategories drive the most revenue vs. the most margin?
- How do B2B, Wholesale, and B2C channels compare in AOV and profitability?
- Where is margin being lost — pricing, discounting, or product mix?
- Which subcategories have anomalous return rates, and where is revenue concentrated?
<img width="551" height="342" alt="{DAE7E42C-1959-41BB-AF7D-0A4FCF2BACE8}" src="https://github.com/user-attachments/assets/be83e481-5de5-451b-a76b-38a28a7c7f79" />

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| **Python** | ETL pipeline — Kaggle API extraction, Azure SQL load |
| **Azure SQL** | Cloud data warehouse (dev + production databases) |
| **Azure Blob Storage** | Raw data landing zone |
| **T-SQL** | Advanced data cleaning, view creation, star schema modelling |
| **Power BI Desktop** | Dashboard development with parameter-driven environment switching |
| **Power BI Service** | Live deployment with daily scheduled refresh |

---

## Dataset

The source is a synthetic e-commerce operations dataset with **~100,000 rows** of transactional data covering orders, products, customers, returns, inventory, and financials across multiple sales channels and geographies.

| Table | Description |
|-------|-------------|
| `ecommerce_raw` | Raw ingested table — single source of truth |
| `FactSales` | Cleaned fact table view — orders, revenue, margin, discounts |
| `DimProduct` | Product dimension — category, subcategory (cleaned) |
| `DimCustomer` | Customer dimension — segment, region |
| `DimGeography` | Geography dimension — region, country |

---

## ETL Pipeline

The pipeline was built in Python and runs end-to-end from data extraction to cloud load with no manual steps.

### Architecture

```
Kaggle API → Python (pandas) → Azure SQL (raw table) → SQL views → Power BI
```

### Key Implementation Details

- **Extraction** via `kagglehub` using `KaggleDatasetAdapter.PANDAS` — loads directly into a DataFrame without intermediate file storage
- **Load** via `SQLAlchemy` + `pyodbc` with ODBC Driver 18 for SQL Server, using batch inserts (`chunksize=500`, `method="multi"`) for performance
- **Dual database setup** — separate development and production Azure SQL databases on the same server, with Power BI switching between them via a parameter
- **Credentials** managed via environment variables — no hardcoded secrets in the codebase
- **Scheduled refresh** configured in Power BI Service — dashboard updates daily from production database

---

## SQL — Data Cleaning & Modelling

The raw table required significant cleaning before it could support reliable analysis. All transformations were applied in T-SQL on top of `ecommerce_raw`.

### Cleaning Operations

- **Mixed date format parsing** — `order_date`, `ship_date`, and `delivery_date` stored in inconsistent formats (MM/DD/YYYY, DD/MM/YYYY, ISO, long-form text). Resolved using `TRY_CONVERT` with multiple format codes inside `COALESCE`, returning the first successful parse
- **Percentage column normalisation** — `gross_margin_pct` and `discount_pct` stored as mixed strings (`"73%"`, `"0.73"`, `"73"`). Cleaned via `REPLACE` + `CAST` to `DECIMAL`, then normalised with a `CASE` expression dividing values `> 1` by 100
- **Subcategory imputation** — null subcategory values filled using keyword matching on `product_name` via `CASE WHEN LOWER(product_name) LIKE '%cookware%'` pattern, wrapped in `COALESCE` to preserve existing values
- **Return flag standardisation** — mixed boolean representations (`Y`, `Yes`, `true`, `1`) unified to a consistent binary flag
- **Payment method consolidation** — card brand variants (`Visa`, `Mastercard`, `CC`) collapsed into a single `Credit Card` category
- **Column type enforcement** — `ALTER TABLE` used to enforce `DECIMAL(10,2)` on numeric columns after string cleaning

### SQL Techniques Used

- **CTEs** — multi-step transformations broken into readable named stages
- **Window functions** — `ROW_NUMBER()` for deduplication, ranking across partitions
- **Subqueries** — inline transformations nested within larger SELECT statements
- **`TRY_CONVERT` / `TRY_CAST`** — safe casting to prevent runtime errors on dirty data
- **`COALESCE`** — fallback chains for null handling across multiple expressions
- **`CASE` expressions** — conditional logic for categorisation, normalisation, and flag standardisation

### Views

All cleaned logic is encapsulated in views, keeping `ecommerce_raw` intact as a replayable source:

| View | Purpose |
|------|---------|
| `FactSales` | Core transactional fact table with cleaned dates, margins, and flags |
| `DimProduct` | Product attributes with imputed subcategories |
| `DimCustomer` | Customer segment and geography |
| `DimGeography` | Region and country reference |

---

## Power BI Dashboard

A single-page executive dashboard deployed live on Power BI Service.

**Features:**
- **Environment parameter** — switches data source between development and production Azure SQL databases without modifying the report
- **Daily scheduled refresh** on Power BI Service — always reflects latest data
- Cross-filtering across category, channel, region, and time dimensions

**KPIs covered:**
- Revenue, gross profit, and gross margin % by category and subcategory
- AOV and order volume by sales channel (B2B, Wholesale, B2C, Amazon, Shopify)
- Return rate by subcategory
- Discount rate distribution across the catalogue

---

## Key Findings

### Category & Subcategory Margin

- **Kitchen is the highest-margin category** despite not leading revenue. Cookware (60%), Utensils (55%), and Cutlery (54%) form the tightest, most consistent margin band in the entire dataset — no subcategory is underperforming
- **Office leads revenue by a wide margin but sits at 53% category margin** — driven down by Office Accessories at 47%, the worst-performing subcategory in the dataset. Office Desks (55%) and Chairs (58%) are healthy, but Accessories is quietly eroding category profit
- **Outdoor/Patio revenue is $6.5M with 58–59% margin, while Gardening sits at $3.1M with the same margin** — identical profitability profile but less than half the order volume. Either a niche product line or underexposed in the catalogue
- **Bedroom Lighting drops to 48% margin** — nearly 10 percentage points below Bedding (57%) and Decor (57%) in the same category. Something structural is driving the gap — pricing, COGS, or heavy discounting
- **Storage is heavily concentrated in Boxes ($7.2M)** — Baskets generates only $2.9M at similar margin (54%). If Boxes faces a supply or demand issue, the entire category feels it

### Discounting & Returns

- **Discounting is consistent across all categories** — margin variation is driven by product mix and COGS, not promotional pricing
- **Storage Boxes has a 33% return rate** — meaningfully above the 26–28% clustering across all other subcategories. Warrants investigation into product quality, sizing expectations, or fulfilment issues

### Channel Performance

- **B2B AOV is 1% higher than Wholesale, and 76% higher than B2C** — as expected for a direct business channel vs. consumer
- **Wholesale AOV is 83% higher than Amazon and 86% higher than Shopify** — the self-managed wholesale channel significantly outperforms marketplace channels in average order value, likely reflecting bulk purchasing behaviour
<img width="551" height="342" alt="{DAE7E42C-1959-41BB-AF7D-0A4FCF2BACE8}" src="https://github.com/user-attachments/assets/e210fa30-46fe-470d-ab2e-1f3e67a442eb" />

---

## Project Structure

```
├── Etl.py                  # Python ETL pipeline (extract → load to Azure SQL)
├── sql/
│   ├── cleaning.sql        # UPDATE and ALTER statements for raw data cleaning
│   └── views.sql           # View definitions (FactSales, DimProduct, etc.)
├── Analytics.pbix          # Power BI dashboard file
└── README.md
```

---

*Synthetic dataset. Built with Python, Azure SQL, and Power BI.*
