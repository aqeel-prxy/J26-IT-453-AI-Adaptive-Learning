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
  late int _totalExamSeconds;

  int? _selectedOption;
  final Stopwatch _questionStopwatch = Stopwatch();
  late final TextEditingController _directAnswerController;

  // Question-by-question tracking for option switches & ML telemetry
  final Map<int, int> _userSelectedOptions = {};
  final Map<int, String> _userTextAnswers = {};
  final Map<int, int> _questionSwitches = {};
  final Map<int, int> _questionElapsedMs = {};

  @override
  void initState() {
    super.initState();
    _directAnswerController = TextEditingController();
    _room = widget.room;
    _currentQuestionIndex = _room.currentQuestionIndex;

    // Total exam timer is calculated across all questions in the test
    _totalExamSeconds = _room.timePerQuestion * _room.questions.length;
    _secondsLeft = _totalExamSeconds;

    _startExamTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionStopwatch.stop();
    _directAnswerController.dispose();
    super.dispose();
  }

  void _startExamTimer() {
    _questionStopwatch.reset();
    _questionStopwatch.start();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft -= 1);
      } else {
        timer.cancel();
        // Total exam duration expired: submit and finish exam
        _finishExam();
      }
    });
  }

  void _selectOption(int optionIndex) {
    final prev = _userSelectedOptions[_currentQuestionIndex];
    if (prev != null && prev != optionIndex) {
      // User switched their option choice: record switch for ML hesitation detection
      _questionSwitches[_currentQuestionIndex] = (_questionSwitches[_currentQuestionIndex] ?? 0) + 1;
    }

    setState(() {
      _userSelectedOptions[_currentQuestionIndex] = optionIndex;
      _selectedOption = optionIndex;
    });
  }

  void _saveCurrentQuestionTelemetry() {
    final current = _questionElapsedMs[_currentQuestionIndex] ?? 0;
    _questionElapsedMs[_currentQuestionIndex] = current + _questionStopwatch.elapsedMilliseconds;
    _questionStopwatch.reset();
    _questionStopwatch.start();
    if (_directAnswerController.text.trim().isNotEmpty) {
      _userTextAnswers[_currentQuestionIndex] = _directAnswerController.text.trim();
    }
  }

  Future<void> _syncAnswerIfPresent(int qIndex) async {
    final selected = _userSelectedOptions[qIndex];
    final text = _userTextAnswers[qIndex];
    if (selected == null && (text == null || text.isEmpty)) {
      return; // Question unanswered / skipped: do not submit fake answer
    }

    final responseTime = _questionElapsedMs[qIndex] ?? 3000;
    final switches = _questionSwitches[qIndex] ?? 0;
    final timeSec = responseTime / 1000.0;
    final idle = (timeSec > 3.5) ? (timeSec - 3.5) : 0.0;

    try {
      final outcome = await _service.submitAnswer(
        pin: _room.pin,
        playerId: widget.currentPlayerId,
        questionIndex: qIndex,
        selectedOptionIndex: selected ?? -1,
        responseTimeMs: responseTime > 0 ? responseTime : 3000,
        textAnswer: text,
        optionSwitches: switches,
        idleSeconds: idle,
      );

      if (mounted) {
        setState(() {
          _room.players = outcome.leaderboard;
        });
      }
    } catch (_) {
      // Silent error handling for background telemetry sync
    }
  }

  void _navigatePrevious() {
    if (_currentQuestionIndex > 0) {
      _saveCurrentQuestionTelemetry();
      _syncAnswerIfPresent(_currentQuestionIndex);
      setState(() {
        _currentQuestionIndex -= 1;
        _loadQuestionState();
      });
    }
  }

  Future<void> _navigateNextOrSubmit() async {
    _saveCurrentQuestionTelemetry();
    _syncAnswerIfPresent(_currentQuestionIndex);

    if (_currentQuestionIndex + 1 < _room.questions.length) {
      setState(() {
        _currentQuestionIndex += 1;
        _loadQuestionState();
      });
    } else {
      await _finishExam();
    }
  }

  Future<void> _finishExam() async {
    _countdownTimer?.cancel();
    _questionStopwatch.stop();

    _saveCurrentQuestionTelemetry();
    await _syncAnswerIfPresent(_currentQuestionIndex);

    // Sync any other answered questions that haven't synced yet
    for (int i = 0; i < _room.questions.length; i++) {
      if (_userSelectedOptions.containsKey(i) || _userTextAnswers.containsKey(i)) {
        await _syncAnswerIfPresent(i);
      }
    }

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

  void _loadQuestionState() {
    _selectedOption = _userSelectedOptions[_currentQuestionIndex];
    _directAnswerController.text = _userTextAnswers[_currentQuestionIndex] ?? '';
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
    final progressFraction = (_secondsLeft / _totalExamSeconds).clamp(0.0, 1.0);
    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');
    final timerText = '$mins:$secs';

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
                                    'QUESTION ${_currentQuestionIndex + 1} OF ${_room.questions.length}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textSecondary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if ((_questionSwitches[_currentQuestionIndex] ?? 0) > 0)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEDE9FE),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '🔄 ${_questionSwitches[_currentQuestionIndex]} ${(_questionSwitches[_currentQuestionIndex] == 1) ? "Switch" : "Switches"}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF6D28D9),
                                            ),
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
                                const SizedBox(height: 10),
                                Text(
                                  'Your answer will be recorded as you navigate through the exam.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: AppTheme.textSecondary,
                                    fontStyle: FontStyle.italic,
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

                // Pinned Bottom Navigation Controls (Previous and Next / Finish)
                _buildBottomNavigationControls(),
              ],
            ),
    );
  }

  Widget _buildRealtimeMiniLeaderboard() {
    final studentPlayers = _room.players
        .where((p) => !p.isHost && !p.name.toLowerCase().contains('(teacher)'))
        .toList();
    final players = studentPlayers.isNotEmpty ? studentPlayers : _room.players;

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
              itemCount: players.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final p = players[index];
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
  }) {
    final isSelected = (_selectedOption == optionIndex);
    final letter = String.fromCharCode(65 + optionIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectOption(optionIndex),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? AppTheme.primaryBlue.withOpacity(0.08) : Colors.black.withOpacity(0.02),
                blurRadius: 8,
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
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppTheme.primaryBlue,
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
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationControls() {
    final isLastQuestion = (_currentQuestionIndex == _room.questions.length - 1);

    return Container(
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
        child: Row(
          children: [
            // Previous Question Button
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: _currentQuestionIndex > 0 ? _navigatePrevious : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(
                    color: _currentQuestionIndex > 0 ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  backgroundColor: _currentQuestionIndex > 0 ? const Color(0xFFF8FAFC) : Colors.transparent,
                ),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: _currentQuestionIndex > 0 ? AppTheme.primaryBlue : const Color(0xFF94A3B8),
                ),
                label: Text(
                  'Previous',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _currentQuestionIndex > 0 ? AppTheme.primaryBlue : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Next / Finish Button
            Expanded(
              flex: 6,
              child: ElevatedButton.icon(
                onPressed: _navigateNextOrSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastQuestion ? const Color(0xFF10B981) : AppTheme.primaryBlue,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: Icon(
                  isLastQuestion ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  isLastQuestion ? 'Submit & Finish' : 'Next Question',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
