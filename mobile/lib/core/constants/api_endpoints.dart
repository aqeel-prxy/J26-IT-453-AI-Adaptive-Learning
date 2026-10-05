class ApiEndpoints {
  // Base URL pointing to local FastAPI server (10.0.2.2 for Android Emulator access to localhost)
  static const String baseUrl = "http://10.0.2.2:8000/api/v1";

  // Auth
  static const String login = "$baseUrl/auth/login";

  // Students
  static const String currentStudent = "$baseUrl/students/me";

  // Mathematics
  static const String topics = "$baseUrl/mathematics/topics";
  static const String concepts = "$baseUrl/mathematics/concepts";
  static const String submitAttempt = "$baseUrl/mathematics/attempts/submit";

  // Learner Profiling (Component 2)
  static const String learnerProfile = "$baseUrl/learner/profile";

  // Adaptive Representation (Component 1)
  static const String selectRepresentation = "$baseUrl/representation/select";
  static const String recordOutcome = "$baseUrl/representation/outcome";

  // Error Diagnosis (Component 4)
  static const String diagnoseError = "$baseUrl/error/diagnose";

  // Engagement (Component 3)
  static const String engagementDashboard = "$baseUrl/engagement/dashboard";
}
