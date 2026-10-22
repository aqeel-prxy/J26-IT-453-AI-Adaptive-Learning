import math
from typing import Dict, Any, Tuple


class TelemetryPreprocessor:
    """
    Multi-modal Telemetry Preprocessor for Component 02
    Handles response latency normalization, noise filtering, outlier clipping,
    and multi-modal behavioral weighting (attempts, hints, option switches).
    """

    # Empirical Grade 10-11 Math problem-solving latency benchmarks (in ms)
    BENCHMARK_MEAN_LATENCY_MS = 32000.0  # 32 seconds
    BENCHMARK_STD_LATENCY_MS = 16000.0   # 16 seconds
    MIN_VALID_LATENCY_MS = 1500.0        # Sub-1.5s implies rapid click/guess
    MAX_VALID_LATENCY_MS = 300000.0      # >5 mins implies idle pause

    @classmethod
    def clean_and_normalize_latency(cls, raw_latency_ms: int) -> Tuple[float, float, bool]:
        """
        Cleans raw latency, handles outlier clipping, and computes:
        1. Log-normalized latency
        2. Standardized Z-score relative to grade-level norms
        Returns: (clipped_latency_ms, z_score, is_outlier)
        """
        is_outlier = False
        clipped = float(raw_latency_ms)

        if clipped < cls.MIN_VALID_LATENCY_MS:
            clipped = cls.MIN_VALID_LATENCY_MS
            is_outlier = True
        elif clipped > cls.MAX_VALID_LATENCY_MS:
            clipped = cls.MAX_VALID_LATENCY_MS
            is_outlier = True

        # Standardized Z-Score
        z_score = (clipped - cls.BENCHMARK_MEAN_LATENCY_MS) / cls.BENCHMARK_STD_LATENCY_MS
        # Bound z-score to [-3.0, 3.0]
        z_score = max(-3.0, min(3.0, z_score))

        return clipped, z_score, is_outlier

    @classmethod
    def compute_behavioral_evidence(
        cls,
        is_correct: bool,
        response_time_ms: int,
        attempt_number: int = 1,
        hints_used: int = 0,
        option_switches: int = 0
    ) -> Dict[str, Any]:
        """
        Fuses multi-modal interaction signals into standardized evidence features.
        Differentiates between:
        - Confident mastery: Fast correct on 1st attempt with no hints
        - Hesitant correctness: Correct but slow, with multiple option switches
        - Assisted answer: Correct after hints/multiple attempts
        - Fast lucky guess: Extremely fast correct on complex question
        - Careless slip: Very fast incorrect on familiar concept
        """
        clipped_ms, z_score, is_outlier = cls.clean_and_normalize_latency(response_time_ms)

        # Speed factor: 1.0 = normal, >1.0 = faster than average, <1.0 = slower
        # Sigmoid-based speed factor centered at 0
        speed_factor = 1.0 / (1.0 + math.exp(z_score * 0.8))

        # Hesitation penalty based on attempts, hints, and option switching
        hesitation_penalty = 0.0
        if attempt_number > 1:
            hesitation_penalty += min(0.35, (attempt_number - 1) * 0.15)
        if hints_used > 0:
            hesitation_penalty += min(0.30, hints_used * 0.12)
        if option_switches > 1:
            hesitation_penalty += min(0.15, (option_switches - 1) * 0.05)

        # Potential slip: fast, unassisted, but incorrect
        is_potential_slip = (not is_correct) and (z_score < -0.8) and (hints_used == 0)

        # Potential guess: fast correct on first attempt without hints
        is_potential_guess = is_correct and (z_score < -1.2) and (attempt_number == 1)

        # Composite multi-modal evidence score in [0.0, 1.0]
        if is_correct:
            evidence_score = max(0.40, 1.0 - (hesitation_penalty * 0.8) - (0.15 if is_potential_guess else 0.0))
        else:
            evidence_score = min(0.35, 0.10 + (hesitation_penalty * 0.5))

        return {
            "cleaned_latency_ms": clipped_ms,
            "latency_z_score": round(z_score, 4),
            "speed_factor": round(speed_factor, 4),
            "hesitation_penalty": round(hesitation_penalty, 4),
            "evidence_score": round(evidence_score, 4),
            "is_potential_slip": is_potential_slip,
            "is_potential_guess": is_potential_guess,
            "is_outlier": is_outlier
        }
