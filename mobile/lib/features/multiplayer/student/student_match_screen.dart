import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/multiplayer_models.dart';
import '../services/multiplayer_service.dart';
import 'student_results_screen.dart';

class StudentMatchScreen extends StatefulWidget {
  final MultiplayerRoom room;
  final String currentPlayerId;

  const StudentMatchScreen({
    super.key,
    required this.room,
    required this.currentPlayerId,
  });

  @override
  State<StudentMatchScreen> createState() => _StudentMatchScreenState();
}

class _StudentMatchScreenState extends State<StudentMatchScreen> with SingleTickerProviderStateMixin {
  final MultiplayerService _service = MultiplayerService();
  late MultiplayerRoom _room;
  late int _currentQuestionIndex;

  Timer? _countdownTimer;
  late int _secondsLeft;
  late int _totalSeconds;

  int? _selectedOption;
  bool _hasAnswered = false;
  AnswerOutcome? _lastOutcome;
  final Stopwatch _questionStopwatch = Stopwatch();
  late final TextEditingController _directAnswerController;

  @override
  void initState() {
    super.initState();
    _directAnswerController = TextEditingController();
    _room = widget.room;
    _currentQuestionIndex = _room.currentQuestionIndex;
    _totalSeconds = _room.timePerQuestion;
    _secondsLeft = _totalSeconds;

    _startQuestion();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionStopwatch.stop();
    _directAnswerController.dispose();
    super.dispose();
  }

