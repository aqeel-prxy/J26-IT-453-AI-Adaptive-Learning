class QuizQuestion {
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String topic;
  final String difficulty;

  QuizQuestion({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.topic,
    required this.difficulty,
  });

  bool get isMcq => options.isNotEmpty;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionId: json['question_id'] as String? ?? 'q1',
      questionText: json['question_text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctIndex: (json['correct_index'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
      topic: json['topic'] as String? ?? 'Mathematics',
      difficulty: json['difficulty'] as String? ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_text': questionText,
      'options': options,
      'correct_index': correctIndex,
      'explanation': explanation,
      'topic': topic,
      'difficulty': difficulty,
    };
  }
}

class RoomPlayer {
  final String playerId;
  final String name;
  final String avatar;
  int score;
  int correctCount;
  final bool isHost;
  final bool isReady;
  int? lastResponseTimeMs;
  String predictedState; // FOCUSED, FRUSTRATED, BORED, AT_RISK
  int answeredCount;
  int progressPercentage;
  bool isCompleted;

  RoomPlayer({
    required this.playerId,
    required this.name,
    this.avatar = 'fox_math',
    this.score = 0,
    this.correctCount = 0,
    this.isHost = false,
    this.isReady = true,
    this.lastResponseTimeMs,
    this.predictedState = 'FOCUSED',
    this.answeredCount = 0,
    this.progressPercentage = 0,
    this.isCompleted = false,
  });

  factory RoomPlayer.fromJson(Map<String, dynamic> json) {
    return RoomPlayer(
      playerId: json['player_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Player',
      avatar: json['avatar'] as String? ?? 'fox_math',
      score: (json['score'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      isHost: json['is_host'] as bool? ?? false,
      isReady: json['is_ready'] as bool? ?? true,
      lastResponseTimeMs: (json['last_response_time_ms'] as num?)?.toInt(),
      predictedState: json['predicted_state'] as String? ?? 'FOCUSED',
      answeredCount: (json['answered_count'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'name': name,
      'avatar': avatar,
      'score': score,
      'correct_count': correctCount,
      'is_host': isHost,
      'is_ready': isReady,
      'last_response_time_ms': lastResponseTimeMs,
      'predicted_state': predictedState,
      'answered_count': answeredCount,
      'progress_percentage': progressPercentage,
      'is_completed': isCompleted,
    };
  }
}

class MultiplayerRoom {
  final String pin;
  final String roomType; // STUDENT_PEER, TEACHER_CLASSROOM
  String status; // LOBBY, IN_PROGRESS, FINISHED
  final String topic;
  final int gradeLevel;
  final int questionCount;
  int currentQuestionIndex;
  final int timePerQuestion;
  final bool mlInsightsEnabled;
  List<RoomPlayer> players;
  final int maxPlayers;
  final String qrCodeData;
  List<QuizQuestion> questions;
  QuizQuestion? currentQuestion;

  MultiplayerRoom({
    required this.pin,
    required this.roomType,
    required this.status,
    required this.topic,
    required this.gradeLevel,
    required this.questionCount,
    this.currentQuestionIndex = 0,
    required this.timePerQuestion,
    required this.mlInsightsEnabled,
    required this.players,
    required this.maxPlayers,
    required this.qrCodeData,
    this.questions = const [],
    this.currentQuestion,
  });

  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    final questionsList = (json['questions'] as List<dynamic>?)
            ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    final playersList = (json['players'] as List<dynamic>?)
            ?.map((p) => RoomPlayer.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    final currQJson = json['current_question'] as Map<String, dynamic>?;
    final currQ = currQJson != null
        ? QuizQuestion.fromJson(currQJson)
        : (questionsList.isNotEmpty ? questionsList[0] : null);

    return MultiplayerRoom(
      pin: json['pin'] as String? ?? '0000',
      roomType: json['room_type'] as String? ?? 'STUDENT_PEER',
      status: json['status'] as String? ?? 'LOBBY',
      topic: json['topic'] as String? ?? 'Quadratic Equations',
      gradeLevel: (json['grade_level'] as num?)?.toInt() ?? 10,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 5,
      currentQuestionIndex: (json['current_question_index'] as num?)?.toInt() ?? 0,
      timePerQuestion: (json['time_per_question'] as num?)?.toInt() ?? 30,
      mlInsightsEnabled: json['ml_insights_enabled'] as bool? ?? true,
      players: playersList,
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 5,
      qrCodeData: json['qr_code_data'] as String? ?? '',
      questions: questionsList,
      currentQuestion: currQ,
    );
  }
}

class AnswerOutcome {
  final bool isCorrect;
  final int earnedScore;
  final int correctIndex;
  final String explanation;
  final List<RoomPlayer> leaderboard;

  AnswerOutcome({
    required this.isCorrect,
    required this.earnedScore,
    required this.correctIndex,
    required this.explanation,
    required this.leaderboard,
  });

  factory AnswerOutcome.fromJson(Map<String, dynamic> json) {
    return AnswerOutcome(
      isCorrect: json['is_correct'] as bool? ?? false,
      earnedScore: (json['earned_score'] as num?)?.toInt() ?? 0,
      correctIndex: (json['correct_index'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((p) => RoomPlayer.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ClassroomAnalytics {
  final String pin;
  final String topic;
  final int totalStudents;
  final double classAverageScore;
  final double classAccuracyPercentage;
  final List<RoomPlayer> podium;
  final List<RoomPlayer> allPlayers;
  final Map<String, dynamic> mlEngagementSummary;
  final List<Map<String, dynamic>> questionPerformance;

  ClassroomAnalytics({
    required this.pin,
    required this.topic,
    required this.totalStudents,
    required this.classAverageScore,
    required this.classAccuracyPercentage,
    required this.podium,
    required this.allPlayers,
    required this.mlEngagementSummary,
    required this.questionPerformance,
  });

  factory ClassroomAnalytics.fromJson(Map<String, dynamic> json) {
    return ClassroomAnalytics(
      pin: json['pin'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      classAverageScore: (json['class_average_score'] as num?)?.toDouble() ?? 0.0,
      classAccuracyPercentage: (json['class_accuracy_percentage'] as num?)?.toDouble() ?? 0.0,
      podium: (json['podium'] as List<dynamic>?)
              ?.map((p) => RoomPlayer.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      allPlayers: (json['all_players'] as List<dynamic>?)
              ?.map((p) => RoomPlayer.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      mlEngagementSummary: json['ml_engagement_summary'] as Map<String, dynamic>? ?? {},
      questionPerformance: (json['question_performance'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}
