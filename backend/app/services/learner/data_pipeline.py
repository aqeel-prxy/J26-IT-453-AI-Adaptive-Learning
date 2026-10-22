import os
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, timezone
import pandas as pd
from app.services.learner.preprocessor import TelemetryPreprocessor


class LearnerDataPipeline:
    """
    Data Pipeline for Component 02
    Handles ingestion, cleaning, missing-value imputation, timestamp normalization,
    and feature preparation for real-world benchmark datasets (EdNet / ASSISTments)
    and local Grade 10-11 Mathematics pilot trial logs.
    """

    DEFAULT_DATA_PATH = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))),
        "data", "benchmarks", "grade11_math_pilot_telemetry.csv"
    )

    @classmethod
    def load_telemetry_dataset(cls, csv_path: Optional[str] = None) -> pd.DataFrame:
        """Loads and parses raw student interaction logs."""
        path = csv_path or cls.DEFAULT_DATA_PATH
        if not os.path.exists(path):
            raise FileNotFoundError(f"Telemetry dataset not found at: {path}")

        df = pd.read_csv(path)
        return cls.clean_and_preprocess_dataset(df)

    @classmethod
    def clean_and_preprocess_dataset(cls, df: pd.DataFrame) -> pd.DataFrame:
        """
        Cleans interaction logs:
        - Drops corrupted / empty rows
        - Fills default behavioral metrics (hints=0, option_switches=0)
        - Normalizes response latency and extracts Z-score
        - Computes inter-response intervals (time gaps) per student
        """
        cleaned = df.copy()

        # Ensure required columns exist
        required_cols = ["student_id", "concept_id", "is_correct", "response_time_ms"]
        for col in required_cols:
            if col not in cleaned.columns:
                raise ValueError(f"Missing required dataset column: {col}")

        # Cast boolean correctness
        cleaned["is_correct"] = cleaned["is_correct"].astype(bool)

        # Impute missing behavioural telemetry
        if "attempt_number" not in cleaned.columns:
            cleaned["attempt_number"] = 1
        else:
            cleaned["attempt_number"] = cleaned["attempt_number"].fillna(1).astype(int)

        if "hints_used" not in cleaned.columns:
            cleaned["hints_used"] = 0
        else:
            cleaned["hints_used"] = cleaned["hints_used"].fillna(0).astype(int)

        if "option_switches" not in cleaned.columns:
            cleaned["option_switches"] = 0
        else:
            cleaned["option_switches"] = cleaned["option_switches"].fillna(0).astype(int)

        # Parse timestamps if present
        if "timestamp" in cleaned.columns:
            cleaned["timestamp"] = pd.to_datetime(cleaned["timestamp"], utc=True)
            cleaned = cleaned.sort_values(by=["student_id", "timestamp"]).reset_index(drop=True)
            # Compute inter-session gap in hours
            cleaned["time_gap_hours"] = (
                cleaned.groupby("student_id")["timestamp"].diff().dt.total_seconds() / 3600.0
            ).fillna(0.0)
        else:
            cleaned["time_gap_hours"] = 0.0

        # Apply multi-modal latency normalization
        preprocessed_features = cleaned.apply(
            lambda row: TelemetryPreprocessor.compute_behavioral_evidence(
                is_correct=row["is_correct"],
                response_time_ms=int(row["response_time_ms"]),
                attempt_number=int(row["attempt_number"]),
                hints_used=int(row["hints_used"]),
                option_switches=int(row["option_switches"])
            ),
            axis=1
        )

        features_df = pd.DataFrame(list(preprocessed_features))
        result_df = pd.concat([cleaned, features_df], axis=1)

        return result_df

    @classmethod
    def split_train_test(
        cls,
        df: pd.DataFrame,
        test_size: float = 0.25,
        random_state: int = 42
    ) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """
        Enforces strict student-level splitting to prevent data leakage across sessions.
        """
        import numpy as np
        unique_students = df["student_id"].unique()
        np.random.seed(random_state)
        shuffled = np.random.permutation(unique_students)

        split_idx = int(len(shuffled) * (1 - test_size))
        train_students = set(shuffled[:split_idx])
        test_students = set(shuffled[split_idx:])

        train_df = df[df["student_id"].isin(train_students)].copy()
        test_df = df[df["student_id"].isin(test_students)].copy()

        return train_df, test_df