  void _startQuestion() {
    _selectedOption = null;
    _hasAnswered = false;
    _lastOutcome = null;
    _secondsLeft = _totalSeconds;
    _directAnswerController.clear();
    _questionStopwatch.reset();
    _questionStopwatch.start();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft -= 1);
      } else {
        timer.cancel();
        if (!_hasAnswered) {
          final curr = _currentQuestion;
          if (curr != null && curr.options.isEmpty) {
            _submitDirectAnswer();
          } else {
            _submitAnswer(-1); // timed out
          }
        }
      }
    });
  }

  Future<void> _submitAnswer(int optionIndex) async {
    if (_hasAnswered) return;
    _countdownTimer?.cancel();
    _questionStopwatch.stop();

    final responseTime = _questionStopwatch.elapsedMilliseconds;
    setState(() {
      _hasAnswered = true;
      _selectedOption = optionIndex;
    });

    final outcome = await _service.submitAnswer(
      pin: _room.pin,
      playerId: widget.currentPlayerId,
      questionIndex: _currentQuestionIndex,
      selectedOptionIndex: optionIndex,
      responseTimeMs: responseTime,
    );

    if (mounted) {
      setState(() {
        _lastOutcome = outcome;
        _room.players = outcome.leaderboard;
      });

      // Auto-advance after 2.5 seconds review
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) _advanceNext();
      });
    }
  }

  Future<void> _submitDirectAnswer() async {
    if (_hasAnswered) return;
    _countdownTimer?.cancel();
    _questionStopwatch.stop();

    final responseTime = _questionStopwatch.elapsedMilliseconds;
    final text = _directAnswerController.text.trim();

    setState(() {
      _hasAnswered = true;
      _selectedOption = 0;
    });

    final outcome = await _service.submitAnswer(
      pin: _room.pin,
      playerId: widget.currentPlayerId,
      questionIndex: _currentQuestionIndex,
      selectedOptionIndex: 0,
      responseTimeMs: responseTime,
      textAnswer: text.isNotEmpty ? text : '(No answer provided)',
    );

    if (mounted) {
      setState(() {
        _lastOutcome = outcome;
        _room.players = outcome.leaderboard;
      });

      // Auto-advance after 2.5 seconds review
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) _advanceNext();
      });
    }
  }

  Future<void> _advanceNext() async {
    if (_currentQuestionIndex + 1 < _room.questions.length) {
      final updated = await _service.nextQuestion(_room.pin);
      if (mounted) {
        setState(() {
          _room = updated;
          _currentQuestionIndex = updated.currentQuestionIndex;
        });
        _startQuestion();
      }
    } else {
      // Round Complete -> Step 4 Results
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => StudentResultsScreen(
              room: _room,
              currentPlayerId: widget.currentPlayerId,
            ),
          ),
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
    final progressFraction = (_secondsLeft / _totalSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Q ${_currentQuestionIndex + 1} / ${_room.questions.length}',
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _room.topic,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
              ),
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
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _secondsLeft <= 5 ? AppTheme.errorRed : AppTheme.primaryBlue,
                ),
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
                // Synchronized Countdown Progress Bar
                LinearProgressIndicator(
                  value: progressFraction,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _secondsLeft <= 5 ? AppTheme.errorRed : AppTheme.accentTeal,
                  ),
                ),

                // Real-Time Mini-Leaderboard Bar (Pinned on Top)
                _buildRealtimeMiniLeaderboard(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
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
                                  Text(
                                    'SOLVE IN TIME',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '⚡ Speed Bonus Active',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFB45309),
                                      ),
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
                                  color: AppTheme.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Options (if MCQ) or Direct Question Input (if Non-MCQ)
                        if (q.options.isNotEmpty) ...[
                          // MCQ Option Buttons
                          ...List.generate(q.options.length, (index) {
                            return _buildOptionButton(
                              optionIndex: index,
                              text: q.options[index],
                              correctIndex: q.correctIndex,
                            );
                          }),
                        ] else ...[
                          // Direct Question Input Card for Student
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.edit_note_rounded, size: 20, color: AppTheme.primaryBlue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Enter Your Answer',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _directAnswerController,
                                  enabled: !_hasAnswered,
                                  maxLines: 2,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    hintText: 'Type your answer or working here...',
                                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppTheme.borderLight),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppTheme.borderLight),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.8),
                                    ),
                                    contentPadding: const EdgeInsets.all(14),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: _hasAnswered ? null : _submitDirectAnswer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                                  label: Text(
                                    _hasAnswered ? 'Submitted' : 'Submit Answer',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Instant Result Banner
                        if (_hasAnswered && _lastOutcome != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _lastOutcome!.isCorrect ? AppTheme.successBg : AppTheme.errorBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _lastOutcome!.isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _lastOutcome!.isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: _lastOutcome!.isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        q.options.isNotEmpty
                                            ? (_lastOutcome!.isCorrect
                                                ? 'Correct! +${_lastOutcome!.earnedScore} pts'
                                                : 'Incorrect (Correct: ${q.options[q.correctIndex.clamp(0, q.options.length - 1)]})')
                                            : 'Answer Recorded! +${_lastOutcome!.earnedScore} pts',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: _lastOutcome!.isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                                        ),
                                      ),
                                      if (_lastOutcome!.explanation.isNotEmpty)
                                        Text(
                                          _lastOutcome!.explanation,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRealtimeMiniLeaderboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, size: 14, color: AppTheme.primaryBlue),
              const SizedBox(width: 6),
              Text(
                'LIVE LEADERBOARD',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _room.players.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final p = _room.players[index];
                final isMe = p.playerId == widget.currentPlayerId;
                final rank = index + 1;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryLight : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMe ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        rank == 1 ? '🥇' : (rank == 2 ? '🥈' : (rank == 3 ? '🥉' : '#$rank')),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.name.split(' ')[0],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                          color: isMe ? AppTheme.primaryBlue : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${p.score}p',
                        style: GoogleFonts.firaCode(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required int optionIndex,
    required String text,
    required int correctIndex,
  }) {
    Color bgColor = Colors.white;
    Color borderColor = AppTheme.borderLight;
    Color textColor = AppTheme.textPrimary;
    IconData? trailingIcon;

    if (_hasAnswered) {
      if (optionIndex == correctIndex) {
        bgColor = AppTheme.successBg;
        borderColor = AppTheme.successGreen;
        textColor = const Color(0xFF166534);
        trailingIcon = Icons.check_circle;
      } else if (optionIndex == _selectedOption) {
        bgColor = AppTheme.errorBg;
        borderColor = AppTheme.errorRed;
        textColor = AppTheme.errorRed;
        trailingIcon = Icons.cancel;
      }
    }

    final letter = String.fromCharCode(65 + optionIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _hasAnswered ? null : () => _submitAnswer(optionIndex),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: borderColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
