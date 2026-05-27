# Distributed Spark Machine Learning & MLflow Tracking Operations

This module details the runtime execution for training distributed machine learning models on **Apache Spark (YARN)**, managing core lifecycles via **MLflow Server**, and applying inference paradigms through distributed **Batch Predictions**.

---

## Technical Pipeline Architecture

### 1. Model Training & Experiment Registration
Workloads are submitted directly to the Hadoop YARN cluster resource manager. The training cycles are logged into separated experiment targets to evaluate performance metrics:

```bash
# Execute baseline regression model structure
spark-submit --master yarn train.py

# Submit challenger Gradient Boosted Trees (GBT) architecture with distinct tuning parameters
spark-submit --master yarn train_gbt_.py

👉 After completion, monitor parameters, evaluation scores, and structural plots via the dashboard: http://localhost:5000/#/experiments/1

2. Model Registry & Batch Inference

//Once production-ready thresholds are met, models are promoted to the central MLflow Model Registry.

To generate distributed batch inferences leveraging the registered metadata layers (e.g., Target Model: spark-gbt-regressor, Version: 1), trigger the following submit sequence:

# Execute distributed batch prediction matrix
spark-submit --master yarn batch_prediction.py
Expected Execution Log Output
[20.945943568858045, 10.664813501556925, 10.069087121212121, 20.29233789018, 14.147560744810743]
