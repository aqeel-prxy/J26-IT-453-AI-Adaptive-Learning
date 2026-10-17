import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import 'models/user_profile.dart';
import 'models/engagement_feedback.dart';

class AvatarPreset {
  final String id;
  final String name;
  final String emoji;
  final String subtitle;
  final int primaryColorValue;

  const AvatarPreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.subtitle,
    required this.primaryColorValue,
  });
}

class ProfileService {
  final ApiClient apiClient;

  ProfileService({ApiClient? client}) : apiClient = client ?? ApiClient();

  static const List<AvatarPreset> availableAvatars = [
    AvatarPreset(
      id: 'fox_math',
      name: 'Math Fox',
      emoji: '🦊',
      subtitle: 'Sharp & Agile Problem Solver',
      primaryColorValue: 0xFFF97316,
    ),
    AvatarPreset(
      id: 'owl_scholar',
      name: 'Scholar Owl',
      emoji: '🦉',
      subtitle: 'Wise Master of Algebraic Proofs',
      primaryColorValue: 0xFF4F46E5,
    ),
    AvatarPreset(
      id: 'robot_tech',
      name: 'Cyber Bot',
      emoji: '🤖',
      subtitle: 'Systematic Algorithm Thinker',
      primaryColorValue: 0xFF06B6D4,
    ),
    AvatarPreset(
      id: 'cosmic_star',
      name: 'Star Cadet',
      emoji: '⭐',
      subtitle: 'Speed & Persistence Champion',
      primaryColorValue: 0xFFF59E0B,
    ),
    AvatarPreset(
      id: 'panda_zen',
      name: 'Zen Panda',
      emoji: '🐼',
      subtitle: 'Calm & Focused Mindset',
      primaryColorValue: 0xFF10B981,
    ),
    AvatarPreset(
      id: 'lion_brave',
      name: 'Brave Lion',
      emoji: '🦁',
      subtitle: 'Resilient Math Challenger',
      primaryColorValue: 0xFF8B5CF6,
    ),
  ];

  static UserProfile _cachedProfile = UserProfile(
    studentId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    anonymizedCode: 'STU_HASH_9A4F21',
    fullName: 'Kavindu Dharmasena',
    email: 'kavindu.dharmasena@example.lk',
    gradeLevel: 10,
    school: 'Central College, Kandy',
    district: 'Central Province',
    avatarId: 'fox_math',
    motivationalArchetype: 'Achiever',
    preferredGoal: 'TERM_TEST',
  );

  static String _currentSimulatedState = 'FRUSTRATED';

  Future<UserProfile> getUserProfile() async {
    try {
      final data = await apiClient.get(ApiEndpoints.currentStudent);
      if (data.containsKey('student_id')) {
        _cachedProfile = _cachedProfile.copyWith(
          email: data['email'] as String?,
          gradeLevel: (data['grade_level'] as num?)?.toInt(),
        );
      }
    } catch (_) {
      // Fallback to local profile cache
    }
    return _cachedProfile;
  }

  Future<UserProfile> updateProfile(UserProfile updated) async {
    _cachedProfile = updated;
    try {
      // Attempt to notify backend
      await apiClient.post(
        '${ApiEndpoints.baseUrl}/students/profile',
        updated.toJson(),
      );
    } catch (_) {
      // Offline fallback: keep local cache updated
    }
    return _cachedProfile;
  }

  Future<EngagementFeedback> getEngagementFeedback({String? overrideState}) async {
    final state = overrideState ?? _currentSimulatedState;
    _currentSimulatedState = state;

    try {
      final endpoint = '${ApiEndpoints.baseUrl}/engagement/profile-feedback/${_cachedProfile.studentId}?state=$state';
      final res = await apiClient.get(endpoint);
      return EngagementFeedback.fromJson(res);
    } catch (_) {
      return _generateMockFeedback(state);
    }
  }

