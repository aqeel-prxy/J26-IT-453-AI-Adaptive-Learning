import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.learning_path.pedagogical_generator import (
    pedagogical_generator,
    NIE_COMPETENCY_MAPPING
)

client = TestClient(app)


def test_nie_competency_mapping_coverage():
    """Verify official Sri Lankan NIE curriculum competencies are defined for G10 and G11."""
    # Grade 11 Indices and Logarithms
    g11_keys = [
        "MATH-G11-IND-01", "MATH-G11-IND-02", "MATH-G11-IND-03",
        "MATH-G11-LOG-01", "MATH-G11-LOG-02", "MATH-G11-LOG-03", "MATH-G11-LOG-04"
    ]
    for key in g11_keys:
        assert key in NIE_COMPETENCY_MAPPING
        entry = NIE_COMPETENCY_MAPPING[key]
        assert "competency_code" in entry
        assert "descriptor" in entry
        assert "textbook_ref" in entry
        assert "Grade 11" in entry["textbook_ref"]

    # Grade 10 Quadratic Equations
    g10_keys = [
        "MATH-G10-QUAD-01", "MATH-G10-QUAD-02", "MATH-G10-QUAD-03", "MATH-G10-QUAD-04"
    ]
    for key in g10_keys:
        assert key in NIE_COMPETENCY_MAPPING
        entry = NIE_COMPETENCY_MAPPING[key]
        assert "competency_code" in entry
        assert "descriptor" in entry
        assert "textbook_ref" in entry
        assert "Grade 10" in entry["textbook_ref"]


def test_goal_differentiation_term_test_vs_comprehensive():
    """Verify dynamic pedagogical content diverges meaningfully based on student goal."""
    concept_id = "10000000-0000-0000-0000-000000000001"  # Positive Integral Laws of Indices

    # 1. Term-Test Mode (Cramming / Exam-Focused)
    term_test_lesson = pedagogical_generator.synthesize_lesson_unit(
        concept_id=concept_id,
        goal_type="TERM_TEST",
        grade_level=11
    )
    assert term_test_lesson["goal_type"] == "TERM_TEST"
    assert "⚡ Term-Test Cramming" in term_test_lesson["pedagogical_mode"]["badge"]
    assert term_test_lesson["pedagogical_mode"]["estimated_minutes"] == 10
    assert "EXAM CRAMMING STRATEGY" in term_test_lesson["theory"]
    assert "composite bases" in term_test_lesson["theory"]

    # 2. Comprehensive Mode (Mastery / First-Principles)
    comp_lesson = pedagogical_generator.synthesize_lesson_unit(
        concept_id=concept_id,
        goal_type="COMPREHENSIVE",
        grade_level=11
    )
    assert comp_lesson["goal_type"] == "COMPREHENSIVE"
    assert "🎯 Comprehensive Mastery" in comp_lesson["pedagogical_mode"]["badge"]
    assert comp_lesson["pedagogical_mode"]["estimated_minutes"] == 20
    assert "CONCEPTUAL FOUNDATION" in comp_lesson["theory"]
    assert comp_lesson["conceptual_analogy"] is not None
    assert len(comp_lesson["conceptual_analogy"]) > 20

    # Ensure theory texts are distinct
    assert term_test_lesson["theory"] != comp_lesson["theory"]


def test_prerequisite_bridge_generation():
    """Verify explicit cognitive bridge connecting Grade 10 foundational algebra to Grade 11 concepts."""
    # Negative Indices Bridge
    lesson_neg = pedagogical_generator.synthesize_lesson_unit(
        concept_id="10000000-0000-0000-0000-000000000002",
        goal_type="COMPREHENSIVE",
        grade_level=11
    )
    bridge = lesson_neg["prerequisite_bridge"]
    assert bridge is not None
    assert "source_concept" in bridge
    assert "target_concept" in bridge
    assert "explanation" in bridge
    assert "Division of Fractions" in bridge["source_concept"]
    assert "a⁰ = 1" in bridge["explanation"] or "a⁰ MUST equal 1" in bridge["explanation"]


def test_annotated_worked_example_rationales():
    """Verify that every step includes mathematical transformation, pedagogical rationale, and verification."""
    lesson = pedagogical_generator.synthesize_lesson_unit(
        concept_id="10000000-0000-0000-0000-000000000002",
        goal_type="TERM_TEST",
        grade_level=11
    )
    worked_ex = lesson["worked_example"]
    assert "problem" in worked_ex
    assert "steps" in worked_ex
    assert len(worked_ex["steps"]) >= 2

    for step in worked_ex["steps"]:
        assert "step_number" in step
        assert "working" in step
        assert "pedagogical_rationale" in step
        assert len(step["pedagogical_rationale"]) > 5

    assert "verification_check" in worked_ex


def test_grade_10_quadratic_equation_synthesis():
    """Verify Grade 10 Quadratic equation synthesis aligns with Competency 10.2 and 10.4."""
    # Solving by Factorization
    lesson_quad = pedagogical_generator.synthesize_lesson_unit(
        concept_id="MATH-G10-QUAD-02",
        goal_type="TERM_TEST",
        grade_level=10
    )
    assert lesson_quad["curriculum_competency"] == "Competency 10.2"
    assert "Factorization" in lesson_quad["title"] or "factorization" in lesson_quad["competency_descriptor"]
    assert "ax² + bx + c = 0" in lesson_quad["theory"] or "ax^2 + bx + c = 0" in lesson_quad["competency_descriptor"]

    # Quadratic Formula
    lesson_form = pedagogical_generator.synthesize_lesson_unit(
        concept_id="MATH-G10-QUAD-04",
        goal_type="COMPREHENSIVE",
        grade_level=10
    )
    assert lesson_form["curriculum_competency"] == "Competency 10.4"
    formula_rules = [f["rule"] for f in lesson_form["formulas"]]
    assert any("b² - 4ac" in r or "b^2 - 4ac" in r for r in formula_rules)


def test_api_lesson_endpoint_with_goal_query():
    """Verify FastAPI route `/lesson/{concept_id}` honors query parameters."""
    concept_id = "10000000-0000-0000-0000-000000000001"
    
    # Query with TERM_TEST
    resp_term = client.get(f"/api/v1/learning-path/lesson/{concept_id}?goal_type=TERM_TEST&grade_level=11")
    assert resp_term.status_code == 200
    data_term = resp_term.json()
    assert data_term["goal_type"] == "TERM_TEST"
    assert "curriculum_competency" in data_term
    assert "prerequisite_bridge" in data_term

    # Query with COMPREHENSIVE
    resp_comp = client.get(f"/api/v1/learning-path/lesson/{concept_id}?goal_type=COMPREHENSIVE&grade_level=11")
    assert resp_comp.status_code == 200
    data_comp = resp_comp.json()
    assert data_comp["goal_type"] == "COMPREHENSIVE"
    assert data_comp["theory"] != data_term["theory"]
