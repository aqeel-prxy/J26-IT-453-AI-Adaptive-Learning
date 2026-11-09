"""
Model Training Script — Component 1 (Aqeel M.I.M)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Executes end-to-end dataset generation, student-level splitting, model training,
comparative evaluation (Logistic Regression, Random Forest, Gradient Boosting),
and artifact persistence.
"""
import sys
import os
import json

# Ensure backend root is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..')))

from app.services.learning_path.data_pipeline import (
    generate_development_dataset, student_train_test_split
)
from app.services.learning_path.readiness_model import ReadinessModelTrainer


def run_pipeline() -> None:
    print("=" * 70)
    print("STEP 1: Generating Development-Only Training Dataset...")
    print("=" * 70)
    dataset_path = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "data", "development", "dev_readiness_data.csv")
    )
    df = generate_development_dataset(output_path=dataset_path, num_students=160, random_seed=42)
    print(f"Dataset generated with {len(df)} records across {df['student_id'].nunique()} distinct students.")
    print(f"Saved to: {dataset_path}")

    print("\n" + "=" * 70)
    print("STEP 2: Student-Grouped Train/Test Splitting (Zero Learner Leakage)...")
    print("=" * 70)
    train_df, test_df = student_train_test_split(df, test_size=0.25, random_seed=42)
    print(f"Train set: {len(train_df)} samples across {train_df['student_id'].nunique()} students.")
    print(f"Test set:  {len(test_df)} samples across {test_df['student_id'].nunique()} students.")

    print("\n" + "=" * 70)
    print("STEP 3: Training & Evaluating Candidate Machine Learning Models...")
    print("=" * 70)
    trainer = ReadinessModelTrainer(random_seed=42)
    report = trainer.train_and_evaluate(train_df, test_df)

    print("\n" + "-" * 70)
    print(f"{'Model Name':<30} | {'Accuracy':<8} | {'Precision':<9} | {'Recall':<8} | {'F1':<6} | {'ROC-AUC':<8} | {'Brier':<6}")
    print("-" * 70)
    for model_name, metrics in report["comparative_metrics"].items():
        print(
            f"{model_name:<30} | {metrics['accuracy']:<8} | {metrics['precision']:<9} | "
            f"{metrics['recall']:<8} | {metrics['f1_score']:<6} | {metrics['roc_auc']:<8} | {metrics['brier_score']:<6}"
        )
    print("-" * 70)
    print(f"\nWinning Selected Model: {report['selected_model']}")
    print(f"Saved Model Artifact to: {report['model_path']}")
    print("=" * 70)


if __name__ == "__main__":
    run_pipeline()