  EngagementFeedback _generateMockFeedback(String state) {
    switch (state) {
      case 'FOCUSED':
        return EngagementFeedback(
          studentId: _cachedProfile.studentId,
          affectiveState: 'FOCUSED',
          stateLabel: 'Focused & In Deep Flow',
          confidenceScore: 0.94,
          motivationalArchetype: _cachedProfile.motivationalArchetype,
          situationExplanation:
              'Clickstream telemetry shows continuous focus: optimal problem latency (42s) with steady deliberation and zero blind guessing.',
          primaryRecommendation:
              'You are in an optimal learning zone! Maintain this pace to maximize concept consolidation.',
          telemetry: TelemetryIndicators(
            timePerProblemSec: 42.0,
            hesitationScore: 0.14,
            blindGuessingProbability: 0.05,
            consecutiveErrors: 0,
            idleLatencySec: 4.5,
            activeTopic: 'Indices & Logarithms (Power Rules)',
          ),
          scaffoldingActions: [
            ScaffoldingAction(
              id: 'focus-1',
              title: 'Flow-State Multiplier Active',
              description: 'Earning 1.5x Mastery Points for consistent conceptual responses.',
              actionType: 'STREAK_SHIELD',
              badgeText: '1.5x XP Active',
            ),
            ScaffoldingAction(
              id: 'focus-2',
              title: 'Unlock Peer Challenge Mode',
              description: 'Test your calculation speed against an asynchronous peer challenge.',
              actionType: 'RESET_CHALLENGE',
              badgeText: 'Challenge Ready',
            ),
          ],
          streakDays: 4,
          streakFreezeShields: 2,
          totalGamificationPoints: 310,
          virtualPet: {'name': 'MathPaws', 'level': 2, 'health': 98},
        );

      case 'BORED':
        return EngagementFeedback(
          studentId: _cachedProfile.studentId,
          affectiveState: 'BORED',
          stateLabel: 'Boredom / Inattention Detected',
          confidenceScore: 0.86,
          motivationalArchetype: _cachedProfile.motivationalArchetype,
          situationExplanation:
              'Sub-10s question dismissals combined with 80s idle gaps indicate loss of cognitive stimulation. Tasks may feel repetitive.',
          primaryRecommendation:
              'Re-energize with a 60-second Quick Reset Challenge before returning to main curriculum.',
          telemetry: TelemetryIndicators(
            timePerProblemSec: 14.0,
            hesitationScore: 0.08,
            blindGuessingProbability: 0.76,
            consecutiveErrors: 1,
            idleLatencySec: 78.0,
            activeTopic: 'Simple Factorization of Expressions',
          ),
          scaffoldingActions: [
            ScaffoldingAction(
              id: 'bored-1',
              title: '60s Quick Reset Mini-Puzzle',
              description: 'Solve 3 fast mental math puzzles to wake up analytical reflexes.',
              actionType: 'RESET_CHALLENGE',
              badgeText: 'Brain Reset',
            ),
            ScaffoldingAction(
              id: 'bored-2',
              title: 'Fast-Forward to Advanced Concept',
              description: 'Jump directly to Quadratic Formula challenges to increase difficulty.',
              actionType: 'CURRICULUM_ADAPT',
              badgeText: 'Level Up',
            ),
          ],
          streakDays: 4,
          streakFreezeShields: 2,
          totalGamificationPoints: 240,
          virtualPet: {'name': 'MathPaws', 'level': 2, 'health': 88},
        );

      case 'AT_RISK':
        return EngagementFeedback(
          studentId: _cachedProfile.studentId,
          affectiveState: 'AT_RISK',
          stateLabel: 'At-Risk of Task Abandonment',
          confidenceScore: 0.92,
          motivationalArchetype: _cachedProfile.motivationalArchetype,
          situationExplanation:
              'High interaction latency (210s) with 4 consecutive incorrect attempts and erratic click rates indicates cognitive overload.',
          primaryRecommendation:
              'Streak Shield applied! Take a 2-minute pause. We will break this question down when you return.',
          telemetry: TelemetryIndicators(
            timePerProblemSec: 215.0,
            hesitationScore: 0.95,
            blindGuessingProbability: 0.88,
            consecutiveErrors: 4,
            idleLatencySec: 125.0,
            activeTopic: 'Completing the Square - Quadratic Roots',
          ),
          scaffoldingActions: [
            ScaffoldingAction(
              id: 'risk-1',
              title: 'Emergency Streak Shield Engaged',
              description: 'Your 4-day streak is guaranteed safe. Take your time without penalty.',
              actionType: 'STREAK_SHIELD',
              badgeText: 'Shield Active 🛡️',
            ),
            ScaffoldingAction(
              id: 'risk-2',
              title: 'Visual Representation Pivot',
              description: 'Switch from algebraic formula to geometric area tile representation.',
              actionType: 'CURRICULUM_ADAPT',
              badgeText: 'Visual Mode',
            ),
            ScaffoldingAction(
              id: 'risk-3',
              title: 'Calibrate Lesson with Member 4',
              description: 'Curriculum sequencer prompted to serve intermediate prerequisite first.',
              actionType: 'STEP_HINT',
              badgeText: 'Scaffold Ready',
            ),
          ],
          streakDays: 4,
          streakFreezeShields: 1,
          totalGamificationPoints: 240,
          virtualPet: {'name': 'MathPaws', 'level': 2, 'health': 75},
        );

      case 'FRUSTRATED':
      default:
        return EngagementFeedback(
          studentId: _cachedProfile.studentId,
          affectiveState: 'FRUSTRATED',
          stateLabel: 'Cognitive Strain & Frustration Detected',
          confidenceScore: 0.89,
          motivationalArchetype: _cachedProfile.motivationalArchetype,
          situationExplanation:
              'Multiple attempt bursts within 2 minutes accompanied by high hesitation (52s) on Quadratic Equations. Pattern reflects cognitive struggle without comprehension.',
          primaryRecommendation:
              'Streak Protection is engaged. Instead of random guessing, follow Step-by-Step Guided Hints to unblock your understanding.',
          telemetry: TelemetryIndicators(
            timePerProblemSec: 148.0,
            hesitationScore: 0.81,
            blindGuessingProbability: 0.68,
            consecutiveErrors: 3,
            idleLatencySec: 44.0,
            activeTopic: 'Quadratic Equations (Factorization)',
          ),
          scaffoldingActions: [
            ScaffoldingAction(
              id: 'frust-1',
              title: 'Streak Protection Active 🛡️',
              description: 'System identified genuine struggle on difficult math. Your 4-day streak will not break.',
              actionType: 'STREAK_SHIELD',
              badgeText: 'Streak Saved',
            ),
            ScaffoldingAction(
              id: 'frust-2',
              title: 'Step-by-Step Guided Hint',
              description: 'Deconstruct the quadratic expression into 3 sub-steps (find product a×c, find factors, split middle term).',
              actionType: 'STEP_HINT',
              badgeText: '3 Sub-Steps',
            ),
            ScaffoldingAction(
              id: 'frust-3',
              title: 'Notify Curriculum Sequencer (Member 4)',
              description: 'Signaled Member 4 recommendation model that student needs scaffolding on factoring polynomials.',
              actionType: 'CURRICULUM_ADAPT',
              badgeText: 'Path Adapted',
            ),
          ],
          streakDays: 4,
          streakFreezeShields: 2,
          totalGamificationPoints: 240,
          virtualPet: {'name': 'MathPaws', 'level': 2, 'health': 92},
        );
    }
  }
}
