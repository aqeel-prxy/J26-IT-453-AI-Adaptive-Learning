class ApiEndpoints {
  // Base URL pointing to FastAPI server (10.0.2.2 for Android emulator, localhost for desktop/web)
  static const String baseUrl = "http://127.0.0.1:8000/api/v1";

  // Auth
  static const String login = "$baseUrl/auth/login";

  // Students
  static const String currentStudent = "$baseUrl/students/me";

  // Mathematics (Core)
  static const String topics = "$baseUrl/mathematics/topics";
  static const String concepts = "$baseUrl/mathematics/concepts";
  static const String submitAttempt = "$baseUrl/mathematics/attempts/submit";

  // Component 1: Learning Path Planning (Aqeel M.I.M - IT23244016)
  static const String learningPathCurriculum = "$baseUrl/learning-path/curriculum";
  static const String learningPathDiagnosticQuestions = "$baseUrl/learning-path/diagnostic/questions";
  static const String learningPathDiagnosticSubmit = "$baseUrl/learning-path/diagnostic/submit";
  static const String learningPathPlan = "$baseUrl/learning-path/plan";
  static const String learningPathActivityComplete = "$baseUrl/learning-path/activity/complete";
  static const String learningPathLesson = "$baseUrl/learning-path/lesson";
  static const String learningPathTelemetry = "$baseUrl/learning-path/telemetry";
  static const String learningPathBaselines = "$baseUrl/learning-path/baselines/compare";

  // Legacy Representation Endpoints (Component 1 backwards compatibility)
  static const String selectRepresentation = "$baseUrl/representation/select";
  static const String recordOutcome = "$baseUrl/representation/outcome";

  // Learner Profiling (Component 2)
  static const String learnerProfile = "$baseUrl/learner/profile";

  // Engagement & Feedback (Component 3: Dharmasena K.C.D)
  static const String studentProfile = "$baseUrl/students/profile";
  static const String engagementDashboard = "$baseUrl/engagement/dashboard";
  static const String engagementFeedback = "$baseUrl/engagement/profile-feedback";
  static const String engagementEvaluateTelemetry = "$baseUrl/engagement/telemetry/evaluate";

  // Error Diagnosis (Component 4)
  static const String diagnoseError = "$baseUrl/error/diagnose";
}
