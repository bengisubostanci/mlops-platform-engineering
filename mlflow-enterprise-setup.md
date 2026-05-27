

# Enterprise MLflow Tracking Server Configuration Guide

This deployment guide outlines the step-by-step configuration of a production-grade **MLflow Tracking Server**. It utilizes a dual-backend architecture: **PostgreSQL** for relational metadata/metrics tracking and distributed storage (**Hadoop HDFS** or **AWS S3**) as the immutable artifact store.

---

## Architecture Overview

- **Backend Store:** PostgreSQL (Tracks experiments, parameters, metrics, and runs).
- **Artifact Store:** Hadoop HDFS (On-premise) or Amazon S3 (Cloud native) (Stores models, plots, and heavy binaries).
- **Process Manager:** Gunicorn (WSGI HTTP Server handling MLflow traffic).

---

## Pre-requisites & Dependencies

> ⚠️ **Note:** Ensure your core development tools and database client libraries are correctly mapped before compiling python packages.

```bash
# Install core system dependencies
sudo yum -y groupinstall "Development Tools"
sudo yum -y install python3-devel postgresql-libs postgresql-devel

# Activate your designated virtual environment
source ~/venvspark/bin/activate

# Install high-performance client libraries & ML frameworks
pip install psycopg2 mlflow keras tensorflow pyspark==3.0.0


Phase 1: Storage Layer Initialization
-- Connect to your PostgreSQL instance and execute:
CREATE DATABASE mlflow OWNER train ENCODING 'UTF8';

public | alembic_version       | table | train
 public | experiment_tags       | table | train
 public | experiments           | table | train
 public | latest_metrics        | table | train
 public | metrics               | table | train
 public | model_version_tags    | table | train
 public | model_versions        | table | train
 public | params                | table | train
 public | registered_model_tags | table | train
 public | registered_models     | table | train
 public | runs                  | table | train
 public | tags                  | table | train

2. Distributed File System Setup (Hadoop HDFS)

# Initialize all Hadoop core daemons (NameNode, DataNode, ResourceManager)
start-all.sh


Phase 2: Launching the MLflow Server

mlflow server \
  --backend-store-uri postgresql+psycopg2://train:Ankara06@localhost:5432/mlflow \
  --default-artifact-root hdfs://localhost:9000/user/train/mlflow \
  --host 0.0.0.0 \
  > mlflow_server.log 2>&1 &

Option B: Cloud-Native Architecture (PostgreSQL + AWS S3)
# Inject cloud provider credentials into environment scope
export AWS_ACCESS_KEY_ID="your_access_key_here"
export AWS_SECRET_ACCESS_KEY="your_secret_key_here"

# Execute tracking service targeting Amazon S3 storage infrastructure
mlflow server \
  --backend-store-uri postgresql+psycopg2://train:Ankara06@localhost:5432/mlflow \
  --default-artifact-root s3://train-mlflow \
  --host 0.0.0.0:5000 \
  > mlflow_server.log 2>&1 &

Phase 3: Verification & Process Management
Once executed, access the central dashboard via your browser footprint:
👉 http://localhost:5000/

# Check if the tracking server daemon is active
ps -A | grep gunicorn

# Gracefully terminate/kill the active MLflow instance
pkill -f gunicorn
