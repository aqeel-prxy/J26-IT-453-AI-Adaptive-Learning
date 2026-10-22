"""
Model Training Script — Component 3 (Dharmasena K.C.D)
AI-Assisted Engagement, Gamification and Feedback Adaptation

Executes end-to-end dataset loading, stratified splitting, multi-candidate model training,
comparative evaluation (Random Forest, Gradient Boosting, Logistic Regression, SVC),
5-fold cross-validation with 95% confidence intervals, and model artifact persistence.
"""
import sys
import os

# Ensure backend root is on sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..')))

from app.services.engagement.data_pipeline import load_dataset, split_dataset
from app.services.engagement.engagement_model import EngagementModelTrainer


def run_pipeline() -> None:
    print("=" * 80)
    print("STEP 1: Ingesting & Validating Interaction Telemetry Dataset...")
    print("=" * 80)
    df = load_dataset()
    print(f"Dataset successfully loaded with {len(df)} total samples.")
    print("Class breakdown:")
    for cls_name, count in df["state"].value_counts().items():
        print(f"  - {cls_name:<12}: {count:>4} samples ({count / len(df) * 100:.1f}%)")

    print("\n" + "=" * 80)
    print("STEP 2: Stratified Train / Test Partitioning (75% Train / 25% Test)...")
    print("=" * 80)
    train_df, test_df = split_dataset(df, test_size=0.25, random_seed=42)
    print(f"Training set:   {len(train_df)} samples")
    print(f"Holdout test:   {len(test_df)} samples")

    print("\n" + "=" * 80)
    print("STEP 3: Training & Benchmarking Candidate Multi-Class Affective Classifiers...")
    print("=" * 80)
    trainer = EngagementModelTrainer(random_seed=42)
    report = trainer.train_and_evaluate(train_df, test_df)

    print("\n" + "-" * 80)
    print("HOLDOUT TEST SET COMPARISON:")
    print(f"{'Model Name':<28} | {'Accuracy':<8} | {'Macro F1':<8} | {'Weighted F1':<11} | {'ROC-AUC':<8}")
    print("-" * 80)
    for model_name, metrics in report["comparative_metrics"].items():
        print(
            f"{model_name:<28} | {metrics['accuracy']:<8.4f} | {metrics['f1_macro']:<8.4f} | "
            f"{metrics['f1_weighted']:<11.4f} | {metrics['roc_auc_macro']:<8.4f}"
        )
    print("-" * 80)

    print("\n" + "=" * 80)
    print("STEP 4: 5-FOLD STRATIFIED CROSS-VALIDATION (95% Confidence Intervals):")
    print("=" * 80)
    print(f"{'Model Name':<28} | {'F1 (Mean ± Std)':<18} | {'95% Confidence Interval':<24} | {'Accuracy':<10}")
    print("-" * 80)
    for model_name, m_dict in report.get("cross_validation_5fold_ci95", {}).items():
        f1_m = m_dict["f1_score"]["mean"]
        f1_s = m_dict["f1_score"]["std"]
        f1_ci = m_dict["f1_score"]["ci_95"]
        acc_m = m_dict["accuracy"]["mean"]
        print(f"{model_name:<28} | {f1_m:.4f} ± {f1_s:.4f}    | [{f1_ci[0]:.4f}, {f1_ci[1]:.4f}]           | {acc_m:.4f}")
    print("-" * 80)

    winning = report["selected_model"]
    win_metrics = report["comparative_metrics"][winning]
    print(f"\nWinning Model Selected: {winning}")
    print(f"Artifact Saved To:      {report['model_path']}")

    print("\nPER-CLASS BREAKDOWN (Winning Model):")
    print(f"{'State Label':<15} | {'Precision':<10} | {'Recall':<10} | {'F1-Score':<10} | {'Support':<8}")
    print("-" * 60)
    for label, p_met in win_metrics["per_class"].items():
        print(f"{label:<15} | {p_met['precision']:<10.4f} | {p_met['recall']:<10.4f} | {p_met['f1_score']:<10.4f} | {p_met['support']:<8}")

    if report.get("feature_importances"):
        print("\nFEATURE IMPORTANCES:")
        sorted_feats = sorted(report["feature_importances"].items(), key=lambda x: x[1], reverse=True)
        for feat, imp in sorted_feats:
            bar = "█" * int(imp * 40)
            print(f"  {feat:<18} : {imp:.4f}  {bar}")

    print("\nCONFUSION MATRIX:")
    print(f"Classes: {win_metrics['labels']}")
    for row in win_metrics["confusion_matrix"]:
        print(f"  {row}")

    print("=" * 80)
    print("Component 3 ML Model Training Complete!")
    print("=" * 80)


if __name__ == "__main__":
    run_pipeline()
