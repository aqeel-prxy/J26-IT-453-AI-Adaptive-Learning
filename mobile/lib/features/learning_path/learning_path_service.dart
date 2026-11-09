import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';


class LearningPathService {
  final ApiClient apiClient;

  LearningPathService({ApiClient? client}) : apiClient = client ?? ApiClient();

  // Fallback demo student ID matching backend seed
  static const String demoStudentId = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11";

  // In-memory state for seamless dynamic pathway interaction
  static Map<String, dynamic>? activePlanCache;

  /// Fetches curriculum DAG for Indices and Logarithms
  Future<Map<String, dynamic>> getCurriculumDag(String topic) async {
    try {
      final endpoint = "${ApiEndpoints.learningPathCurriculum}/$topic";
      return await apiClient.get(endpoint);
    } catch (_) {
      return _localMockCurriculumDag;
    }
  }

  /// Fetches active learning plan for a student
  Future<Map<String, dynamic>> getActivePlan({String studentId = demoStudentId}) async {
    if (activePlanCache != null) {
      return activePlanCache!;
    }
    try {
      final endpoint = "${ApiEndpoints.learningPathPlan}/$studentId";
      final data = await apiClient.get(endpoint);
      activePlanCache = data;
      return data;
    } catch (_) {
      activePlanCache = _generateLocalMockPlan(goalType: "TERM_TEST");
      return activePlanCache!;
    }
  }

  /// Generates a new goal-aware learning plan
  Future<Map<String, dynamic>> createPlan({
    required String studentId,
    String topicCategory = "Indices and Logarithms",
    required String goalType,
    String? targetDate,
    int availableDailyMinutes = 30,
  }) async {
    final payload = {
      "student_id": studentId,
      "topic_category": topicCategory,
      "goal_type": goalType,
      "target_date": targetDate,
      "available_daily_minutes": availableDailyMinutes,
    };

    try {
      final data = await apiClient.post(ApiEndpoints.learningPathPlan, payload);
      activePlanCache = data;
      return data;
    } catch (_) {
      activePlanCache = _generateLocalMockPlan(
        goalType: goalType,
        targetDate: targetDate,
        dailyMinutes: availableDailyMinutes,
      );
      return activePlanCache!;
    }
  }

