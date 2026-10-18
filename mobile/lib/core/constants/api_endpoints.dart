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

  // Multiplayer Quiz Arena (Component 3)
  static const String multiplayerCreate = "$baseUrl/multiplayer/create";
  static const String multiplayerRoom = "$baseUrl/multiplayer/room";
  static const String multiplayerJoin = "$baseUrl/multiplayer/join";
  static const String multiplayerAddBot = "$baseUrl/multiplayer/add-bot";
  static const String multiplayerStart = "$baseUrl/multiplayer/start";
  static const String multiplayerSubmitAnswer = "$baseUrl/multiplayer/submit-answer";
  static const String multiplayerNextQuestion = "$baseUrl/multiplayer/next-question";
  static const String multiplayerAnalytics = "$baseUrl/multiplayer/analytics";
  static const String multiplayerParseCsv = "$baseUrl/multiplayer/parse-csv";
  static const String multiplayerWsBase = "ws://127.0.0.1:8000/api/v1/multiplayer/ws";

  // Error Diagnosis (Component 4)
  static const String diagnoseError = "$baseUrl/error/diagnose";
}
