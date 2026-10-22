class TelemetryIndicators {
  final double timePerProblemSec;
  final double hesitationScore; // 0.0 to 1.0
  final double blindGuessingProbability; // 0.0 to 1.0
  final int consecutiveErrors;
  final double idleLatencySec;
  final String activeTopic;

  TelemetryIndicators({
    required this.timePerProblemSec,
    required this.hesitationScore,
    required this.blindGuessingProbability,
    required this.consecutiveErrors,
    required this.idleLatencySec,
    required this.activeTopic,
  });

  factory TelemetryIndicators.fromJson(Map<String, dynamic> json) {
    return TelemetryIndicators(
      timePerProblemSec: (json['time_per_problem_sec'] as num?)?.toDouble() ?? 145.0,
      hesitationScore: (json['hesitation_score'] as num?)?.toDouble() ?? 0.78,
      blindGuessingProbability: (json['blind_guessing_probability'] as num?)?.toDouble() ?? 0.65,
      consecutiveErrors: (json['consecutive_errors'] as num?)?.toInt() ?? 3,
      idleLatencySec: (json['idle_latency_sec'] as num?)?.toDouble() ?? 38.0,
      activeTopic: json['active_topic'] as String? ?? 'Quadratic Equations (Factorization)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_per_problem_sec': timePerProblemSec,
      'hesitation_score': hesitationScore,
      'blind_guessing_probability': blindGuessingProbability,
      'consecutive_errors': consecutiveErrors,
      'idle_latency_sec': idleLatencySec,
      'active_topic': activeTopic,
    };
  }
}

class ScaffoldingAction {
  final String id;
  final String title;
  final String description;
  final String actionType; // 'STREAK_SHIELD', 'STEP_HINT', 'RESET_CHALLENGE', 'CURRICULUM_ADAPT'
  final String badgeText;
  final bool isCompleted;

  ScaffoldingAction({
    required this.id,
    required this.title,
    required this.description,
    required this.actionType,
    required this.badgeText,
    this.isCompleted = false,
  });

  factory ScaffoldingAction.fromJson(Map<String, dynamic> json) {
    return ScaffoldingAction(
      id: json['id'] as String? ?? 'action-1',
      title: json['title'] as String? ?? 'Streak Protection Shield',
      description: json['description'] as String? ?? 'Your streak is protected while you solve this tough problem.',
      actionType: json['action_type'] as String? ?? 'STREAK_SHIELD',
      badgeText: json['badge_text'] as String? ?? 'Protected',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'action_type': actionType,
      'badge_text': badgeText,
      'is_completed': isCompleted,
    };
  }
}

class EngagementFeedback {
  final String studentId;
  final String affectiveState; // 'FRUSTRATED', 'FOCUSED', 'BORED', 'AT_RISK'
  final String stateLabel;
  final double confidenceScore;
  final String motivationalArchetype; // Hexad: 'Achiever', 'Player', 'Free Spirit', 'Philanthropist'
  final String situationExplanation;
  final String primaryRecommendation;
  final TelemetryIndicators telemetry;
  final List<ScaffoldingAction> scaffoldingActions;
  final int streakDays;
  final int streakFreezeShields;
  final int totalGamificationPoints;
  final Map<String, dynamic> virtualPet;

  EngagementFeedback({
    required this.studentId,
    required this.affectiveState,
    required this.stateLabel,
    required this.confidenceScore,
    required this.motivationalArchetype,
    required this.situationExplanation,
    required this.primaryRecommendation,
    required this.telemetry,
    required this.scaffoldingActions,
    required this.streakDays,
    required this.streakFreezeShields,
    required this.totalGamificationPoints,
    required this.virtualPet,
  });

  factory EngagementFeedback.fromJson(Map<String, dynamic> json) {
    return EngagementFeedback(
      studentId: json['student_id'] as String? ?? '',
      affectiveState: json['affective_state'] as String? ?? 'FRUSTRATED',
      stateLabel: json['state_label'] as String? ?? 'Stuck & Frustrated (Cognitive Strain)',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.88,
      motivationalArchetype: json['motivational_archetype'] as String? ?? 'Achiever',
      situationExplanation: json['situation_explanation'] as String? ??
          'Our AI model detected repeated attempt bursts and long hesitation pauses on Quadratic Equations.',
      primaryRecommendation: json['primary_recommendation'] as String? ??
          'Break this problem down using Step-by-Step Guided Hints. Your streak is shielded.',
      telemetry: TelemetryIndicators.fromJson(
        json['telemetry'] as Map<String, dynamic>? ?? {},
      ),
      scaffoldingActions: (json['scaffolding_actions'] as List<dynamic>?)
              ?.map((item) => ScaffoldingAction.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 4,
      streakFreezeShields: (json['streak_freeze_shields'] as num?)?.toInt() ?? 2,
      totalGamificationPoints: (json['total_gamification_points'] as num?)?.toInt() ?? 240,
      virtualPet: json['virtual_pet'] as Map<String, dynamic>? ??
          {'name': 'MathPaws', 'level': 2, 'health': 95},
    );
  }
}
