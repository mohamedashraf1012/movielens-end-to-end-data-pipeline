<div align="center">

# Movielens-End-To-End-Data-Pipeline

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
    <td align="center" width="30"></td>
<td align="center">
  <img width="60" height="60" alt="apache-airflow-icon" src="https://github.com/user-attachments/assets/8ed72eb0-cbdd-4cb2-81ef-60f5149d9e08" /><br/>
  <sub><b>Apache Airflow</b></sub>
</td>
<td align="center">
  <img width="65" height="63" alt="apache-airflow-icon" src="https://github.com/user-attachments/assets/825a0362-e9c7-44dd-ab36-d544dbda321a" /><br/>
  <sub><b>Docker</b></sub>
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

The pipeline follows the **Medallion Architecture** (Bronze → Silver → Gold), ingesting raw CSV files through **AWS S3** into **Snowflake**, transforming them with **dbt**, orchestrating the workflow using **Apache Airflow**, and delivering business insights through a **Power BI** dashboard.


---

## 🏗️ Architecture Diagram

<div align="center">

  

<img width="1692" height="930" alt="ARCHITECTURE DIAGRAM_LAST" src="https://github.com/user-attachments/assets/3e64caad-32ca-4c6e-a795-61e2bc2a8d94" />


*End-to-end orchestrated pipeline: CSV → S3 → Snowflake → dbt → Airflow → Power BI*

---

## 🥉🥈🥇 Medallion Architecture

| Layer | Storage | What happens |
|-------|---------|--------------|
| 🥉 **Bronze** | AWS S3 + `MOVIELENS.RAW` | Raw CSV files ingested through Airflow and loaded into Snowflake RAW tables |
| 🥈 **Silver** | `MOVIELENS.STAGING` + `MOVIELENS.ANALYTICS` | dbt staging and core transformations with dimensions, facts, and bridge tables |
| 🥇 **Gold** | `MOVIELENS.ANALYTICS` (marts) | Business-ready marts powering Power BI dashboards |

---
##  STAR SCHEMA DIAGRAM

<img width="3989" height="2911" alt="star_schema" src="https://github.com/user-attachments/assets/34297cd9-17b8-45ec-8031-66e5c8b109a0" />

---

<div align="LEFT">
  
## ❄️ Snowflake Setup

Run all steps in a Snowflake Worksheet as `ACCOUNTADMIN`.

1. **Create a role** for dbt transformations and grant it to `ACCOUNTADMIN`
2. **Create a warehouse** and grant operate permissions to the role
3. **Create a dbt service user** with the role as default and set `TYPE=LEGACY_SERVICE`
4. **Create the database and schemas** for each layer of your pipeline
5. **Grant permissions** on the database, all schemas, and future tables to the role
6. **Create an external stage** pointing to your s3 bucket with the required credentials
7. **Create your raw tables** in the RAW schema matching your source file structure
8. **Load data** using `COPY INTO` for each table from the stage


---

## 🌪️ Apache Airflow Orchestration

The entire pipeline is automated using Apache Airflow through a DAG named:

```python
movielens_pipeline
```

The DAG runs daily and orchestrates the complete ELT workflow end-to-end.

### Airflow Tasks

| Order | Task | Description |
|------|------|-------------|
| 1 | `check_s3_files` | Waits for all required CSV files to exist in AWS S3 |
| 2 | `load_to_snowflake` | Loads raw CSV files from S3 into Snowflake RAW tables |
| 3 | `dbt_run_staging` | Builds staging models in Snowflake |
| 4 | `dbt_run_core` | Builds dimension, fact, and bridge models |
| 5 | `dbt_run_marts` | Builds Gold mart models |
| 6 | `dbt_test` | Runs dbt data quality and relationship tests |

### DAG Workflow

<img width="1212" height="160" alt="airflow_dag1" src="https://github.com/user-attachments/assets/98868595-3b64-4c93-9bf0-cd58cd4219ad" />


### Scheduling

- Schedule: `@daily`
- Catchup: `False`

This orchestration layer automates ingestion, transformation, testing, and warehouse loading without manual intervention.


---


## 📊 Power BI Dashboard

<img width="1325" height="886" alt="MOVIELENS_Dashboard" src="https://github.com/user-attachments/assets/68808fad-315d-4dfb-94ca-2a9a37caf297" />

---



## 🚀 How to Run

### Prerequisites

- Docker & Docker Compose
- Snowflake account
- AWS account + S3 bucket
- Airflow connections configured:
  - `aws_conn`
  - `snowflake_conn`

---

### Start the Pipeline

```bash
# Clone repository
git clone https://github.com/AbdallahAhmed7/movielens-end-to-end-data-pipeline.git

# Enter project directory
cd movielens-end-to-end-data-pipeline

# Enter Airflow directory
cd airflow


# Build custom Airflow image
docker compose build

# Start Airflow services
docker compose up -d
```

Open the Airflow UI at:
```bash
http://localhost:8080
```
Then trigger the DAG:
```bash
movielens_pipeline
```


### Running dbt Manually (Optional)

For local development and debugging, you can run dbt independently:

```bash
# Install packages
dbt deps

# Verify Snowflake connection
dbt debug

# Run models
dbt run

# Run tests
dbt test

# Generate and serve docs
dbt docs generate && dbt docs serve
```




## 📁 Project Structure

```bash

.
├── airflow/
│   ├── dags/
│   │   └── movielens_pipeline.py
│   ├── docker-compose.yml
│   ├── .env
│   └── Dockerfile
│
├── models/
│   ├── staging/
│   ├── dim/
│   ├── fct/
│   ├── bridge/
│   ├── mart/
│   ├── sources.yml
│   └── schema.yml
│
├── docs/
│
├── dbt_project.yml
├── packages.yml
└── README.md
```


<div align="center">


## 👨‍💻 Author

**Abdallah Ahmed, Mohamed Ashraf, Ahmed Hassan**


[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/abdallahahmed7)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/AbdallahAhmed7)


</div>
