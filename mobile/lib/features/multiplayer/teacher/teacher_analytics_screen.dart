import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/multiplayer_models.dart';
import 'teacher_setup_screen.dart';

class TeacherAnalyticsScreen extends StatelessWidget {
  final ClassroomAnalytics analytics;

  const TeacherAnalyticsScreen({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    // Exclude host/teacher so only actual student participants and their states are displayed
    final participants = analytics.allPlayers
        .where((p) => !p.isHost && !p.name.toLowerCase().contains('(teacher)'))
        .toList();

    final top1 = participants.isNotEmpty ? participants[0] : null;
    final top2 = participants.length > 1 ? participants[1] : null;
    final top3 = participants.length > 2 ? participants[2] : null;

    final mlSummary = analytics.mlEngagementSummary;
    final focusedPct = (mlSummary['focused_percentage'] as num?)?.toDouble() ?? 70.0;
    final frustratedPct = (mlSummary['frustrated_percentage'] as num?)?.toDouble() ?? 20.0;
    final boredPct = (mlSummary['boredom_percentage'] as num?)?.toDouble() ?? 10.0;
    final recommendation = mlSummary['adaptive_recommendation'] as String? ??
        'Optimal classroom engagement! Majority of students demonstrated active flow state.';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Classroom Analytics • Step 5',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Analytics',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Classroom analytics report ready for export.'),
                  backgroundColor: AppTheme.primaryBlue,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overview Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)),
                        ),
                        child: Text(
                          'ROOM PIN: ${analytics.pin}',
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        '${participants.length} Students',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    analytics.topic,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricTile(
                        'Class Accuracy',
                        '${analytics.classAccuracyPercentage.toStringAsFixed(1)}%',
                        Icons.check_circle_outline,
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      _buildMetricTile(
                        'Average Score',
                        analytics.classAverageScore.toStringAsFixed(0),
                        Icons.bolt,
                        const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 12),
                      _buildMetricTile(
                        'Cognitive Strain',
                        frustratedPct > 30 ? 'ELEVATED' : 'STABLE',
                        Icons.psychology,
                        frustratedPct > 30 ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top Podium Widget
            Text(
              '🏆 CLASSROOM PODIUM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            _buildPodiumView(top1, top2, top3),
            const SizedBox(height: 24),

            // Component 3 ML Engagement & Frustration Summary
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'AI INSIGHTS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ML Engagement & Frustration Summary',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breakdown Meters
                  _buildStateMeter('Deep Flow / Focused', focusedPct, const Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  _buildStateMeter('Cognitive Strain / Frustration', frustratedPct, const Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  _buildStateMeter('Passive / Boredom', boredPct, const Color(0xFF64748B)),
                  const Divider(height: 28),

                  // Adaptive Recommendation Box
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Component 3 Adaptive Recommendation',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.darkSlate,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommendation,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                height: 1.45,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Question Difficulty & Cognitive Load
            if (analytics.questionPerformance.isNotEmpty) ...[
              Text(
                'QUESTION PERFORMANCE & COGNITIVE LOAD',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              ...analytics.questionPerformance.map((q) => _buildQuestionItem(q)),
              const SizedBox(height: 24),
            ],

            // Full Classroom Leaderboard (Student Participants Only)
            Text(
              'ALL PARTICIPANTS (${participants.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: participants.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No student participants joined this session.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: participants.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, idx) {
                        final p = participants[idx];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: idx == 0
                          ? const Color(0xFFF59E0B)
                          : idx == 1
                              ? const Color(0xFF94A3B8)
                              : idx == 2
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFFE2E8F0),
                      child: Text(
                        '#${idx + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: idx < 3 ? Colors.white : AppTheme.darkSlate,
                        ),
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'State: ${p.predictedState}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: p.predictedState == 'FOCUSED'
                            ? const Color(0xFF16A34A)
                            : p.predictedState == 'FRUSTRATED'
                                ? const Color(0xFFDC2626)
                                : AppTheme.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '${p.score} pts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const TeacherSetupScreen()),
                  (route) => route.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Host Another Classroom Match',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Back to Dashboard',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumView(RoomPlayer? top1, RoomPlayer? top2, RoomPlayer? top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 2nd Place
          _buildPodiumStep(
            player: top2,
            rank: 2,
            height: 90,
            color: const Color(0xFF94A3B8),
            medal: '🥈',
          ),
          // 1st Place
          _buildPodiumStep(
            player: top1,
            rank: 1,
            height: 125,
            color: const Color(0xFFF59E0B),
            medal: '👑',
          ),
          // 3rd Place
          _buildPodiumStep(
            player: top3,
            rank: 3,
            height: 70,
            color: const Color(0xFFB45309),
            medal: '🥉',
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep({
    required RoomPlayer? player,
    required int rank,
    required double height,
    required Color color,
    required String medal,
  }) {
    final name = player?.name ?? '—';
    final score = player != null ? '${player.score} pts' : '—';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          score,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateMeter(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(Map<String, dynamic> q) {
    final idx = (q['question_index'] as num?)?.toInt() ?? 0;
    final text = q['question_text'] as String? ?? 'Question ${idx + 1}';
    final acc = (q['accuracy_percentage'] as num?)?.toDouble() ?? 0.0;
    final avgTime = (q['avg_response_time_sec'] as num?)?.toDouble() ?? 0.0;
    final load = q['cognitive_load'] as String? ?? 'OPTIMAL';

    final loadColor = load == 'HIGH'
        ? const Color(0xFFEF4444)
        : load == 'OPTIMAL'
            ? const Color(0xFF10B981)
            : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.darkSlate,
                child: Text(
                  'Q${idx + 1}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: loadColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  load,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: loadColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Correct: ${acc.toStringAsFixed(1)}%',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
              ),
              Text(
                'Avg Latency: ${avgTime.toStringAsFixed(1)}s',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
