"""
Data Pipeline & Dataset Preparation — Component 1 (Aqeel M.I.M)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Provides dataset loading, feature engineering, and development-only dataset generation
strictly adhering to research safeguards:
- Learner-level data splitting (preventing student data leakage across train and test sets).
- Transparent feature extraction without target leakage.
- Clear tagging of development-only synthetic data.
"""
import os
import random
import numpy as np
import pandas as pd
from typing import Tuple, List, Dict, Any
from app.services.learning_path.curriculum_graph import INDICES_LOGARITHMS_DAG

# Metadata tag required by research safeguards
DEV_DATASET_HEADER = """# ==============================================================================
# DEVELOPMENT-ONLY DATASET — STRICTLY FOR PIPELINE TESTING AND VERIFICATION
# NOT AN AUTHENTIC DATASET — DO NOT USE TO MAKE SCIENTIFIC OR RESEARCH CLAIMS
# Component 1: Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning
# Author: Aqeel M.I.M (IT23244016)
# ==============================================================================
"""

FEATURE_COLUMNS = [
    "concept_order_index",
    "prerequisite_avg_accuracy",
    "past_overall_accuracy",
    "recent_attempt_count",
    "avg_response_time_ms",
]

TARGET_COLUMN = "is_ready"


def generate_development_dataset(
    output_path: str = "data/development/dev_readiness_data.csv",
    num_students: int = 150,
    random_seed: int = 42
) -> pd.DataFrame:
    """
    Generates a development-only dataset for pipeline verification.
    Simulates student responses across the Grade 11 Indices and Logarithms curriculum DAG.
    Grounded in pedagogical reality: prerequisite competence strongly informs target readiness.
    """
    random.seed(random_seed)
    np.random.seed(random_seed)

    concepts = INDICES_LOGARITHMS_DAG.topological_sort()
    records: List[Dict[str, Any]] = []

    for s_idx in range(1, num_students + 1):
        student_id = f"dev-student-{s_idx:04d}"

        # Latent student baseline mathematical ability: normal distribution
        latent_ability = np.clip(np.random.normal(loc=0.55, scale=0.20), 0.10, 0.95)

        # Track evolving student accuracy across concepts in topological sequence
        concept_scores: Dict[str, float] = {}
        all_past_scores: List[float] = []

        for node in concepts:
            # 1. Evaluate prerequisite accuracy from direct prerequisites
            if not node.prerequisites:
                prereq_acc = latent_ability  # Baseline ability for root concepts
            else:
                prereq_acc = np.mean([
                    concept_scores.get(pid, latent_ability * 0.6)
                    for pid in node.prerequisites
                ])

            # 2. Historical performance features (available BEFORE target concept attempt)
            past_overall_acc = float(np.mean(all_past_scores)) if all_past_scores else float(latent_ability)
            attempt_count = random.randint(1, 4)
            response_time_ms = float(np.clip(
                np.random.normal(loc=18000 - (latent_ability * 8000), scale=4000),
                5000, 45000
            ))

            # 3. Target Readiness Probability (Pedagogical logistic formula)
            # Higher prerequisite accuracy and latent ability boost readiness;
            # Higher curriculum order requires stronger prerequisite grounding.
            order_penalty = (node.order_index - 1) * 0.12
            logit = (
                2.8 * prereq_acc
                + 1.5 * past_overall_acc
                - 1.2 * order_penalty
                - 0.00003 * response_time_ms
                - 0.8
            )
            prob_ready = 1.0 / (1.0 + np.exp(-logit))

            # Binary outcome sampled from probability
            is_ready = 1 if random.random() < prob_ready else 0

            # Store attempt record
            records.append({
                "student_id": student_id,
                "concept_id": node.id,
                "concept_code": node.code,
                "concept_order_index": node.order_index,
                "prerequisite_avg_accuracy": round(float(prereq_acc), 4),
                "past_overall_accuracy": round(float(past_overall_acc), 4),
                "recent_attempt_count": attempt_count,
                "avg_response_time_ms": round(response_time_ms, 1),
                "is_ready": is_ready
            })

            # Update historical state for future concepts
            concept_scores[node.id] = 1.0 if is_ready else 0.2
            all_past_scores.append(1.0 if is_ready else 0.0)

    df = pd.DataFrame(records)

    # Save to disk with safeguard header
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(DEV_DATASET_HEADER)
        df.to_csv(f, index=False)

    return df


def load_dataset(file_path: str = "data/development/dev_readiness_data.csv") -> pd.DataFrame:
    """Loads dataset from CSV, skipping comment header lines."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Dataset file not found at: {file_path}")
    return pd.read_csv(file_path, comment="#")


def student_train_test_split(
    df: pd.DataFrame,
    test_size: float = 0.25,
    random_seed: int = 42
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """
    Performs a student-level split so all attempts by any given student
    fall strictly into either the training set OR the test set.
    PREVENTS TARGET LEAKAGE ACROSS LEARNERS.
    """
    unique_students = np.array(df["student_id"].unique(), dtype=object)
    rng = np.random.RandomState(random_seed)
    rng.shuffle(unique_students)

    split_idx = int(len(unique_students) * (1 - test_size))
    train_students = set(unique_students[:split_idx])
    test_students = set(unique_students[split_idx:])

    train_df = df[df["student_id"].isin(train_students)].copy()
    test_df = df[df["student_id"].isin(test_students)].copy()

    # Integrity verification
    assert len(train_students.intersection(test_students)) == 0, "Learner data leakage detected!"

    return train_df, test_df
