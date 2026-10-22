"""
Similar Mathematics Practice Question Service
Owner: Ranathunga K.P.B.S (IT23322530)
Component 4: AI-Assisted Mathematical Solution Analysis, Error Diagnosis & Personalized Correction
"""

import random
from typing import Dict, Any, List
from uuid import UUID
from app.services.error_diagnosis.math_solver import MathSolver


class SimilarQuestionService:
    """Provides mathematically verified similar practice questions for student retry."""

    QUESTION_BANK = {
        "Quadratic Equations": [
            {
                "question_id": "c4000000-0000-0000-0000-000000000001",
                "concept_id": "MATH-G10-QUAD-01",
                "topic": "Quadratic Equations",
                "question": "x² + 7x + 12 = 0",
                "difficulty": "Medium",
                "expected_answer": "x = -3 or x = -4"
            },
            {
                "question_id": "c4000000-0000-0000-0000-000000000002",
                "concept_id": "MATH-G10-QUAD-01",
                "topic": "Quadratic Equations",
                "question": "x² - 5x + 6 = 0",
                "difficulty": "Medium",
                "expected_answer": "x = 2 or x = 3"
            },
            {
                "question_id": "c4000000-0000-0000-0000-000000000003",
                "concept_id": "MATH-G10-QUAD-01",
                "topic": "Quadratic Equations",
                "question": "2x² + 5x - 3 = 0",
                "difficulty": "Hard",
                "expected_answer": "x = -3 or x = 1/2"
            },
            {
                "question_id": "c4000000-0000-0000-0000-000000000004",
                "concept_id": "MATH-G10-QUAD-01",
                "topic": "Quadratic Equations",
                "question": "x² + 6x + 8 = 0",
                "difficulty": "Easy",
                "expected_answer": "x = -2 or x = -4"
            },
            {
                "question_id": "c4000000-0000-0000-0000-000000000005",
                "concept_id": "MATH-G10-QUAD-01",
                "topic": "Quadratic Equations",
                "question": "x² - 9 = 0",
                "difficulty": "Easy",
                "expected_answer": "x = 3 or x = -3"
            }
        ],
        "Linear Equations": [
            {
                "question_id": "c4000000-0000-0000-0000-000000000006",
                "concept_id": "MATH-G10-LIN-01",
                "topic": "Linear Equations",
                "question": "3(x + 2) = 21",
                "difficulty": "Medium",
                "expected_answer": "x = 5"
            },
            {
                "question_id": "c4000000-0000-0000-0000-000000000007",
                "concept_id": "MATH-G10-LIN-01",
                "topic": "Linear Equations",
                "question": "2(x - 5) = 8",
                "difficulty": "Medium",
                "expected_answer": "x = 9"
            },
            {
                "question_id": "c4000000-0000-0000-0000-000000000008",
                "concept_id": "MATH-G10-LIN-01",
                "topic": "Linear Equations",
                "question": "4x + 7 = 31",
                "difficulty": "Easy",
                "expected_answer": "x = 6"
            },
            {
                "question_id": "c4000000-0000-0000-0000-000000000009",
                "concept_id": "MATH-G10-LIN-01",
                "topic": "Linear Equations",
                "question": "5(x + 1) = 25",
                "difficulty": "Easy",
                "expected_answer": "x = 4"
            }
        ]
    }

    @classmethod
    def get_similar_question(cls, current_question: str) -> Dict[str, Any]:
        """
        Retrieves a similar practice question testing the same concept.
        Ensures the returned question is distinct from the current question and verified.
        """
        cleaned = current_question.lower()
        if "x^2" in cleaned or "x²" in cleaned:
            topic = "Quadratic Equations"
        else:
            topic = "Linear Equations"

        candidates = cls.QUESTION_BANK.get(topic, cls.QUESTION_BANK["Quadratic Equations"])
        
        # Filter out current question using normalized clean representation
        clean_curr = MathSolver.clean_math_text(current_question).replace(" ", "").lower()
        filtered = [
            c for c in candidates
            if MathSolver.clean_math_text(c["question"]).replace(" ", "").lower() != clean_curr
        ]
        selected = random.choice(filtered) if filtered else candidates[0]

        # Mathematically verify using MathSolver before returning
        verification = MathSolver.solve_question(selected["question"])
        if verification.get("success"):
            selected["expected_answer"] = verification.get("final_answer", selected["expected_answer"])

        return selected
