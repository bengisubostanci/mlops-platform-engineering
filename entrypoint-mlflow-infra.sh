#!/usr/bin/env bash

# ==============================================================================
# Script Name    : entrypoint-mlflow-infra.sh
# Description    : Automated initialization orchestrator for Enterprise MLflow 
#                  Tracking Server targeting PostgreSQL, Hadoop HDFS, and AWS S3.
# Author         : Bengisu Bostanci
# ==============================================================================

# Hata oluştuğunda scriptin durmasını sağlayan güvenli modları aktif ediyoruz
set -eo pipefail

echo "======================================================================"
echo "🚀 Initializing Production MLOps Tracking Infrastructure..."
echo "======================================================================"

# --- STEP 1: HADOOP HDFS SERVICES CHECK ---
echo "⚙️ [1/4] Starting Hadoop Distributed File System (HDFS) daemons..."
if ! command -v start-all.sh &> /dev/null; then
    echo "❌ Error: Hadoop environment binary 'start-all.sh' not found in PATH."
    exit 1
fi

# Hadoop servislerini arka planda ayağa kaldırıyoruz
start-all.sh
echo "✅ Hadoop ecosystem storage services are running smoothly."

# --- STEP 2: VIRTUAL ENVIRONMENT ACTIVATION ---
echo "⚙️ [2/4] Activating designated Python Virtual Environment..."
VENV_PATH="$HOME/venvspark/bin/activate"

if [ -f "$VENV_PATH" ]; then
    source "$VENV_PATH"
    echo "✅ Virtual environment successfully mapped: $(which python)"
else
    echo "❌ Error: Virtual environment execution path not found at $VENV_PATH"
    exit 1
fi

# --- STEP 3: INFRASTRUCTURE PROCESS CONTROL (CLEANUP) ---
echo "⚙️ [3/4] Scanning for conflicting legacy backend server instances..."
# Eğer arkada çalışan eski bir gunicorn/mlflow süreci varsa temizliyoruz
if pkill -f gunicorn; then
    echo "⚠️ Terminated existing rogue Gunicorn/MLflow processes."
    sleep 2
else
    echo "✅ No active conflicting tracking processes detected."
fi

# --- STEP 4: ORCHESTRATE MLFLOW TRACKING SERVER ---
echo "⚙️ [4/4] Spinning up enterprise MLflow Tracking Daemon..."

# Ortam değişkenlerini ve bağlantı stringlerini parametreleştiriyoruz
DB_URI="postgresql+psycopg2://train:Ankara06@localhost:5432/mlflow"
HDFS_ARTIFACT_ROOT="hdfs://localhost:9000/user/train/mlflow"
SERVER_HOST="0.0.0.0"
SERVER_PORT="5000"
LOG_FILE="mlflow_server.log"

# MLflow sunucusunu güvenli bir şekilde arka planda (detach mode) başlatıyoruz
mlflow server \
    --backend-store-uri "$DB_URI" \
    --default-artifact-root "$HDFS_ARTIFACT_ROOT" \
    --host "$SERVER_HOST" \
    --port "$SERVER_PORT" > "$LOG_FILE" 2>&1 &

# Arka plandaki sürecin başlaması için ufak bir bekleme süresi
sleep 3

# Sürecin ayağa kalkıp kalkmadığını kontrol ediyoruz
if ps -A | grep gunicorn > /dev/null; then
    echo "======================================================================"
    echo "🎉 SUCCESS: MLflow Central Tracking Server is fully operational!"
    echo "🌐 Central Dashboard Web UI available at: http://localhost:${SERVER_PORT}"
    echo "📝 Execution logs actively streamed to: ./$LOG_FILE"
    echo "======================================================================"
else
    echo "❌ Critical Error: MLflow tracking server failed to transition to active state."
    echo "🔍 Check telemetry logs inside ./$LOG_FILE for details."
    exit 1
fi
