import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import 'learning_path_service.dart';

class DiagnosticAssessmentScreen extends StatefulWidget {
  const DiagnosticAssessmentScreen({super.key});

  @override
  State<DiagnosticAssessmentScreen> createState() => _DiagnosticAssessmentScreenState();
}

class _DiagnosticAssessmentScreenState extends State<DiagnosticAssessmentScreen> {
  final _service = LearningPathService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;

  final List<Map<String, dynamic>> _responses = [];
  int _correctCount = 0;
  DateTime _questionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final qs = await _service.getDiagnosticQuestions();
    if (mounted) {
      setState(() {
        _questions = qs;
        _isLoading = false;
        _questionStartTime = DateTime.now();
      });
    }
  }

  void _onSelectOption(int index) {
    if (_answered) return;
    final currQ = _questions[_currentIndex];
    final options = (currQ["options"] as List).cast<String>();
    final selectedAnswer = options[index];
    final correctAnswer = currQ["correct_answer"] as String? ?? "";
    final isCorrect = selectedAnswer.trim() == correctAnswer.trim();

    final responseTimeMs = DateTime.now().difference(_questionStartTime).inMilliseconds;

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (isCorrect) _correctCount++;

      _responses.add({
        "question_id": currQ["id"] ?? "q$index",
        "concept_id": currQ["concept_id"] ?? "10000000-0000-0000-0000-000000000001",
        "is_correct": isCorrect,
        "response_time_ms": responseTimeMs,
      });
    });
  }

  void _onNext() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _answered = false;
        _questionStartTime = DateTime.now();
      });
    } else {
      // Diagnostic complete: submit to ML planner service
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Calibrating ML Concept Readiness Vector...'),
              ],
            ),
          ),
        ),
      ),
    );

    await _service.submitDiagnostic(
      studentId: LearningPathService.demoStudentId,
      goalType: "TERM_TEST",
      responses: _responses,
    );

    if (!mounted) return;
    Navigator.pop(context); // close loader dialog

    final accuracyPct = (_correctCount / _questions.length * 100).toInt();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Diagnostic Assessment Complete!',
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Initial Diagnostic Score: $_correctCount / ${_questions.length} ($accuracyPct%)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Our Random Forest ML model calibrated your prerequisite readiness. '
              'Foundational index laws have been reinforced, and your custom path has been synthesized.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, AppRouter.learningPath);
              },
              child: const Text('View Tailored Learning Pathway'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diagnostic Assessment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diagnostic Assessment')),
        body: const Center(child: Text('No diagnostic questions available.')),
      );
    }

    final currQ = _questions[_currentIndex];
    final options = (currQ["options"] as List).cast<String>();
    final correctAnswer = currQ["correct_answer"] as String? ?? "";
    final explanation = currQ["explanation"] as String? ?? "";
    final isPrereq = currQ["is_prerequisite_check"] as bool? ?? false;
    final total = _questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Curriculum Diagnostic'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar & Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of $total',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (isPrereq)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Prerequisite Check 🔍',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppTheme.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 24),

            // Question Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mathematical Problem',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currQ["question_text"] ?? "",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Select the Correct Answer:',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Options List
            ...List.generate(options.length, (optIdx) {
              final optText = options[optIdx];
              final isSelected = _selectedOptionIndex == optIdx;
              final isCorrect = optText.trim() == correctAnswer.trim();

              Color borderColor = AppTheme.borderLight;
              Color bgColor = Colors.white;
              Widget? trailingIcon;

              if (_answered) {
                if (isCorrect) {
                  borderColor = AppTheme.successGreen;
                  bgColor = AppTheme.successBg;
                  trailingIcon = const Icon(Icons.check_circle, color: AppTheme.successGreen);
                } else if (isSelected) {
                  borderColor = AppTheme.errorRed;
                  bgColor = AppTheme.errorBg;
                  trailingIcon = const Icon(Icons.cancel, color: AppTheme.errorRed);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => _onSelectOption(optIdx),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isSelected ? AppTheme.primaryBlue : const Color(0xFFF1F5F9),
                          child: Text(
                            String.fromCharCode(65 + optIdx),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            optText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Pedagogical Explanation Box
            if (_answered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: AppTheme.warningAmber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Solution Explanation',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      explanation,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _onNext,
                child: Text(
                  _currentIndex < total - 1 ? 'Next Question' : 'Complete Assessment',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
