<div align="center">

# movielens-end-to-end-data-pipeline

### From raw CSV files to a Power BI dashboard — built with a modern data stack

<br/>

<!-- ── TOOL ICONS — replace each src path with your downloaded PNG ── -->
<table>
  <tr>
    <td align="center">
      <img width="60" height="60" alt="amazon-s3-svgrepo-com" src="https://github.com/user-attachments/assets/a406d595-7cf3-4d38-b5fe-9f2f778bb8e7" /><br/>
      <sub><b>AWS S3</b></sub>
    </td>
    <td align="center" width="30"></td>
    <td align="center">
      <img width="60" height="60" alt="snowflake-data-cloud-icon" src="https://github.com/user-attachments/assets/fee697ae-fba9-4d21-b9b8-4a60f45cafe9" /><br/>
      <sub><b>Snowflake</b></sub>
    </td>
    <td align="center" width="30"></td>
    <td align="center">
       <img width="60" height="60" alt="dbt-icon" src="https://github.com/user-attachments/assets/f1cebf7e-3f51-4165-87eb-c5616c332ce2" /><br/>
      <sub><b>dbt</b></sub>
    </td>
    <td align="center" width="30"></td>
    <td align="center">
      <img width="60" height="60" alt="Microsoft-Power-Bi--Streamline-Svg-Logos" src="https://github.com/user-attachments/assets/bb34e1a7-949b-4183-ad0e-66b034b6e75f" /><br/>
      <sub><b>Power BI</b></sub>
    </td>
  </tr>
</table>

<br/>

