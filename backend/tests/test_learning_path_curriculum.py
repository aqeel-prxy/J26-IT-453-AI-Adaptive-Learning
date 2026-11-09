"""
Unit Tests for Component 1 Curriculum Prerequisite DAG & Diagnostic Bank
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students
"""
import sys
import os
import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.services.learning_path.curriculum_graph import (
    CurriculumDAG, ConceptNode, INDICES_LOGARITHMS_DAG
)
from app.services.learning_path.diagnostic_bank import (
    DIAGNOSTIC_QUESTION_BANK,
    get_diagnostic_questions_for_topic,
    get_prerequisite_screening_questions,
    get_questions_for_concept
)


def test_indices_logarithms_dag_is_acyclic():
    """Verify that the official Grade 11 Indices and Logarithms prerequisite graph is strictly acyclic."""
    assert INDICES_LOGARITHMS_DAG.is_acyclic() is True


def test_indices_logarithms_dag_node_count():
    """Verify that all 7 core Grade 11 concepts are present in the DAG."""
    assert len(INDICES_LOGARITHMS_DAG.nodes) == 7


def test_topological_sort_preserves_prerequisites():
    """
    Verify that every prerequisite appears BEFORE the dependent concept
    in the topological sort order.
    """
    sorted_nodes = INDICES_LOGARITHMS_DAG.topological_sort()
    seen_ids = set()

    for node in sorted_nodes:
        for pid in node.prerequisites:
            assert pid in seen_ids, (
                f"Prerequisite '{pid}' must appear before dependent concept '{node.code}' ({node.id}) "
                f"in topological order."
            )
        seen_ids.add(node.id)


def test_cycle_detection_in_curriculum_dag():
    """Verify that circular prerequisite references are correctly detected and rejected."""
    cyclic_dag = CurriculumDAG(topic_name="Cyclic Test", grade_level=11)
    cyclic_dag.add_concept(ConceptNode(
        id="c-node-1", code="TEST-01", title="Node 1", description="", grade_level=11, topic="Test",
        prerequisites=["c-node-2"]
    ))
    cyclic_dag.add_concept(ConceptNode(
        id="c-node-2", code="TEST-02", title="Node 2", description="", grade_level=11, topic="Test",
        prerequisites=["c-node-1"]
    ))

    assert cyclic_dag.is_acyclic() is False
    with pytest.raises(ValueError, match="Circular prerequisite dependency detected"):
        cyclic_dag.topological_sort()


def test_ancestor_prerequisites_resolution():
    """
    Verify transitive prerequisite resolution:
    Solving Logarithmic Equations (Concept 7) depends directly on Concept 2 and Concept 5.
    Concept 5 depends on Concept 4, which depends on Concepts 1 and 2.
    Therefore, transitive ancestors must include Concepts 1, 2, 4, 5.
    """
    concept_7_id = "10000000-0000-0000-0000-000000000007"
    ancestors = INDICES_LOGARITHMS_DAG.get_all_ancestor_prerequisites(concept_7_id)
    ancestor_ids = {a.id for a in ancestors}

    assert "10000000-0000-0000-0000-000000000001" in ancestor_ids  # Laws of Positive Indices
    assert "10000000-0000-0000-0000-000000000002" in ancestor_ids  # Fractional Indices
    assert "10000000-0000-0000-0000-000000000004" in ancestor_ids  # Definition of Logarithms
    assert "10000000-0000-0000-0000-000000000005" in ancestor_ids  # Laws of Logarithms


def test_prerequisites_satisfaction_evaluation():
    """
    Test prerequisite satisfaction logic under varied mastery states:
    - Target: Concept 4 (Definition of Logarithm) requires Concept 1 and Concept 2.
    """
    c4_id = "10000000-0000-0000-0000-000000000004"
    c1_id = "10000000-0000-0000-0000-000000000001"
    c2_id = "10000000-0000-0000-0000-000000000002"

    # Case A: Neither prerequisite mastered
    satisfied_none, missing_none = INDICES_LOGARITHMS_DAG.validate_prerequisites_satisfied(c4_id, set())
    assert satisfied_none is False
    assert set(missing_none) == {c1_id, c2_id}

    # Case B: Only Concept 1 mastered
    satisfied_partial, missing_partial = INDICES_LOGARITHMS_DAG.validate_prerequisites_satisfied(c4_id, {c1_id})
    assert satisfied_partial is False
    assert missing_partial == [c2_id]

    # Case C: Both mastered
    satisfied_full, missing_full = INDICES_LOGARITHMS_DAG.validate_prerequisites_satisfied(c4_id, {c1_id, c2_id})
    assert satisfied_full is True
    assert len(missing_full) == 0


def test_diagnostic_question_bank_integrity():
    """Verify that every diagnostic question is linked to a valid concept in the DAG."""
    all_questions = get_diagnostic_questions_for_topic("Indices and Logarithms")
    assert len(all_questions) >= 12

    for q in all_questions:
        assert q["concept_id"] in INDICES_LOGARITHMS_DAG.nodes, (
            f"Question {q['id']} references unknown concept {q['concept_id']}"
        )
        assert len(q["options"]) == 4
        assert q["correct_answer"] in q["options"]
        assert 0.0 <= q["difficulty"] <= 1.0


def test_prerequisite_screening_questions():
    """Verify that prerequisite screening questions exist and target early concepts."""
    screening = get_prerequisite_screening_questions()
    assert len(screening) >= 4

    screening_concept_ids = {q["concept_id"] for q in screening}
    # Screening questions should cover the foundational concepts
    assert "10000000-0000-0000-0000-000000000001" in screening_concept_ids
    assert "10000000-0000-0000-0000-000000000002" in screening_concept_ids
