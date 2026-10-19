"""
Comprehensive Tests for Component 4: Mathematics Question Solving, OCR, and Error Diagnosis Workflow
Owner: Ranathunga K.P.B.S (IT23322530)
"""

import base64
import pytest
from fastapi.testclient import TestClient
import sympy as sp
from app.main import app
from app.services.error_diagnosis.math_solver import MathSolver
from app.services.error_diagnosis.ocr_service import MathOCRService
from app.services.error_diagnosis.question_generator import SimilarQuestionService

client = TestClient(app)

# 1. Manual question submission
def test_manual_question_submission():
    response = client.post(
        "/api/v1/error/solve",
        json={"question": "2(x + 3) = 14"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["supported"] is True
    assert data["final_answer"] == "x = 4"
    assert len(data["steps"]) >= 3


# 2. Image upload and OCR extraction
def test_image_upload_and_ocr_extraction():
    import os
    sample_path = os.path.join(os.path.dirname(__file__), "..", "data", "test_sample.jpeg")
    if os.path.exists(sample_path):
        with open(sample_path, "rb") as f:
            b64_data = base64.b64encode(f.read()).decode("utf-8")
    else:
        b64_data = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAALUlEQVR42u3BAQEAAACCIP+vbkhAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/BhpkwABw8jRcwAAAABJRU5ErkJggg=="

    response = client.post(
        "/api/v1/error/ocr",
        json={"image_base64": b64_data}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["extracted_question"] is not None
    assert "x" in data["extracted_question"]
    if os.path.exists(sample_path):
        assert "6x" in data["extracted_question"]
        assert "5x" in data["extracted_question"]
        assert "=" in data["extracted_question"]
    assert data["confidence"] > 0.9


# 3. OCR error handling (empty or corrupted image)
def test_ocr_empty_and_corrupted_image_handling():
    # Empty string
    res_empty = client.post("/api/v1/error/ocr", json={"image_base64": ""})
    assert res_empty.status_code == 200
    assert res_empty.json()["success"] is False
    assert "No image data" in res_empty.json()["error_message"]

    # Corrupted base64
    res_corrupt = client.post("/api/v1/error/ocr", json={"image_base64": "not_valid_base64_data!!"})
    assert res_corrupt.status_code == 200
    assert res_corrupt.json()["success"] is False
    assert res_corrupt.json()["error_message"] is not None


# 4. Correct solution derivation (Linear and Quadratic)
def test_correct_solution_derivation_linear():
    res = MathSolver.solve_question("2(x + 3) = 14")
    assert res["success"] is True
    assert res["final_answer"] == "x = 4"
    assert res["steps"][0]["step_number"] == 1
    assert "2*x + 6 = 14" in res["steps"][0]["expression"]
    assert "Expand" in res["steps"][0]["explanation"]
    assert "Subtract" in res["steps"][1]["explanation"]
    assert res["steps"][2]["expression"] == "x = 4"


def test_correct_solution_derivation_quadratic():
    res = MathSolver.solve_question("2x² + 5x - 3 = 0")
    assert res["success"] is True
    assert "x = -3" in res["final_answer"]
    assert "x = 1/2" in res["final_answer"]
    assert len(res["steps"]) >= 4
    # Step 1 should be standard form
    assert "ax² + bx + c = 0" in res["steps"][0]["explanation"]


# 5. Incorrect mathematical expressions (Syntax errors)
def test_incorrect_mathematical_expressions():
    res = MathSolver.solve_question("2x +++ 5 ===")
    assert res["success"] is False
    assert res["supported"] is False
    assert "Could not parse" in res["error_message"]


# 6. Unsupported questions (Calculus, higher order polynomials)
def test_unsupported_questions():
    # Calculus
    res_calc = MathSolver.solve_question("d/dx(x^2) = 0")
    assert res_calc["supported"] is False
    assert "outside the Grade 10-11 syllabus" in res_calc["error_message"]

    # Cubic equation
    res_cubic = MathSolver.solve_question("x^3 - 6x^2 + 11x - 6 = 0")
    assert res_cubic["supported"] is False
    assert "degree 3 is not supported" in res_cubic["error_message"]

    # No variable x
    res_nox = MathSolver.solve_question("5 + 3 = 8")
    assert res_nox["supported"] is False
    assert "variable 'x'" in res_nox["error_message"]


# 7. Mathematical verification of every returned solution step
def test_mathematical_verification_of_returned_steps():
    equations = [
        "2(x + 3) = 14",
        "2x² + 5x - 3 = 0",
        "x² - 5x + 6 = 0",
        "x² - 9 = 0"
    ]
    x = sp.Symbol('x')
    for eq in equations:
        res = MathSolver.solve_question(eq)
        assert res["success"] is True
        roots = [sp.sympify(r) for r in res["roots"]]
        
        # Each root must satisfy the original equation
        cleaned = MathSolver.clean_math_text(eq)
        lhs_s, rhs_s = cleaned.split("=", 1)
        lhs = sp.sympify(MathSolver._to_sympy_expr_str(lhs_s))
        rhs = sp.sympify(MathSolver._to_sympy_expr_str(rhs_s))
        original_expr = lhs - rhs
        
        for r in roots:
            assert sp.simplify(original_expr.subs(x, r)) == 0


# 8. Error diagnosis of student's own working (Sign Error and Valid alternative)
def test_error_diagnosis_student_working():
    # Test sign error
    res_err = client.post(
        "/api/v1/error/check-working",
        json={
            "question": "2x² + 5x - 3 = 0",
            "solution_steps": "2x² + 6x - x - 3 = 0\n2x(x + 3) - 1(x + 3) = 0\n(2x - 1)(x + 3) = 0\nx = 1/2 or x = 3"
        }
    )
    assert res_err.status_code == 200
    data_err = res_err.json()
    assert data_err["is_correct"] is False
    assert data_err["failed_step_index"] == 4
    assert data_err["error_category"] == "Sign Error"
    assert "x = -3" in data_err["explanation_text"]

    # Test completely correct working
    res_ok = client.post(
        "/api/v1/error/check-working",
        json={
            "question": "2x² + 5x - 3 = 0",
            "solution_steps": "2x² + 6x - x - 3 = 0\n2x(x + 3) - 1(x + 3) = 0\n(2x - 1)(x + 3) = 0\nx = 1/2 or x = -3"
        }
    )
    assert res_ok.status_code == 200
    data_ok = res_ok.json()
    assert data_ok["is_correct"] is True
    assert data_ok["failed_step_index"] is None


# 9. Similar question retry and attempt persistence
def test_similar_question_retry_and_persistence():
    # Get similar question
    res_sim = client.get("/api/v1/error/similar-question?current_question=2x² + 5x - 3 = 0")
    assert res_sim.status_code == 200
    data_sim = res_sim.json()
    assert data_sim["topic"] == "Quadratic Equations"
    assert data_sim["question"] != "2x² + 5x - 3 = 0"
    assert data_sim["expected_answer"] is not None

    # Submit retry attempt to existing endpoint
    res_attempt = client.post(
        "/api/v1/mathematics/attempts/submit",
        json={
            "student_id": "a1111111-1111-1111-1111-111111111111",
            "question_id": data_sim["concept_id"] if len(data_sim["concept_id"]) == 36 else "c4000000-0000-0000-0000-000000000001",
            "student_solution": data_sim["expected_answer"],
            "response_time_ms": 12000
        }
    )
    assert res_attempt.status_code == 200
    attempt_data = res_attempt.json()
    assert attempt_data["attempt_id"] is not None