![Star Schema](https://img.shields.io/badge/Star_Schema-✓-2f9e44?style=flat-square)
![Medallion Architecture](https://img.shields.io/badge/Medallion_Architecture-Bronze_·_Silver_·_Gold-gold?style=flat-square)
![dbt tests](https://img.shields.io/badge/dbt_tests-passing-2f9e44?style=flat-square)
![dbt models](https://img.shields.io/badge/dbt_models-14-FF694B?style=flat-square&logo=dbt&logoColor=white)

</div>

---

## 📌 Overview

This project builds a complete end-to-end data pipeline using the [MovieLens dataset](https://grouplens.org/datasets/movielens/) — a well-known dataset containing 20+ millions of movie ratings, tags, and genome scores.

The pipeline follows the **Medallion Architecture** (Bronze → Silver → Gold), ingesting raw CSV files through **AWS S3** into **Snowflake**, transforming them with **dbt**, and delivering a **Power BI** dashboard for business insights.

---

## 🏗️ Architecture Diagram

<div align="center">
<img width="1691" height="930" alt="diagram_last" src="https://github.com/user-attachments/assets/fb7c4233-06cc-46c2-8793-4b4375cbdd77" />


*End-to-end pipeline: CSV → S3 → Snowflake → dbt → Power BI*

---

## 🥉🥈🥇 Medallion Architecture

| Layer | Storage | What happens |
|-------|---------|--------------|
| 🥉 **Bronze** | AWS S3 + `MOVIELENS.RAW` | Raw files loaded as-is — no transformation, original column names and types |
| 🥈 **Silver** | `MOVIELENS.STAGING` + `MOVIELENS.ANALYTICS` | Renamed columns, type casting, surrogate keys, business logic |
| 🥇 **Gold** | `MOVIELENS.ANALYTICS` (marts) | Pre-aggregated, dashboard-ready tables |

```
CSV Files ──► AWS S3 ──► Snowflake RAW ──► dbt Staging + Core ──► dbt Marts ──► Power BI
              │               │                    │                    │
           🥉 BRONZE       🥉 BRONZE            🥈 SILVER           🥇 GOLD
```

---

## ❄️ Snowflake Schema Setup

```sql
-- Run once before your first dbt run
CREATE SCHEMA IF NOT EXISTS MOVIELENS.STAGING;
CREATE SCHEMA IF NOT EXISTS MOVIELENS.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS MOVIELENS.SNAPSHOTS;
-- MOVIELENS.RAW already exists from data ingestion
```

| Schema | Layer | Contains |
|--------|-------|----------|
| `MOVIELENS.RAW` | 🥉 Bronze | Raw source tables loaded from S3 |
| `MOVIELENS.STAGING` | 🥈 Silver | `src_*` staging views |
| `MOVIELENS.ANALYTICS` | 🥈🥇 Silver + Gold | `dim_`, `fct_`, `bridge_`, `mart_` tables |
| `MOVIELENS.SNAPSHOTS` | Optional | SCD2 snapshot history |

---

## 🌟 Star Schema Design

```

```

---

## 📁 Project Structure
<pre>
movielens-end-to-end-data-pipeline/
├── models/
│   ├── bridge/
│   │   └── bridge_movie_tags.sql
│   ├── dim/
│   │   ├── dim_genome_tags.sql
│   │   ├── dim_movies.sql
│   │   └── dim_users.sql
│   ├── fct/
│   │   └── fct_ratings.sql
│   ├── mart/
│   │   ├── mart_genre_summary.sql
│   │   ├── mart_movie_releases.sql
│   │   └── mart_top_movies.sql
│   ├── staging/
│   │   ├── sources.yml
│   │   ├── src_genome_score.sql
│   │   ├── src_genome_tags.sql
│   │   ├── src_links.sql
│   │   ├── src_movies.sql
│   │   ├── src_ratings.sql
│   │   └── src_tags.sql
│   └── schema.yml
├── snapshots/
│   └── snap_movies.sql
├── dbt_project.yml
└── packages.yml
</pre>
```

---

## 🔄 Key dbt Transformations

| Transformation | Function | Model |
|----------------|----------|-------|
| Rename camelCase → snake_case | Column aliases | All `src_*` |
| Unix int → timestamp | `TO_TIMESTAMP_LTZ()` | `src_ratings`, `src_tags` |
| Extract release year | `REGEXP_SUBSTR()` | `dim_movies` |
| Remove year from title | `REGEXP_REPLACE()` | `dim_movies` |
| Split genres into array | `SPLIT(genres, '\|')` | `dim_movies` |
| Explode array into rows | `LATERAL FLATTEN` | `mart_genre_summary` |
| MD5 surrogate keys | `dbt_utils.generate_surrogate_key()` | All dim + fct |
| Incremental load | `WHERE timestamp > MAX(timestamp)` | `fct_ratings` |
| Behavioral user stats | `COUNT DISTINCT, AVG, MIN, MAX` | `dim_users` |

---

## 🧪 Data Quality Tests

Tests run via `dbt test` and defined in `schema.yml`:

| Test | Column | Model |
|------|--------|-------|
| `unique` + `not_null` | All `_sk` surrogate keys | All dim + fct |
| `not_null` | All FK columns | `fct_ratings`, `bridge_movie_tags` |
| `accepted_values` (0.5–5.0) | `rating` | `fct_ratings` |
| `relationships` → `dim_movies` | `movie_id` | `fct_ratings`, `bridge_movie_tags` |
| `relationships` → `dim_users` | `user_id` | `fct_ratings` |
| `relationships` → `dim_genome_tags` | `tag_id` | `bridge_movie_tags` |

> The `relationships` test is the dbt equivalent of a foreign key constraint — Snowflake does not enforce FKs, so dbt tests fill that role.

---

## 🚀 How to Run

**Prerequisites:** Snowflake account with `MOVIELENS.RAW` loaded · dbt Core installed (`pip install dbt-snowflake`) · credentials in `~/.dbt/profiles.yml`

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/movielens-end-to-end-data-pipeline.git
cd movielens-end-to-end-data-pipeline

# Install packages
dbt deps

# Verify connection
dbt debug

# Build all models
dbt run

# Run all tests
dbt test

# View documentation and lineage
dbt docs generate && dbt docs serve
```

**Full pipeline in one command:**
```bash
dbt deps && dbt snapshot && dbt run && dbt test
```

---

## 📊 Power BI Setup

Connect to **`MOVIELENS.ANALYTICS`** and import:

**Star schema tables** — create these relationships in Model view:
```
fct_ratings [movie_id]        →→→  dim_movies [movie_id]
fct_ratings [user_id]         →→→  dim_users [user_id]
bridge_movie_tags [movie_id]  →→→  dim_movies [movie_id]
bridge_movie_tags [tag_id]    →→→  dim_genome_tags [tag_id]
```

**Mart tables** — standalone, no relationships needed:

| Mart | Power BI Visual |
|------|----------------|
| `mart_genre_summary` | Bar chart · Treemap |
| `mart_movie_releases` | Line chart · Area chart |
| `mart_top_movies` | Ranked table |

---

## 📚 Resources

- 📺 [Tutorial Video — Netflix Data Analysis | dbt Course](https://www.youtube.com/watch?v=zZVQluYDwYY)
- 📖 [dbt Documentation](https://docs.getdbt.com/)
- 📖 [dbt-utils Package](https://github.com/dbt-labs/dbt-utils)
- 📖 [Snowflake COPY INTO](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table)
- 📖 [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)
- 📖 [MovieLens Dataset](https://grouplens.org/datasets/movielens/)

---

<div align="center">

Made with ❤️ using dbt · Snowflake · AWS · Power BI

</div>
