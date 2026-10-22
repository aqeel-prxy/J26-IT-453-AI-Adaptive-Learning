import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/multiplayer_models.dart';
import '../services/multiplayer_service.dart';
import 'teacher_analytics_screen.dart';

class TeacherLiveControlScreen extends StatefulWidget {
  final MultiplayerRoom room;

  const TeacherLiveControlScreen({super.key, required this.room});

  @override
  State<TeacherLiveControlScreen> createState() => _TeacherLiveControlScreenState();
}

class _TeacherLiveControlScreenState extends State<TeacherLiveControlScreen> {
  final MultiplayerService _service = MultiplayerService();
  late MultiplayerRoom _room;

  Timer? _countdownTimer;
  Timer? _pollTimer;
  late int _secondsLeft;
  late int _totalExamSeconds;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _room = widget.room;

    // Total exam time computed from question count & per-question allocation
    _totalExamSeconds = _room.timePerQuestion * _room.questions.length;
    _secondsLeft = _totalExamSeconds;

    _startExamCountdown();
    _startLiveStudentPolling();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startExamCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft -= 1);
      } else {
        timer.cancel();
      }
    });
  }

  void _startLiveStudentPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final updated = await _service.getRoom(_room.pin);
        if (mounted) {
          setState(() => _room = updated);
        }
      } catch (_) {
        // Silent polling fail
      }
    });
  }

  Future<void> _endExamAndShowAnalytics() async {
    if (_isEnding) return;
    setState(() => _isEnding = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      _countdownTimer?.cancel();
      _pollTimer?.cancel();

      // Conclude room session on backend
      await _service.endGame(_room.pin);

      // Fetch Component 3 classroom engagement & question analytics
      final analytics = await _service.getClassroomAnalytics(_room.pin);

      if (mounted) {
        nav.pushReplacement(
          MaterialPageRoute(
            builder: (_) => TeacherAnalyticsScreen(analytics: analytics),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isEnding = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Cannot finalize session: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  List<RoomPlayer> get _studentParticipants {
    return _room.players
        .where((p) => !p.isHost && !p.name.toLowerCase().contains('(teacher)'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final students = _studentParticipants;
    final totalStudents = students.length;
    final completedStudents = students.where((s) => s.isCompleted || s.answeredCount >= _room.questions.length).length;
    final allCompleted = (totalStudents > 0 && completedStudents == totalStudents);

    // Calculate classroom average completion percentage
    final avgProgress = totalStudents > 0
        ? (students.map((s) => s.progressPercentage).reduce((a, b) => a + b) / totalStudents).round()
        : 0;

    // Calculate affective state metrics
    final focusedCount = students.where((s) => s.predictedState == 'FOCUSED').length;
    final focusPct = totalStudents > 0 ? ((focusedCount / totalStudents) * 100).round() : 100;

    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');
    final timerText = '$mins:$secs';
    final progressFraction = (_secondsLeft / _totalExamSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.darkSlate,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'EXAM MONITOR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PIN: ${_room.pin}',
              style: GoogleFonts.firaCode(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              tooltip: 'Copy PIN',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _room.pin));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN copied!'), duration: Duration(seconds: 1)),
                );
              },
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _secondsLeft <= 15 ? AppTheme.errorBg : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _secondsLeft <= 15 ? AppTheme.errorRed : AppTheme.primaryBlue,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _secondsLeft <= 15 ? AppTheme.errorRed : AppTheme.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  timerText,
                  style: GoogleFonts.firaCode(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _secondsLeft <= 15 ? AppTheme.errorRed : AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Synchronized Exam Countdown Bar
          LinearProgressIndicator(
            value: progressFraction,
            minHeight: 5,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(
              _secondsLeft <= 15 ? AppTheme.errorRed : AppTheme.accentTeal,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Exam Status Banner
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
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: allCompleted ? AppTheme.successGreen : const Color(0xFF38BDF8),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (allCompleted ? AppTheme.successGreen : const Color(0xFF38BDF8)).withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  allCompleted ? 'ALL STUDENTS COMPLETED' : 'EXAM IN PROGRESS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white70,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_room.questions.length} Questions',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _room.topic,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Grade ${_room.gradeLevel} • Students are completing quiz independently at their own pace.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Classroom Real-Time Statistics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.people_alt_rounded,
                          iconColor: AppTheme.primaryBlue,
                          title: 'Joined Students',
                          value: '$totalStudents',
                          subtitle: 'active roster',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.task_alt_rounded,
                          iconColor: AppTheme.successGreen,
                          title: 'Finished Exam',
                          value: '$completedStudents / $totalStudents',
                          subtitle: '$completedStudents submitted',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.trending_up_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Avg Completion',
                          value: '$avgProgress%',
                          subtitle: 'class progress',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.psychology_rounded,
                          iconColor: AppTheme.accentTeal,
                          title: 'Class Focus Rate',
                          value: '$focusPct%',
                          subtitle: '$focusedCount focused',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Student Roster Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school_rounded, size: 20, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            'STUDENT EXAM PROGRESS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Live Updating ⚡',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Joined Students List
                  if (students.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.hourglass_empty_rounded, size: 36, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 10),
                            Text(
                              'Waiting for student responses...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final s = students[index];
                        return _buildStudentProgressCard(s, _room.questions.length);
                      },
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Pinned Bottom Control Bar (End Session / View Analytics)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: _isEnding ? null : _endExamAndShowAnalytics,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allCompleted ? AppTheme.successGreen : AppTheme.primaryBlue,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                icon: _isEnding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(
                        allCompleted ? Icons.check_circle_rounded : Icons.analytics_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isEnding
                      ? 'Finalizing Exam Session...'
                      : (allCompleted
                          ? 'All Finished! View Classroom Analytics (Step 5)'
                          : 'End Exam & View Classroom Analytics (Step 5)'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
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
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.firaCode(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProgressCard(RoomPlayer student, int totalQuestions) {
    final isDone = student.isCompleted || student.answeredCount >= totalQuestions;
    final progressFraction = (student.progressPercentage / 100.0).clamp(0.0, 1.0);

    // Affective state badge details
    Color stateBg;
    Color stateColor;
    String stateLabel;
    IconData stateIcon;

    switch (student.predictedState.toUpperCase()) {
      case 'FRUSTRATED':
        stateBg = const Color(0xFFFEE2E2);
        stateColor = const Color(0xFFB91C1C);
        stateLabel = 'Frustrated';
        stateIcon = Icons.warning_amber_rounded;
        break;
      case 'BORED':
        stateBg = const Color(0xFFFEF3C7);
        stateColor = const Color(0xFFB45309);
        stateLabel = 'Bored';
        stateIcon = Icons.sentiment_neutral_rounded;
        break;
      case 'FOCUSED':
      default:
        stateBg = const Color(0xFFDCFCE7);
        stateColor = const Color(0xFF15803D);
        stateLabel = 'Focused';
        stateIcon = Icons.bolt_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppTheme.successGreen.withOpacity(0.4) : AppTheme.borderLight,
          width: isDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Student Name, Status & Affective State Badges
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDone ? const Color(0xFFDCFCE7) : AppTheme.primaryLight,
                child: Text(
                  isDone ? '✓' : student.name.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDone ? AppTheme.successGreen : AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Score: ${student.score} pts • ${student.correctCount} correct',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Affective State ML Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stateBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(stateIcon, size: 12, color: stateColor),
                    const SizedBox(width: 4),
                    Text(
                      stateLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: stateColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Completion Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.successGreen : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDone ? 'Completed ✓' : 'In Progress',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDone ? Colors.white : AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Completion Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppTheme.successGreen : AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Progress Detail Caption
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${student.answeredCount} of $totalQuestions completed',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${student.progressPercentage}%',
                style: GoogleFonts.firaCode(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDone ? AppTheme.successGreen : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
