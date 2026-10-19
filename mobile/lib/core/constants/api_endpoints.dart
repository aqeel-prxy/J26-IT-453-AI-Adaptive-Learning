import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Base URL pointing to FastAPI server:
  // - 10.0.2.2: Host loopback inside Android Emulator
  // - 127.0.0.1: Windows / macOS / Linux / Web
  // (If presenting on a physical Android phone over Wi-Fi, change host to your laptop's Wi-Fi IP)
  static String get host {
    if (kIsWeb) return "127.0.0.1";
    if (Platform.isAndroid) return "10.0.2.2";
    return "127.0.0.1";
  }

  static String get baseUrl => "http://$host:8000/api/v1";

  // Auth
  static String get login => "$baseUrl/auth/login";

  // Students
  static String get currentStudent => "$baseUrl/students/me";

  // Mathematics (Core)
  static String get topics => "$baseUrl/mathematics/topics";
  static String get concepts => "$baseUrl/mathematics/concepts";
  static String get submitAttempt => "$baseUrl/mathematics/attempts/submit";

  // Component 1: Learning Path Planning (Aqeel M.I.M - IT23244016)
  static String get learningPathCurriculum => "$baseUrl/learning-path/curriculum";
  static String get learningPathDiagnosticQuestions => "$baseUrl/learning-path/diagnostic/questions";
  static String get learningPathDiagnosticSubmit => "$baseUrl/learning-path/diagnostic/submit";
  static String get learningPathPlan => "$baseUrl/learning-path/plan";
  static String get learningPathActivityComplete => "$baseUrl/learning-path/activity/complete";
  static String get learningPathLesson => "$baseUrl/learning-path/lesson";
  static String get learningPathTelemetry => "$baseUrl/learning-path/telemetry";
  static String get learningPathBaselines => "$baseUrl/learning-path/baselines/compare";

  // Legacy Representation Endpoints (Component 1 backwards compatibility)
  static String get selectRepresentation => "$baseUrl/representation/select";
  static String get recordOutcome => "$baseUrl/representation/outcome";

  // Learner Profiling (Component 2)
  static String get learnerProfile => "$baseUrl/learner/profile";

  // Engagement (Component 3)
  static String get engagementDashboard => "$baseUrl/engagement/dashboard";

  // Error Diagnosis (Component 4)
  static String get diagnoseError => "$baseUrl/error/diagnose";
}

