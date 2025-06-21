# dbt Procurement Pipeline

This dbt project transforms procurement and bid data from multiple JSONL sources into output tables that power two key user-facing features in the Datenna platform:

1. **Procurements Page** – page with all relevant procurements, displays procurement information and winners.
2. **Company Profile Page** – enriches company pages with all procurements a company participated on, and winner information.

---

## 📦 Overview

This pipeline handles data from several sources (e.g., source 12, 34, 56), loaded via validated JSONL files into BigQuery. 

The data is transformed in dbt using a `staging → intermediate → marts` layer structure to meet platform-specific data quality and usability requirements.

---

## ✅ Output Tables

### 1. `procurements_page`
- One row per procurement.
- Fields:
  - Procurement number
  - Procurement title (cleaned)
  - Published date
  - Buyer
  - Number of bids
  - Winner supplier name
  - Winner bid value
- **Use case:** feeds the procurement search UI on the platform.

### 2. `company_profile_page`
- One row per bid.
- Fields:
  - Supplier
  - Procurement metadata (title, published date, buyer)
  - Value amount and currency
  - `is_winner` boolean
- **Use case:** enriches the profile of each company with all bids submitted, highlighting wins.

### The **contract for the output** can be found in the data_contracts folder. Additionally, a Looker Studio dashboard can be seen [here](https://lookerstudio.google.com/s/m7JkUfS4tcM).
---

## 🛠 Project Structure

- **`base_*`**: 1:1 base models with the source, to be unioned later (e.g., `base_source_12__bids_12`)
- **`stg_*`**: Union base models (e.g., `stg_bids`, `stg_procurements`)
- **`int_*`**: Join and enrich logic (e.g., `int_suppliers_bids`)
- **`marts/*`**: Final models used for downstream consuption
  - `procurements_page.sql`
  - `company_profile_page.sql`
![Diagram](image.png)
This structure is based on [dbt's project structure best practices](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview).

---

## 📌 Key Business Rules Enforced
(As seen in the provided output_description.md file)
- All procurements should have a title
- The title shouldn't have identification codes (e.g. '1-560')
- All the bids should have a supplier name
- The bid value and currency should be separated in two columns.

---
## 🧠 Assumptions
In addition to the key business rules described above, the following assumptions were used:
- A procurement is considered **won by the bid with the lowest non-null value**.
- Only bids with non-null values are considered. Therefore, bids with missing or unparsable `value` fields are filtered out in the intermediate layer.

---

## ⚙️ Configuration

- Final `company_profile_page` table is **clustered by `supplier`** to optimize filter performance in BigQuery.
- Documentation is persisted to BigQuery using `persist_docs`.

---

## 🧪 Tests and Validation

- Column-level tests for:
  - Not null constraints (e.g., `supplier`, `procurement_number`)
  - Regex validation for cleaned titles
- Primary keys defined per model for uniqueness and integrity, e.g. int model due to join operation.

---

## 🚀 How to Run

1. Create a .venv and activate it.
2. Run `pip install requirements.txt`
3. Log in on GCP through `gcloud auth application-default login`
4. Run dbt!

```bash
dbt deps           # install packages, such as dbt_utils and dbt_expectations
dbt build          # run and tests models
dbt docs generate  # generate documentation
dbt docs serve     # view documentation

