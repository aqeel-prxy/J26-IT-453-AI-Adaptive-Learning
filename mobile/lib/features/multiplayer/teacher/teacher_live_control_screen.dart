import 'dart:async';
import 'package:flutter/material.dart';
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
  late int _currentQuestionIndex;

  Timer? _countdownTimer;
  late int _secondsLeft;
  late int _totalSeconds;

  int _simulatedAnsweredCount = 0;
  bool _isAdvancing = false;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _currentQuestionIndex = _room.currentQuestionIndex;
    _totalSeconds = _room.timePerQuestion;
    _secondsLeft = _totalSeconds;

    _startQuestionControl();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startQuestionControl() {
    _secondsLeft = _totalSeconds;
    _simulatedAnsweredCount = 0;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft -= 1;
          // Simulate student answers arriving over time
          final totalStudents = _room.players.where((p) => !p.isHost).length;
          if (_simulatedAnsweredCount < totalStudents && _secondsLeft < _totalSeconds - 2) {
            _simulatedAnsweredCount = (_simulatedAnsweredCount + 1).clamp(0, totalStudents);
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _advanceNext() async {
    setState(() => _isAdvancing = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (_currentQuestionIndex + 1 < _room.questions.length) {
        final updated = await _service.nextQuestion(_room.pin);
        if (mounted) {
          setState(() {
            _room = updated;
            _currentQuestionIndex = updated.currentQuestionIndex;
            _isAdvancing = false;
          });
          _startQuestionControl();
        }
      } else {
        // Last question finished -> Step 5 Classroom Analytics
        _countdownTimer?.cancel();
        final analytics = await _service.getClassroomAnalytics(_room.pin);
        if (mounted) {
          nav.pushReplacement(
            MaterialPageRoute(
              builder: (_) => TeacherAnalyticsScreen(analytics: analytics),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdvancing = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Cannot advance: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  QuizQuestion? get _currentQuestion {
    if (_currentQuestionIndex < _room.questions.length) {
      return _room.questions[_currentQuestionIndex];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    final totalStudents = _room.players.where((p) => !p.isHost).length;
    final isLastQuestion = (_currentQuestionIndex + 1 == _room.questions.length);
    final progressFraction = (_secondsLeft / _totalSeconds).clamp(0.0, 1.0);

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
                'HOST CONTROL',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PIN: ${_room.pin}',
              style: GoogleFonts.firaCode(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _secondsLeft <= 5 ? AppTheme.errorBg : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _secondsLeft <= 5 ? AppTheme.errorRed : AppTheme.primaryBlue,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 16, color: _secondsLeft <= 5 ? AppTheme.errorRed : AppTheme.primaryBlue),
                const SizedBox(width: 4),
                Text(
                  '${_secondsLeft}s',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _secondsLeft <= 5 ? AppTheme.errorRed : AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: q == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Synchronized Progress Bar
                LinearProgressIndicator(
                  value: progressFraction,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _secondsLeft <= 5 ? AppTheme.errorRed : AppTheme.primaryBlue,
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Responses Counter Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STUDENT RESPONSES',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$_simulatedAnsweredCount of $totalStudents Answered',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              CircularProgressIndicator(
                                value: totalStudents > 0 ? (_simulatedAnsweredCount / totalStudents) : 0,
                                strokeWidth: 4,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Question Display
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'QUESTION ${_currentQuestionIndex + 1} OF ${_room.questions.length}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.accentTeal,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      q.topic,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                q.questionText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options & Answer Key
                        // Options & Answer Key (if MCQ) or Open Question Notice (if Non-MCQ)
                        if (q.options.isNotEmpty) ...[
                          Text(
                            'Option Distribution & Correct Key',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),

                          ...List.generate(q.options.length, (idx) {
                            final isCorrect = idx == q.correctIndex;
                            final letter = String.fromCharCode(65 + idx);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCorrect ? AppTheme.successBg : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isCorrect ? AppTheme.successGreen : AppTheme.borderLight,
                                  width: isCorrect ? 1.8 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: isCorrect ? AppTheme.successGreen : const Color(0xFFF1F5F9),
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isCorrect ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      q.options[idx],
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: isCorrect ? FontWeight.w800 : FontWeight.w600,
                                        color: isCorrect ? const Color(0xFF166534) : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isCorrect)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successGreen,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'KEY',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE9D5FF)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.help_outline_rounded, size: 18, color: Color(0xFF7C3AED)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Direct Question (Non-MCQ)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF7C3AED),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'This question is shown directly to students without choices. Students submit their free text answers directly.',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                                ),
                                if (q.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE9D5FF)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.successGreen),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Reference Key / Solution: ${q.explanation}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 36),

                        // Next Question Control Button
                        ElevatedButton.icon(
                          onPressed: _isAdvancing ? null : _advanceNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLastQuestion ? AppTheme.successGreen : AppTheme.primaryBlue,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: _isAdvancing
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(isLastQuestion ? Icons.assessment : Icons.arrow_forward_rounded, color: Colors.white),
                          label: Text(
                            _isAdvancing
                                ? 'Processing...'
                                : (isLastQuestion ? 'End Quiz & View Analytics (Step 5)' : 'Next Question (${_currentQuestionIndex + 2}/${_room.questions.length})'),
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
