"""
Curriculum Prerequisite Graph Engine — Component 1 (Aqeel M.I.M)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Defines the Directed Acyclic Graph (DAG) data structure for secondary school mathematics concepts
and encodes the verified prerequisite relationships for Sri Lankan Grade 11 Mathematics.
"""
from dataclasses import dataclass, field
from typing import List, Dict, Set, Optional, Tuple, Any
from collections import deque


@dataclass
class ConceptNode:
    """Represents a single mathematical concept in the curriculum prerequisite graph."""
    id: str
    code: str
    title: str
    description: str
    grade_level: int
    topic: str
    prerequisites: List[str] = field(default_factory=list)
    order_index: int = 1
    textbook_ref: str = ""
    is_terminal_objective: bool = False

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "code": self.code,
            "title": self.title,
            "description": self.description,
            "grade_level": self.grade_level,
            "topic": self.topic,
            "prerequisites": self.prerequisites,
            "order_index": self.order_index,
            "textbook_ref": self.textbook_ref,
            "is_terminal_objective": self.is_terminal_objective,
        }


class CurriculumDAG:
    """
    Directed Acyclic Graph (DAG) managing concept prerequisites.
    Enforces that dependent mathematical concepts cannot be attempted
    before essential prerequisites are addressed.
    """

    def __init__(self, topic_name: str, grade_level: int = 11):
        self.topic_name = topic_name
        self.grade_level = grade_level
        self.nodes: Dict[str, ConceptNode] = {}
        self.code_to_id: Dict[str, str] = {}

    def add_concept(self, node: ConceptNode) -> None:
        """Adds a concept node to the DAG."""
        self.nodes[node.id] = node
        self.code_to_id[node.code] = node.id

    def get_concept(self, concept_id: str) -> Optional[ConceptNode]:
        """Retrieves a concept node by its UUID string or code."""
        if concept_id in self.nodes:
            return self.nodes[concept_id]
        if concept_id in self.code_to_id:
            return self.nodes[self.code_to_id[concept_id]]
        return None

    def get_direct_prerequisites(self, concept_id: str) -> List[ConceptNode]:
        """Returns direct prerequisite nodes for the given concept."""
        node = self.get_concept(concept_id)
        if not node:
            return []
        return [self.nodes[pid] for pid in node.prerequisites if pid in self.nodes]

    def get_all_ancestor_prerequisites(self, concept_id: str) -> List[ConceptNode]:
        """
        Returns all transitive (direct and indirect) prerequisite nodes
        in topological order leading up to the target concept.
        """
        node = self.get_concept(concept_id)
        if not node:
            return []

        ancestor_ids: Set[str] = set()
        queue = deque(node.prerequisites)

        while queue:
            curr_id = queue.popleft()
            if curr_id not in ancestor_ids and curr_id in self.nodes:
                ancestor_ids.add(curr_id)
                queue.extend(self.nodes[curr_id].prerequisites)

        # Return in topological order
        sorted_nodes = self.topological_sort()
        return [n for n in sorted_nodes if n.id in ancestor_ids]

    def is_acyclic(self) -> bool:
        """
        Verifies whether the curriculum graph is strictly acyclic (no circular dependencies).
        Uses Kahn's algorithm (indegree reduction).
        """
        try:
            self.topological_sort()
            return True
        except ValueError:
            return False

    def topological_sort(self) -> List[ConceptNode]:
        """
        Returns all concept nodes in valid topological order
        (every prerequisite concept appears before any concept that depends on it).
        Raises ValueError if a cycle is detected.
        """
        in_degree: Dict[str, int] = {cid: 0 for cid in self.nodes}
        adj_list: Dict[str, List[str]] = {cid: [] for cid in self.nodes}

        for cid, node in self.nodes.items():
            for pid in node.prerequisites:
                if pid in self.nodes:
                    adj_list[pid].append(cid)
                    in_degree[cid] += 1

        queue = deque([cid for cid, deg in in_degree.items() if deg == 0])
        sorted_nodes: List[ConceptNode] = []

        while queue:
            curr_id = queue.popleft()
            sorted_nodes.append(self.nodes[curr_id])

            for neighbor in adj_list[curr_id]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

        if len(sorted_nodes) != len(self.nodes):
            raise ValueError(
                f"Circular prerequisite dependency detected in {self.topic_name} DAG. "
                f"Processed {len(sorted_nodes)} of {len(self.nodes)} nodes."
            )

        return sorted_nodes

    def validate_prerequisites_satisfied(
        self, target_concept_id: str, mastered_concept_ids: Set[str]
    ) -> Tuple[bool, List[str]]:
        """
        Validates whether all essential prerequisites for a target concept are satisfied.
        Returns:
            (is_satisfied: bool, missing_prerequisite_ids: List[str])
        """
        node = self.get_concept(target_concept_id)
        if not node:
            return False, []

        missing: List[str] = [
            pid for pid in node.prerequisites
            if pid not in mastered_concept_ids
        ]
        return len(missing) == 0, missing

    def to_dict(self) -> Dict[str, Any]:
        """Serializes the DAG structure for API exposure."""
        return {
            "topic_name": self.topic_name,
            "grade_level": self.grade_level,
            "concepts": [node.to_dict() for node in self.topological_sort()],
            "edge_count": sum(len(n.prerequisites) for n in self.nodes.values()),
        }


# ==============================================================================
# AUTHORITATIVE CURRICULUM DEFINITION: Sri Lankan Grade 11 Mathematics
# Topic: Indices and Logarithms (දර්ශක හා ලඝුගණක)
# Reference: Ministry of Education Sri Lanka, Grade 11 Mathematics Textbook, Part I
# ==============================================================================

