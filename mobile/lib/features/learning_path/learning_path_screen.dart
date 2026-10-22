import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import 'learning_path_service.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  final _service = LearningPathService();
  bool _isLoading = true;
  Map<String, dynamic>? _plan;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    setState(() => _isLoading = true);
    final plan = await _service.getActivePlan();
    if (mounted) {
      setState(() {
        _plan = plan;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Curriculum DAG Pathway')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final nodes = (_plan!['pathway_nodes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final recActivity = _plan!['recommended_activity'] as Map<String, dynamic>? ?? {};
    final goalType = _plan!['goal_type'] as String? ?? 'COMPREHENSIVE';
    final targetConceptId = _plan!['current_concept_id'] as String? ?? '';
    final dailyMinutes = _plan!['available_daily_minutes'] as int? ?? 30;
    final gradeLevel = _plan!['grade_level'] as int? ?? 11;
    final topicCategory = _plan!['topic_category'] as String? ?? 'Indices and Logarithms';
    final isG10 = gradeLevel == 10 || topicCategory.toLowerCase().contains('quad');

    // Calculate overall stats
    final masteredCount = nodes.where((n) => n['status'] == 'MASTERED').length;
    final totalNodes = nodes.length;
    final completionPct = totalNodes > 0 ? (masteredCount / totalNodes) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Learning Pathway'),
        actions: [
          IconButton(
            tooltip: 'Research Telemetry & Baselines',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRouter.telemetry),
          ),
          IconButton(
            tooltip: 'Goal Settings',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.pushNamed(context, AppRouter.learningGoal),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlan,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Topic & Goal Header Banner
              _buildTopicHeaderCard(
                goalType,
                dailyMinutes,
                completionPct,
                masteredCount,
                totalNodes,
                gradeLevel,
                isG10,
              ),
              const SizedBox(height: 16),

              // 2. AI Recommended Next Action Card (REQ-C1-05)
              _buildRecommendationCard(recActivity, targetConceptId),
              const SizedBox(height: 24),

              // 3. Curriculum Prerequisite DAG Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Curriculum Prerequisite DAG',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Topological Dependency Roadmap • Sri Lankan G$gradeLevel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'DAG Verified 🔒',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Interactive Roadmap Nodes with connecting lines
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nodes.length,
                itemBuilder: (context, index) {
                  final node = nodes[index];
                  final isLast = index == nodes.length - 1;
                  return _buildPathNodeItem(node, isLast);
                },
              ),
              const SizedBox(height: 24),

              // Diagnostic Re-assessment prompt
              _buildDiagnosticBanner(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicHeaderCard(
    String goalType,
    int dailyMinutes,
    double completionPct,
    int masteredCount,
    int totalNodes,
    int gradeLevel,
    bool isG10,
  ) {
    final topicTitle = isG10 ? 'Quadratic Equations' : 'Indices & Logarithms';
    final topicSinhala = isG10 ? 'වර්ගජ සමීකරණ' : 'දර්ශක හා ලඝුගණක';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Grade $gradeLevel Mathematics',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goalType == 'TERM_TEST' ? AppTheme.warningAmber : AppTheme.accentTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goalType == 'TERM_TEST' ? '⚡ Term-Test Blitz' : '🎓 Comprehensive',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            topicTitle,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '$topicSinhala • $totalNodes Concepts in Prerequisite DAG',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Curriculum Mastery',
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '$masteredCount of $totalNodes Mastered (${(completionPct * 100).toInt()}%)',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionPct,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.alarm, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'Target: $dailyMinutes mins/day • Dynamic ML Revision Active',
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec, String targetConceptId) {
    final activityType = rec['activity_type'] as String? ?? 'LESSON_UNIT';
    final conceptTitle = rec['concept_title'] as String? ?? 'Target Concept';
    final rationale = rec['rationale'] as String? ?? 'Recommended action generated by planning model.';
    final duration = rec['estimated_duration_minutes'] as int? ?? 15;

    Color badgeColor = AppTheme.primaryBlue;
    IconData actionIcon = Icons.menu_book;

    if (activityType == 'REVISE_PREREQUISITE') {
      badgeColor = AppTheme.errorRed;
      actionIcon = Icons.warning_amber;
    } else if (activityType == 'WORKED_EXAMPLE') {
      badgeColor = AppTheme.accentTeal;
      actionIcon = Icons.lightbulb_outline;
    } else if (activityType == 'PRACTICE') {
      badgeColor = AppTheme.warningAmber;
      actionIcon = Icons.fitness_center;
    } else if (activityType == 'PROCEED_DIRECT') {
      badgeColor = AppTheme.successGreen;
      actionIcon = Icons.arrow_forward;
    }


    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: badgeColor.withOpacity(0.35), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(actionIcon, color: badgeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'AI RECOMMENDED NEXT STEP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: badgeColor,
                ),
              ),
              const Spacer(),
              Text(
                '$duration min',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conceptTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rationale,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          ElevatedButton.icon(
            onPressed: () {
              final cid = targetConceptId.isNotEmpty ? targetConceptId : "10000000-0000-0000-0000-000000000002";
              final currentGoal = _plan?['goal_type'] as String? ?? 'TERM_TEST';
              final currentGrade = _plan?['grade_level'] as int? ?? 11;
              Navigator.pushNamed(
                context,
                AppRouter.lessonUnit,
                arguments: {
                  'conceptId': cid,
                  'goalType': currentGoal,
                  'gradeLevel': currentGrade,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: badgeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_circle_fill, size: 20),
            label: Text(
              'Start Recommended Activity',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathNodeItem(Map<String, dynamic> node, bool isLast) {
    final status = node['status'] as String? ?? 'AVAILABLE';
    final readiness = (node['readiness_probability'] as num?)?.toDouble() ?? 0.5;
    final title = node['title'] as String? ?? 'Concept';
    final code = node['code'] as String? ?? '';
    final textbook = node['textbook_ref'] as String? ?? '';
    final order = node['order_index'] as int? ?? 1;
    final isTerminal = node['is_terminal_objective'] as bool? ?? false;
    final conceptId = node['concept_id'] as String? ?? '';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'MASTERED':
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        statusText = 'MASTERED';
        break;
      case 'RECOMMENDED_NEXT':
        statusColor = AppTheme.primaryBlue;
        statusIcon = Icons.play_arrow;
        statusText = 'ACTIVE FOCUS';
        break;
      case 'REVISION_REQUIRED':
        statusColor = AppTheme.warningAmber;
        statusIcon = Icons.error_outline;
        statusText = 'REVISION NEEDED';
        break;
      case 'LOCKED':
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.lock_outline;
        statusText = 'PREREQUISITE LOCKED';
        break;
      default:
        statusColor = AppTheme.accentTeal;
        statusIcon = Icons.circle_outlined;
        statusText = 'AVAILABLE';
    }

    final isClickable = status != 'LOCKED';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline connector column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(statusIcon, color: statusColor, size: 16),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: status == 'MASTERED' ? AppTheme.successGreen : AppTheme.borderLight,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Node Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: isClickable
                    ? () {
                        final currentGoal = _plan?['goal_type'] as String? ?? 'TERM_TEST';
                        final currentGrade = _plan?['grade_level'] as int? ?? 11;
                        Navigator.pushNamed(
                          context,
                          AppRouter.lessonUnit,
                          arguments: {
                            'conceptId': conceptId,
                            'goalType': currentGoal,
                            'gradeLevel': currentGrade,
                          },
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: status == 'RECOMMENDED_NEXT' ? AppTheme.primaryBlue : AppTheme.borderLight,
                      width: status == 'RECOMMENDED_NEXT' ? 1.8 : 1.0,
                    ),
                    boxShadow: status == 'RECOMMENDED_NEXT'
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.015),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                          if (isTerminal)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.warningBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🎯 Terminal Goal',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.warningAmber,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Step $order: $title',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: status == 'LOCKED' ? AppTheme.textMuted : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        '$code • $textbook',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Readiness Probability Meter
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: readiness,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  readiness >= 0.70
                                      ? AppTheme.successGreen
                                      : (readiness >= 0.50 ? AppTheme.warningAmber : AppTheme.errorRed),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Readiness: ${(readiness * 100).toInt()}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.psychology, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want to recalibrate your pathway?',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Take the 5-question curriculum diagnostic test.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.diagnostic);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Test', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
