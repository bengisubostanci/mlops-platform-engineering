#!/usr/bin/env bash

# ==============================================================================
# Script Name    : run-spark-mlops.sh
# Description    : Automated execution orchestrator for Spark Model Training,
#                  MLflow Registration, and Distributed Batch Prediction.
# Author         : Bengisu Bostanci
# ==============================================================================

set -eo pipefail

echo "======================================================================"
echo "🎯 Initiating Distributed Spark MLOps Pipeline..."
echo "======================================================================"

# --- STEP 1: ENVIRONMENT & INSTANCE VERIFICATION ---
echo "⚙️ [1/4] Validating active MLflow Tracking Server instance..."
if ! ps -A | grep gunicorn > /dev/null; then
    echo "❌ Critical Error: MLflow Tracking Server is not running."
    echo "💡 Please execute 'entrypoint-mlflow-infra.sh' before starting this pipeline."
    exit 1
fi
echo "✅ Verified: MLflow Tracking Server daemon is actively listening."

# --- STEP 2: DISTRIBUTED MODEL TRAINING & EXPERIMENTATION ---
echo "⚙️ [2/4] Submitting initial Regression Training to YARN cluster..."
cd ../mlflow/play/spark_advertsing_regression

# İlk model eğitimi (Linear Regression / Baseline Model)
spark-submit --master yarn train.py

echo "⚙️ [3/4] Submitting challenger GBT Regression Training to YARN cluster..."
# İkinci model eğitimi (Gradient Boosted Trees - Farklı parametre ve run name ile)
spark-submit --master yarn train_gbt_.py

echo "✅ Training lifecycle complete. Artifacts successfully logged to MLflow UI (Port 5000)."

# --- STEP 3: DISTRIBUTED BATCH PREDICTION ---
echo "⚙️ [4/4] Orchestrating Batch Prediction workflows using registered models..."

# Tahmin scriptinin bulunduğu dizine geçiş yapıyoruz
cd ../batch_prediction

# Kayıtlı en güncel modeli (örn: spark-gbt-regressor, v1) kullanarak toplu tahmin işlemini başlatıyoruz
echo "📊 Executing parallelized inference on target data matrix..."
spark-submit --master yarn batch_prediction.py

echo "======================================================================"
echo "🎉 SUCCESS: End-to-End Spark MLOps Pipeline executed successfully!"
echo "======================================================================"
