import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import '../../core/services/error_diagnosis_service.dart';

class AnswerSubmissionScreen extends StatefulWidget {
  final String mode; // 'solve' or 'check_working'
  final String questionTitle;
  final String? submittedSolution;
  final Map<String, dynamic>? initialData;

  const AnswerSubmissionScreen({
    super.key,
    this.mode = 'solve',
    this.questionTitle = '2(x + 3) = 14',
    this.submittedSolution,
    this.initialData,
  });

  @override
  State<AnswerSubmissionScreen> createState() => _AnswerSubmissionScreenState();
}

class _AnswerSubmissionScreenState extends State<AnswerSubmissionScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _data;
  String _currentQuestion = '';

  // Similar question state
  bool _isLoadingSimilar = false;
  Map<String, dynamic>? _similarQuestionData;
  final _retryController = TextEditingController();
  bool _isSubmittingRetry = false;
  bool? _retryResultCorrect;
  String? _retryFeedback;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.questionTitle;
    _data = widget.initialData;

    if (_data == null) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _retryController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.mode == 'check_working') {
        final res = await ErrorDiagnosisService.checkWorking(
          question: _currentQuestion,
          solutionSteps: widget.submittedSolution ?? '',
        );
        if (mounted) setState(() => _data = res);
      } else {
        final res = await ErrorDiagnosisService.solveQuestion(_currentQuestion);
        if (mounted) setState(() => _data = res);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSimilarQuestion() async {
    setState(() {
      _isLoadingSimilar = true;
      _similarQuestionData = null;
      _retryResultCorrect = null;
      _retryFeedback = null;
      _retryController.clear();
    });

    try {
      final q = await ErrorDiagnosisService.getSimilarQuestion(_currentQuestion);
      if (mounted) {
        setState(() => _similarQuestionData = q);
      }
    } finally {
      if (mounted) setState(() => _isLoadingSimilar = false);
    }
  }

  Future<void> _submitRetryAttempt() async {
    final answer = _retryController.text.trim();
    if (answer.isEmpty || _similarQuestionData == null) return;

    setState(() => _isSubmittingRetry = true);
    try {
      final simQ = _similarQuestionData!['question'] as String;
      // Solve new question via solver to verify student's retry
      final checkRes = await ErrorDiagnosisService.checkWorking(
        question: simQ,
        solutionSteps: answer,
      );

      final isCorrect = checkRes['is_correct'] == true;

      // Persist to database attempt history using existing attempt endpoint
      await ErrorDiagnosisService.recordAttempt(
        studentId: 'a1111111-1111-1111-1111-111111111111',
        questionId: _similarQuestionData!['question_id'] ?? 'c4000000-0000-0000-0000-000000000001',
        studentSolution: answer,
        responseTimeMs: 14500,
      );

      if (mounted) {
        setState(() {
          _retryResultCorrect = isCorrect;
          _retryFeedback = isCorrect
              ? 'Excellent! Your retry solution is completely correct.'
              : 'Incorrect: ${checkRes['explanation_text'] ?? 'Expected answer: ${_similarQuestionData!['expected_answer'] ?? ''}'}';
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmittingRetry = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCheckWorking = widget.mode == 'check_working';
    final isCorrect = _data?['is_correct'] == true;
    final finalAnswer = _data?['final_answer'] ?? '';
    final List<dynamic> rawSteps = _data?['steps'] ?? _data?['correct_steps'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCheckWorking ? 'Diagnosis & Verification' : 'Verified Step-by-Step Solution',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              'Mathematical Solution Analysis & Error Detection',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    isCheckWorking
                        ? 'Analyzing Step-by-Step Mathematical Solution...'
                        : 'Generating Verified Derivation...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Classifying steps against mathematical solver and taxonomy',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Evaluated Problem Header
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calculate_outlined, color: AppTheme.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mathematical Question',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _currentQuestion,
                                style: GoogleFonts.firaCode(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // If in Check Working Mode: Show Diagnosis Banner
                  if (isCheckWorking) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect ? AppTheme.successBg : AppTheme.errorBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle_outline : Icons.error_outline,
                            color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect
                                      ? 'Your Derivation is Mathematically Sound!'
                                      : (_data?['failed_step_index'] != null
                                          ? 'Error Detected at Line ${_data!['failed_step_index']}'
                                          : 'Mathematical Error Detected'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                                  ),
                                ),
                                if (!isCorrect && _data?['error_category'] != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Taxonomy: ${_data!['error_category']}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.errorRed,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  _data?['explanation_text'] ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                                if (_data?['corrected_step'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Corrected Step: ${_data!['corrected_step']}',
                                    style: GoogleFonts.firaCode(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF065F46),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Verified Final Answer Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.successBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Final Answer',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              finalAnswer.isNotEmpty ? finalAnswer : 'Solution derived below',
                              style: GoogleFonts.firaCode(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified, color: AppTheme.successGreen, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Engine Verified',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Numbered Sequence of Steps
                  Text(
                    'Step-by-Step Mathematical Derivation:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (rawSteps.isNotEmpty)
                    ...rawSteps.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final stepData = entry.value;

                      String expr = '';
                      String expl = '';

                      if (stepData is Map) {
                        expr = stepData['expression'] ?? '';
                        expl = stepData['explanation'] ?? '';
                      } else {
                        expr = stepData.toString();
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Step $idx',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    expr,
                                    style: GoogleFonts.firaCode(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (expl.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                expl,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    })
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Direct evaluation verified.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Similar Practice Question Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sync_alt, color: Color(0xFF15803D), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Practice a Similar Question',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF14532D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Test your understanding by trying another question on this topic:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_similarQuestionData == null)
                          OutlinedButton.icon(
                            onPressed: _isLoadingSimilar ? null : _fetchSimilarQuestion,
                            icon: _isLoadingSimilar
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh, size: 16),
                            label: Text(_isLoadingSimilar ? 'Loading Question...' : 'Get Similar Practice Question'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF15803D),
                              side: const BorderSide(color: Color(0xFF15803D)),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Similar Question:',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Difficulty: ${_similarQuestionData!['difficulty'] ?? 'STANDARD'}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _similarQuestionData!['question'] ?? '',
                                  style: GoogleFonts.firaCode(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _retryController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your answer (e.g. x = 2 or x = 3)',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _isSubmittingRetry ? null : _submitRetryAttempt,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF15803D),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(40),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(_isSubmittingRetry ? 'Verifying...' : 'Submit Attempt & Verify'),
                                ),
                                if (_retryFeedback != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _retryResultCorrect == true ? AppTheme.successBg : AppTheme.errorBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _retryFeedback!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _retryResultCorrect == true ? AppTheme.successGreen : AppTheme.errorRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _fetchSimilarQuestion,
                            child: const Text('Try Another Question'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Direct Integration with Pathway Engine Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.hub, color: AppTheme.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Integration with Adaptive Pathway Engine',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Diagnostic events trigger the Adaptive Pathway Engine to dynamically schedule targeted remedial prerequisite nodes into the student\'s active learning trajectory.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.learningPath);
                            },
                            icon: const Icon(Icons.alt_route, size: 18),
                            label: const Text('Review Remedial Pathway'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Navigation Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Back to Workspace'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRouter.dashboard,
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Return to Hub'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