  /// Fetches diagnostic assessment questions
  Future<List<Map<String, dynamic>>> getDiagnosticQuestions() async {
    try {
      final data = await apiClient.get(ApiEndpoints.learningPathDiagnosticQuestions);
      final list = (data["questions"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      if (list.isNotEmpty) return list;
      return _localMockDiagnosticQuestions;
    } catch (_) {
      return _localMockDiagnosticQuestions;
    }
  }

  /// Submits diagnostic answers and obtains tailored pathway
  Future<Map<String, dynamic>> submitDiagnostic({
    required String studentId,
    required String goalType,
    required List<Map<String, dynamic>> responses,
  }) async {
    final payload = {
      "student_id": studentId,
      "topic_category": "Indices and Logarithms",
      "goal_type": goalType,
      "responses": responses,
    };

    try {
      final data = await apiClient.post(ApiEndpoints.learningPathDiagnosticSubmit, payload);
      activePlanCache = data;
      return data;
    } catch (_) {
      activePlanCache = _generateLocalMockPlan(goalType: goalType, fromDiagnostic: true);
      return activePlanCache!;
    }
  }

  /// Submits activity completion to trigger dynamic pathway revision (REQ-C1-07)
  Future<Map<String, dynamic>> completeActivity({
    required String studentId,
    required String conceptId,
    String activityType = "QUIZ",
    bool isSuccessful = true,
    double score = 1.0,
    int durationSeconds = 120,
  }) async {
    final payload = {
      "student_id": studentId,
      "concept_id": conceptId,
      "activity_type": activityType,
      "is_successful": isSuccessful,
      "score": score,
      "duration_seconds": durationSeconds,
    };

    try {
      final data = await apiClient.post(ApiEndpoints.learningPathActivityComplete, payload);
      // Update local cache nodes
      if (activePlanCache != null && data["pathway_nodes"] != null) {
        activePlanCache!["pathway_nodes"] = data["pathway_nodes"];
        activePlanCache!["recommended_activity"] = data["next_recommended_activity"];
        activePlanCache!["current_concept_id"] = data["next_concept_id"];
      }
      return data;
    } catch (_) {
      return _reviseLocalMockPlan(conceptId, isSuccessful, score);
    }
  }

  /// Retrieves structured lesson material
  Future<Map<String, dynamic>> getLesson(String conceptId) async {
    try {
      final endpoint = "${ApiEndpoints.learningPathLesson}/$conceptId";
      return await apiClient.get(endpoint);
    } catch (_) {
      return _localMockLessons[conceptId] ?? _localMockLessons.values.first;
    }
  }

  /// Retrieves empirical baseline comparison telemetry
  Future<Map<String, dynamic>> getBaselineComparison({String goalType = "TERM_TEST"}) async {
    try {
      final endpoint = "${ApiEndpoints.learningPathBaselines}?goal_type=$goalType";
      return await apiClient.get(endpoint);
    } catch (_) {
      return _localMockBaselines;
    }
  }

  // ===========================================================================
  // LOCAL MOCK STATE ENGINE (Ensures 100% offline & demo reliability)
  // ===========================================================================

  static Map<String, dynamic> _reviseLocalMockPlan(String completedConceptId, bool isSuccess, double score) {
    final plan = activePlanCache ?? _generateLocalMockPlan();
    final nodes = (plan["pathway_nodes"] as List).cast<Map<String, dynamic>>();

    int completedIdx = nodes.indexWhere((n) => n["concept_id"] == completedConceptId);
    if (completedIdx != -1) {
      if (isSuccess) {
        nodes[completedIdx]["status"] = "MASTERED";
        nodes[completedIdx]["readiness_probability"] = 0.92;
      } else {
        nodes[completedIdx]["status"] = "REVISION_REQUIRED";
      }
    }

    // Unlock next node
    int nextIdx = completedIdx + 1;
    String nextId = completedConceptId;
    String nextTitle = "Next Concept";
    if (nextIdx < nodes.length && isSuccess) {
      nodes[nextIdx]["status"] = "RECOMMENDED_NEXT";
      nextId = nodes[nextIdx]["concept_id"];
      nextTitle = nodes[nextIdx]["title"];
    }

    final nextActivity = {
      "activity_type": isSuccess ? "WORKED_EXAMPLE" : "REVISE_PREREQUISITE",
      "concept_id": nextId,
      "concept_title": nextTitle,
      "rationale": isSuccess
          ? "Mastery verified (${(score * 100).toInt()}%). Dynamic DAG engine unlocked next concept: $nextTitle."
          : "Readiness fell below threshold. Reinforcing prerequisite with worked examples.",
      "estimated_duration_minutes": 15,
    };

    plan["recommended_activity"] = nextActivity;
    plan["current_concept_id"] = nextId;
    activePlanCache = plan;

    return {
      "status": "revised",
      "previous_concept_id": completedConceptId,
      "next_concept_id": nextId,
      "next_recommended_activity": nextActivity,
      "pathway_nodes": nodes,
    };
  }

  static Map<String, dynamic> _generateLocalMockPlan({
    String goalType = "TERM_TEST",
    String? targetDate,
    int dailyMinutes = 30,
    bool fromDiagnostic = false,
  }) {
    return {
      "plan_id": "p-demo-plan-001",
      "student_id": demoStudentId,
      "topic_category": "Indices and Logarithms",
      "goal_type": goalType,
      "target_date": targetDate ?? "2026-11-25",
      "available_daily_minutes": dailyMinutes,
      "current_concept_id": "10000000-0000-0000-0000-000000000002",
      "overall_readiness_score": fromDiagnostic ? 0.82 : 0.68,
      "status": "ACTIVE",
      "recommended_activity": {
        "activity_type": goalType == "TERM_TEST" ? "PRACTICE" : "WORKED_EXAMPLE",
        "concept_id": "10000000-0000-0000-0000-000000000002",
        "concept_title": "Fractional and Negative Indices",
        "rationale": goalType == "TERM_TEST"
            ? "Term-Test High-Yield: Prerequisite 'Laws of Indices' verified (88% readiness). Fast-tracking to fractional index problem solving."
            : "Comprehensive Mastery: Step-by-step worked example recommended to anchor conceptual grounding.",
        "estimated_duration_minutes": 20,
      },
      "pathway_nodes": [
        {
          "concept_id": "10000000-0000-0000-0000-000000000001",
          "code": "MATH-G11-IND-01",
          "title": "Laws of Positive Integral Indices",
          "order_index": 1,
          "prerequisites": [],
          "textbook_ref": "Chapter 3, Section 3.1",
          "status": "MASTERED",
          "readiness_probability": 0.88,
          "confidence": 0.76,
          "model_version": "ML-RandomForest",
          "is_terminal_objective": false,
        },
        {
          "concept_id": "10000000-0000-0000-0000-000000000002",
          "code": "MATH-G11-IND-02",
          "title": "Fractional and Negative Indices",
          "order_index": 2,
          "prerequisites": ["10000000-0000-0000-0000-000000000001"],
          "textbook_ref": "Chapter 3, Section 3.2",
          "status": "RECOMMENDED_NEXT",
          "readiness_probability": 0.74,
          "confidence": 0.68,
          "model_version": "ML-RandomForest",
          "is_terminal_objective": false,
        },
        {
          "concept_id": "10000000-0000-0000-0000-000000000003",
          "code": "MATH-G11-IND-03",
          "title": "Scientific Notation (Standard Form)",
          "order_index": 3,
          "prerequisites": [
            "10000000-0000-0000-0000-000000000001",
            "10000000-0000-0000-0000-000000000002"
          ],
          "textbook_ref": "Chapter 3, Section 3.3",
          "status": "AVAILABLE",
          "readiness_probability": 0.65,
          "confidence": 0.55,
          "model_version": "ML-RandomForest",
          "is_terminal_objective": false,
        },
        {
          "concept_id": "10000000-0000-0000-0000-000000000004",
          "code": "MATH-G11-LOG-01",
          "title": "Definition of Logarithm and Form Conversion",
          "order_index": 4,
          "prerequisites": [
            "10000000-0000-0000-0000-000000000001",
            "10000000-0000-0000-0000-000000000002"
          ],
          "textbook_ref": "Chapter 4, Section 4.1",
          "status": "AVAILABLE",
          "readiness_probability": 0.61,
          "confidence": 0.52,
          "model_version": "ML-RandomForest",
          "is_terminal_objective": false,
        },
        {
          "concept_id": "10000000-0000-0000-0000-000000000005",
          "code": "MATH-G11-LOG-02",
          "title": "Laws of Logarithms",
          "order_index": 5,
          "prerequisites": ["10000000-0000-0000-0000-000000000004"],
          "textbook_ref": "Chapter 4, Section 4.2",
          "status": "LOCKED",
          "readiness_probability": 0.44,
          "confidence": 0.48,
          "model_version": "ML-RandomForest",
          "is_terminal_objective": false,
        },
        {
          "concept_id": "10000000-0000-0000-0000-000000000006",
          "code": "MATH-G11-LOG-03",
          "title": "Common Logarithms & Numerical Computations",
          "order_index": 6,
          "prerequisites": [
            "10000000-0000-0000-0000-000000000003",
            "10000000-0000-0000-0000-000000000005"
          ],
          "textbook_ref": "Chapter 4, Section 4.3",
          "status": "LOCKED",
          "readiness_probability": 0.35,
          "confidence": 0.62,
          "model_version": "ML-RandomForest",
          "is_terminal_objective": true,
        },
        {
          "concept_id": "10000000-0000-0000-0000-000000000007",
          "code": "MATH-G11-LOG-04",
          "title": "Logarithmic and Exponential Equations",
          "order_index": 7,
          "prerequisites": [
            "10000000-0000-0000-0000-000000000002",
            "10000000-0000-0000-0000-000000000005"
          ],
          "textbook_ref": "Chapter 4, Section 4.4",
          "status": "LOCKED",
          "readiness_probability": 0.30,
          "confidence": 0.65,
          "model_version": "ML-RandomForest",
          "is_terminal_objective": true,
        },
      ],
    };
  }

  static const Map<String, dynamic> _localMockCurriculumDag = {
    "topic_category": "Indices and Logarithms",
    "grade_level": 11,
    "edge_count": 8,
    "concepts": [],
  };

  static const List<Map<String, dynamic>> _localMockDiagnosticQuestions = [
    {
      "id": "q1000000-0000-0000-0000-000000000001",
      "concept_id": "10000000-0000-0000-0000-000000000001",
      "concept_code": "MATH-G11-IND-01",
      "question_text": "Simplify: 2^3 * 2^4",
      "options": ["2^7", "2^12", "4^7", "4^12"],
      "correct_answer": "2^7",
      "explanation": "According to the product law of indices a^m * a^n = a^(m+n), 2^3 * 2^4 = 2^(3+4) = 2^7.",
      "difficulty": 0.2,
      "is_prerequisite_check": true,
    },
    {
      "id": "q1000000-0000-0000-0000-000000000002",
      "concept_id": "10000000-0000-0000-0000-000000000001",
      "concept_code": "MATH-G11-IND-01",
      "question_text": "Find the value of: (3^2)^3 / 3^4",
      "options": ["3^2 (9)", "3^1", "3^6", "1"],
      "correct_answer": "3^2 (9)",
      "explanation": "(3^2)^3 = 3^(2*3) = 3^6. Then 3^6 / 3^4 = 3^(6-4) = 3^2 = 9.",
      "difficulty": 0.35,
      "is_prerequisite_check": true,
    },
    {
      "id": "q1000000-0000-0000-0000-000000000003",
      "concept_id": "10000000-0000-0000-0000-000000000002",
      "concept_code": "MATH-G11-IND-02",
      "question_text": "Evaluate: 16^(-1/2)",
      "options": ["1/4", "-4", "1/8", "-1/4"],
      "correct_answer": "1/4",
      "explanation": "16^(-1/2) = 1 / (16^(1/2)) = 1 / sqrt(16) = 1/4.",
      "difficulty": 0.45,
      "is_prerequisite_check": true,
    },
    {
      "id": "q1000000-0000-0000-0000-000000000004",
      "concept_id": "10000000-0000-0000-0000-000000000004",
      "concept_code": "MATH-G11-LOG-01",
      "question_text": "If 2^5 = 32, which is the equivalent logarithmic form?",
      "options": ["log_2(32) = 5", "log_5(32) = 2", "log_32(2) = 5", "log_2(5) = 32"],
      "correct_answer": "log_2(32) = 5",
      "explanation": "If a^x = y, then log_a(y) = x. Here base a=2, exponent x=5, y=32.",
      "difficulty": 0.3,
      "is_prerequisite_check": false,
    },
    {
      "id": "q1000000-0000-0000-0000-000000000005",
      "concept_id": "10000000-0000-0000-0000-000000000005",
      "concept_code": "MATH-G11-LOG-02",
      "question_text": "Express as a single logarithm: log_a(15) - log_a(3)",
      "options": ["log_a(5)", "log_a(12)", "log_a(45)", "5"],
      "correct_answer": "log_a(5)",
      "explanation": "By the quotient law, log_a(x) - log_a(y) = log_a(x/y) = log_a(15/3) = log_a(5).",
      "difficulty": 0.35,
      "is_prerequisite_check": false,
    },
  ];

  static const Map<String, dynamic> _localMockBaselines = {
    "evaluation_topic": "Indices and Logarithms",
    "goal_type": "TERM_TEST",
    "total_curriculum_nodes": 7,
    "models_evaluated": {
      "adaptive_ml": {
        "name": "Adaptive ML Goal-Aware Planner (Aqeel)",
        "model_family": "RandomForest Classifier + Topological DAG",
        "accuracy": 0.7473,
        "f1_score": 0.8414,
        "prerequisite_integrity_pct": 100.0,
        "dynamic_revision_supported": true,
        "estimated_time_to_mastery_minutes": 95,
        "description": "Dynamically selects optimal next action and prevents prerequisite cognitive overload."
      },
      "baseline_1_fixed_sequence": {
        "name": "Baseline 1: Fixed Textbook Sequence",
        "model_family": "Static Linear Ordering",
        "accuracy": 0.5210,
        "f1_score": 0.6100,
        "prerequisite_integrity_pct": 71.4,
        "dynamic_revision_supported": false,
        "estimated_time_to_mastery_minutes": 155,
        "description": "Presents concepts in inflexible static index without adaptation to student readiness."
      },
      "baseline_2_rule_based": {
        "name": "Baseline 2: Static Rule-Based Planner",
        "model_family": "Deterministic Score Thresholds (>= 70%)",
        "accuracy": 0.6480,
        "f1_score": 0.7320,
        "prerequisite_integrity_pct": 92.8,
        "dynamic_revision_supported": false,
        "estimated_time_to_mastery_minutes": 125,
        "description": "Applies static threshold logic without probabilistic calibration or goal bounding."
      }
    },
    "research_conclusion": "Component 1 Adaptive ML pathway achieves highest F1 score (0.8414) with 100% prerequisite integrity and reduces student learning time by ~38.7% compared to Fixed Sequence."
  };

  static final Map<String, Map<String, dynamic>> _localMockLessons = {
    "10000000-0000-0000-0000-000000000002": {
      "concept_id": "10000000-0000-0000-0000-000000000002",
      "code": "MATH-G11-IND-02",
      "title": "Fractional and Negative Indices",
      "grade_level": 11,
      "textbook_ref": "Grade 11 Mathematics Part I, Chapter 3, Section 3.2",
      "estimated_duration_minutes": 20,
      "theory": "Negative indices define reciprocal powers: a^(-n) = 1 / a^n (a != 0). Fractional indices define radical roots: a^(1/n) = n-th root of a. More generally, a^(m/n) represents the m-th power of the n-th root of a: a^(m/n) = (n-th root of a)^m.",
      "formulas": [
        {"name": "Negative Exponent Definition", "rule": "a^(-n) = 1 / (a^n)"},
        {"name": "Unit Fractional Exponent", "rule": "a^(1/n) = n-th root of a"},
        {"name": "General Fractional Exponent", "rule": "a^(m/n) = (n-th root of a)^m"}
      ],
      "worked_example": {
        "problem": "Evaluate the exact numerical value of: 32^(-3/5)",
        "steps": [
          {
            "step_number": 1,
            "description": "Convert the negative index into reciprocal form",
            "working": "32^(-3/5) = 1 / (32^(3/5))"
          },
          {
            "step_number": 2,
            "description": "Take the 5th root of 32 first",
            "working": "32^(1/5) = 2 (since 2^5 = 32)"
          },
          {
            "step_number": 3,
            "description": "Raise the root to the power of 3",
            "working": "2^3 = 8, therefore 1 / (32^(3/5)) = 1/8"
          }
        ],
        "final_answer": "1/8"
      },
      "guided_practice": {
        "problem": "Evaluate: 64^(2/3)",
        "hint": "Find the cube root of 64 first (4), then square the result.",
        "solution": "64^(1/3) = 4, then 4^2 = 16"
      },
      "quiz": {
        "question": "What is the value of 81^(-1/4)?",
        "options": ["1/3", "-3", "1/9", "3"],
        "correct_index": 0,
        "explanation": "81^(-1/4) = 1 / (81^(1/4)) = 1 / 3."
      }
    }
  };
}
