"""
Diagnostic Question Bank — Component 1 (Aqeel M.I.M)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Contains curated diagnostic assessment questions grounded in the Sri Lankan Grade 11 Mathematics
curriculum for Indices and Logarithms, explicitly linked to nodes in the prerequisite DAG.
"""
from typing import List, Dict, Any

DIAGNOSTIC_QUESTION_BANK: List[Dict[str, Any]] = [
    # -------------------------------------------------------------------------
    # Concept 1: Laws of Positive Integral Indices (MATH-G11-IND-01)
    # -------------------------------------------------------------------------
    {
        "id": "q1000000-0000-0000-0000-000000000001",
        "concept_id": "10000000-0000-0000-0000-000000000001",
        "concept_code": "MATH-G11-IND-01",
        "question_text": "Simplify: 2^3 * 2^4",
        "options": ["2^7", "2^12", "4^7", "4^12"],
        "correct_answer": "2^7",
        "explanation": "According to the product law of indices a^m * a^n = a^(m+n), 2^3 * 2^4 = 2^(3+4) = 2^7.",
        "difficulty": 0.2,
        "is_prerequisite_check": True
    },
    {
        "id": "q1000000-0000-0000-0000-000000000002",
        "concept_id": "10000000-0000-0000-0000-000000000001",
        "concept_code": "MATH-G11-IND-01",
        "question_text": "Find the value of: (3^2)^3 / 3^4",
        "options": ["3^2", "3^1", "3^6", "9"],
        "correct_answer": "3^2",
        "explanation": "(3^2)^3 = 3^(2*3) = 3^6. Then 3^6 / 3^4 = 3^(6-4) = 3^2 (which is 9).",
        "difficulty": 0.35,
        "is_prerequisite_check": True
    },

    # -------------------------------------------------------------------------
    # Concept 2: Fractional and Negative Indices (MATH-G11-IND-02)
    # -------------------------------------------------------------------------
    {
        "id": "q1000000-0000-0000-0000-000000000003",
        "concept_id": "10000000-0000-0000-0000-000000000002",
        "concept_code": "MATH-G11-IND-02",
        "question_text": "Evaluate: 16^(-1/2)",
        "options": ["1/4", "-4", "1/8", "-1/4"],
        "correct_answer": "1/4",
        "explanation": "16^(-1/2) = 1 / (16^(1/2)) = 1 / sqrt(16) = 1/4.",
        "difficulty": 0.45,
        "is_prerequisite_check": True
    },
    {
        "id": "q1000000-0000-0000-0000-000000000004",
        "concept_id": "10000000-0000-0000-0000-000000000002",
        "concept_code": "MATH-G11-IND-02",
        "question_text": "Evaluate: 27^(2/3)",
        "options": ["9", "3", "18", "81"],
        "correct_answer": "9",
        "explanation": "27^(2/3) = (cbrt(27))^2 = 3^2 = 9.",
        "difficulty": 0.4,
        "is_prerequisite_check": True
    },

    # -------------------------------------------------------------------------
    # Concept 3: Scientific Notation (Standard Form) (MATH-G11-IND-03)
    # -------------------------------------------------------------------------
    {
        "id": "q1000000-0000-0000-0000-000000000005",
        "concept_id": "10000000-0000-0000-0000-000000000003",
        "concept_code": "MATH-G11-IND-03",
        "question_text": "Express 0.00045 in scientific notation (standard form):",
        "options": ["4.5 x 10^-4", "4.5 x 10^-3", "45 x 10^-5", "0.45 x 10^-3"],
        "correct_answer": "4.5 x 10^-4",
        "explanation": "Standard form is A x 10^n where 1 <= A < 10. Moving the decimal 4 places right gives 4.5 x 10^-4.",
        "difficulty": 0.35,
        "is_prerequisite_check": False
    },

    # -------------------------------------------------------------------------
    # Concept 4: Definition of Logarithm and Form Conversion (MATH-G11-LOG-01)
    # -------------------------------------------------------------------------
    {
        "id": "q1000000-0000-0000-0000-000000000006",
        "concept_id": "10000000-0000-0000-0000-000000000004",
        "concept_code": "MATH-G11-LOG-01",
        "question_text": "Convert 2^5 = 32 into logarithmic form:",
        "options": ["log_2(32) = 5", "log_5(32) = 2", "log_2(5) = 32", "log_32(2) = 5"],
        "correct_answer": "log_2(32) = 5",
        "explanation": "By definition, if a^x = y, then log_a(y) = x. With base a=2, exponent x=5, result y=32: log_2(32) = 5.",
        "difficulty": 0.3,
        "is_prerequisite_check": False
    },
    {
        "id": "q1000000-0000-0000-0000-000000000007",
        "concept_id": "10000000-0000-0000-0000-000000000004",
        "concept_code": "MATH-G11-LOG-01",
        "question_text": "Find the value of: log_3(81)",
        "options": ["4", "3", "27", "9"],
        "correct_answer": "4",
        "explanation": "Let log_3(81) = x. In index form, 3^x = 81. Since 3^4 = 81, x = 4.",
        "difficulty": 0.35,
        "is_prerequisite_check": False
    },

    # -------------------------------------------------------------------------
    # Concept 5: Laws of Logarithms (MATH-G11-LOG-02)
    # -------------------------------------------------------------------------
    {
        "id": "q1000000-0000-0000-0000-000000000008",
        "concept_id": "10000000-0000-0000-0000-000000000005",
        "concept_code": "MATH-G11-LOG-02",
        "question_text": "Simplify: log_10(25) + log_10(4)",
        "options": ["2", "100", "log_10(29)", "1"],
        "correct_answer": "2",
        "explanation": "By the product law log_a(x) + log_a(y) = log_a(xy), log_10(25) + log_10(4) = log_10(100) = 2.",
        "difficulty": 0.5,
        "is_prerequisite_check": False
    },
    {
        "id": "q1000000-0000-0000-0000-000000000009",
        "concept_id": "10000000-0000-0000-0000-000000000005",
        "concept_code": "MATH-G11-LOG-02",
        "question_text": "Express 2*log_a(x) - log_a(y) as a single logarithm:",
        "options": ["log_a(x^2 / y)", "log_a(2x / y)", "log_a(x^2 - y)", "log_a((x/y)^2)"],
        "correct_answer": "log_a(x^2 / y)",
        "explanation": "2*log_a(x) = log_a(x^2) by power law. Then log_a(x^2) - log_a(y) = log_a(x^2 / y) by quotient law.",
        "difficulty": 0.55,
        "is_prerequisite_check": False
    },

    # -------------------------------------------------------------------------
    # Concept 6: Common Logarithms & Calculations (MATH-G11-LOG-03)
    # -------------------------------------------------------------------------
    {
        "id": "q1000000-0000-0000-0000-000000000010",
        "concept_id": "10000000-0000-0000-0000-000000000006",
        "concept_code": "MATH-G11-LOG-03",
        "question_text": "What is the characteristic of log_10(0.0345)?",
        "options": ["-2 (or bar-2)", "2", "-1", "-3"],
        "correct_answer": "-2 (or bar-2)",
        "explanation": "0.0345 in standard form is 3.45 x 10^-2. The characteristic is the power of 10, which is -2 (written as bar-2).",
        "difficulty": 0.6,
        "is_prerequisite_check": False
    },

    # -------------------------------------------------------------------------
    # Concept 7: Logarithmic and Exponential Equations (MATH-G11-LOG-04)
    # -------------------------------------------------------------------------
    {
        "id": "q1000000-0000-0000-0000-000000000011",
        "concept_id": "10000000-0000-0000-0000-000000000007",
        "concept_code": "MATH-G11-LOG-04",
        "question_text": "Solve for x: 3^(2x - 1) = 27",
        "options": ["x = 2", "x = 1", "x = 4", "x = 3/2"],
        "correct_answer": "x = 2",
        "explanation": "Express both sides with base 3: 3^(2x - 1) = 3^3. Equating powers: 2x - 1 = 3 -> 2x = 4 -> x = 2.",
        "difficulty": 0.65,
        "is_prerequisite_check": False
    },
    {
        "id": "q1000000-0000-0000-0000-000000000012",
        "concept_id": "10000000-0000-0000-0000-000000000007",
        "concept_code": "MATH-G11-LOG-04",
        "question_text": "Solve for x: log_2(x + 3) = 4",
        "options": ["x = 13", "x = 5", "x = 11", "x = 16"],
        "correct_answer": "x = 13",
        "explanation": "Convert to index form: x + 3 = 2^4 = 16. Therefore, x = 16 - 3 = 13.",
        "difficulty": 0.6,
        "is_prerequisite_check": False
    }
]


def get_diagnostic_questions_for_topic(topic: str = "Indices and Logarithms") -> List[Dict[str, Any]]:
    """Returns all diagnostic questions for the specified topic."""
    return DIAGNOSTIC_QUESTION_BANK


def get_prerequisite_screening_questions() -> List[Dict[str, Any]]:
    """Returns fundamental diagnostic questions designed to screen for prerequisite gaps."""
    return [q for q in DIAGNOSTIC_QUESTION_BANK if q.get("is_prerequisite_check")]


def get_questions_for_concept(concept_id: str) -> List[Dict[str, Any]]:
    """Returns questions mapped to a specific concept node."""
    return [q for q in DIAGNOSTIC_QUESTION_BANK if q["concept_id"] == concept_id]