INDICES_LOGARITHMS_DAG = CurriculumDAG(
    topic_name="Indices and Logarithms",
    grade_level=11
)

# 1. Laws of Positive Integral Indices (Fundamental Grade 10-11 Bridge)
INDICES_LOGARITHMS_DAG.add_concept(ConceptNode(
    id="10000000-0000-0000-0000-000000000001",
    code="MATH-G11-IND-01",
    title="Laws of Positive Integral Indices",
    description="Product, quotient, power-of-a-power, and power-of-a-product rules for positive integer exponents: a^m * a^n = a^(m+n), a^m / a^n = a^(m-n), (a^m)^n = a^mn, a^0 = 1.",
    grade_level=11,
    topic="Indices and Logarithms",
    prerequisites=[],
    order_index=1,
    textbook_ref="Grade 11 Mathematics Part I, Chapter 3, Section 3.1",
    is_terminal_objective=False
))

# 2. Fractional and Negative Indices
INDICES_LOGARITHMS_DAG.add_concept(ConceptNode(
    id="10000000-0000-0000-0000-000000000002",
    code="MATH-G11-IND-02",
    title="Fractional and Negative Indices",
    description="Evaluation and simplification of expressions containing negative indices (a^-n = 1/a^n) and fractional indices (a^(1/n) = n-th root of a, a^(m/n) = (n-th root of a)^m).",
    grade_level=11,
    topic="Indices and Logarithms",
    prerequisites=["10000000-0000-0000-0000-000000000001"],
    order_index=2,
    textbook_ref="Grade 11 Mathematics Part I, Chapter 3, Section 3.2",
    is_terminal_objective=False
))

# 3. Scientific Notation and Standard Form
INDICES_LOGARITHMS_DAG.add_concept(ConceptNode(
    id="10000000-0000-0000-0000-000000000003",
    code="MATH-G11-IND-03",
    title="Scientific Notation (Standard Form)",
    description="Expressing very large and very small decimal numbers in scientific notation A x 10^n (1 <= A < 10, n in Z) and applying index operations.",
    grade_level=11,
    topic="Indices and Logarithms",
    prerequisites=[
        "10000000-0000-0000-0000-000000000001",
        "10000000-0000-0000-0000-000000000002"
    ],
    order_index=3,
    textbook_ref="Grade 11 Mathematics Part I, Chapter 3, Section 3.3",
    is_terminal_objective=False
))

# 4. Introduction to Logarithms and Form Conversion
INDICES_LOGARITHMS_DAG.add_concept(ConceptNode(
    id="10000000-0000-0000-0000-000000000004",
    code="MATH-G11-LOG-01",
    title="Definition of Logarithm and Form Conversion",
    description="Defining logarithms as the inverse of exponentiation: if a^x = y, then log_a(y) = x (a > 0, a != 1, y > 0). Converting between index form and logarithmic form.",
    grade_level=11,
    topic="Indices and Logarithms",
    prerequisites=[
        "10000000-0000-0000-0000-000000000001",
        "10000000-0000-0000-0000-000000000002"
    ],
    order_index=4,
    textbook_ref="Grade 11 Mathematics Part I, Chapter 4, Section 4.1",
    is_terminal_objective=False
))

# 5. Laws of Logarithms
INDICES_LOGARITHMS_DAG.add_concept(ConceptNode(
    id="10000000-0000-0000-0000-000000000005",
    code="MATH-G11-LOG-02",
    title="Laws of Logarithms",
    description="Proof and application of logarithmic identities: log_a(xy) = log_a(x) + log_a(y), log_a(x/y) = log_a(x) - log_a(y), log_a(x^k) = k * log_a(x), log_a(a) = 1, log_a(1) = 0.",
    grade_level=11,
    topic="Indices and Logarithms",
    prerequisites=["10000000-0000-0000-0000-000000000004"],
    order_index=5,
    textbook_ref="Grade 11 Mathematics Part I, Chapter 4, Section 4.2",
    is_terminal_objective=False
))

# 6. Common Logarithms, Characteristic, and Numerical Calculations
INDICES_LOGARITHMS_DAG.add_concept(ConceptNode(
    id="10000000-0000-0000-0000-000000000006",
    code="MATH-G11-LOG-03",
    title="Common Logarithms (Base 10) & Numerical Computations",
    description="Determination of characteristic and mantissa using standard form, finding logarithms and antilogarithms using tables, and performing multi-step numerical calculations.",
    grade_level=11,
    topic="Indices and Logarithms",
    prerequisites=[
        "10000000-0000-0000-0000-000000000003",
        "10000000-0000-0000-0000-000000000005"
    ],
    order_index=6,
    textbook_ref="Grade 11 Mathematics Part I, Chapter 4, Section 4.3",
    is_terminal_objective=True
))

# 7. Logarithmic and Exponential Equations
INDICES_LOGARITHMS_DAG.add_concept(ConceptNode(
    id="10000000-0000-0000-0000-000000000007",
    code="MATH-G11-LOG-04",
    title="Logarithmic and Exponential Equations",
    description="Solving algebraic equations involving unknowns in the exponent (e.g. 2^(x+1) = 16, 3^(2x-1) = 27) and logarithmic equations using law reduction.",
    grade_level=11,
    topic="Indices and Logarithms",
    prerequisites=[
        "10000000-0000-0000-0000-000000000002",
        "10000000-0000-0000-0000-000000000005"
    ],
    order_index=7,
    textbook_ref="Grade 11 Mathematics Part I, Chapter 4, Section 4.4",
    is_terminal_objective=True
))
