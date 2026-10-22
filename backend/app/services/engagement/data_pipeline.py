"""
Data Pipeline — Component 3 (Dharmasena K.C.D)
AI-Assisted Engagement, Gamification and Feedback Adaptation

Loads and validates the interaction telemetry dataset for cognitive/affective state inference.
Dataset features:
- time_taken_sec: float (duration spent on the math problem)
- option_switches: int (number of times student changed their selected choice)
- is_rapid_guess: int (binary flag for fast unreflective guesses, e.g. < 3s)
- is_correct: int (binary correctness of the response)
- idle_seconds: float (hesitation or inactivity latency during attempt)
Target:
- state: str (Engaged, Bored, Frustrated)
"""
import os
import pandas as pd
from typing import Tuple, List
from sklearn.model_selection import train_test_split

FEATURE_COLUMNS: List[str] = [
    "time_taken_sec",
    "option_switches",
    "is_rapid_guess",
    "is_correct",
    "idle_seconds",
]

TARGET_COLUMN: str = "state"
CLASS_NAMES: List[str] = ["Engaged", "Bored", "Frustrated"]

DEFAULT_DATASET_PATHS = [
    os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "datasets", "raw", "synthetic_engagement_telemetry.csv")),
    os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "data", "development", "synthetic_engagement_telemetry.csv")),
]


def find_dataset_path(custom_path: str = None) -> str:
    """Finds the dataset path, checking custom path then project defaults."""
    if custom_path and os.path.exists(custom_path):
        return custom_path
    for p in DEFAULT_DATASET_PATHS:
        if os.path.exists(p):
            return p
    raise FileNotFoundError(f"Engagement telemetry dataset not found. Checked: {DEFAULT_DATASET_PATHS}")


def load_dataset(file_path: str = None) -> pd.DataFrame:
    """Loads and validates the engagement telemetry dataset."""
    resolved_path = find_dataset_path(file_path)
    df = pd.read_csv(resolved_path)

    # Validate required columns
    missing = [c for c in FEATURE_COLUMNS + [TARGET_COLUMN] if c not in df.columns]
    if missing:
        raise ValueError(f"Dataset missing required columns: {missing}")

    # Clean whitespace and normalize target string
    df[TARGET_COLUMN] = df[TARGET_COLUMN].astype(str).str.strip()

    # Drop any nulls if present
    df = df.dropna(subset=FEATURE_COLUMNS + [TARGET_COLUMN]).copy()

    # Ensure types
    df["time_taken_sec"] = df["time_taken_sec"].astype(float)
    df["option_switches"] = df["option_switches"].astype(int)
    df["is_rapid_guess"] = df["is_rapid_guess"].astype(int)
    df["is_correct"] = df["is_correct"].astype(int)
    df["idle_seconds"] = df["idle_seconds"].astype(float)

    return df


def split_dataset(
    df: pd.DataFrame,
    test_size: float = 0.25,
    random_seed: int = 42
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """
    Performs stratified train/test split to preserve balanced affective class distributions.
    """
    train_df, test_df = train_test_split(
        df,
        test_size=test_size,
        stratify=df[TARGET_COLUMN],
        random_state=random_seed
    )
    return train_df.reset_index(drop=True), test_df.reset_index(drop=True)
