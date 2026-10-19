import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import '../../core/services/error_diagnosis_service.dart';

class AnswerSubmissionScreen extends StatefulWidget {
  final String submittedSolution;
  final String questionTitle;

  const AnswerSubmissionScreen({
    super.key,
    this.submittedSolution = '2x² + 6x - x - 3 = 0\n2x(x + 3) - 1(x + 3) = 0\n(2x - 1)(x + 3) = 0\nx = 1/2 or x = 3',
    this.questionTitle = '2x² + 5x - 3 = 0',
  });

  @override
  State<AnswerSubmissionScreen> createState() => _AnswerSubmissionScreenState();
}

class _AnswerSubmissionScreenState extends State<AnswerSubmissionScreen> {
  bool _isAnalyzing = true;
  Map<String, dynamic>? _diagnosisResult;

  @override
  void initState() {
    super.initState();
    _fetchDiagnosis();
  }

  Future<void> _fetchDiagnosis() async {
    setState(() => _isAnalyzing = true);
    try {
      final res = await ErrorDiagnosisService.solveAndDiagnose(
        question: widget.questionTitle,
        solution: widget.submittedSolution,
      );
      if (mounted) {
        setState(() {
          _diagnosisResult = res;
          _isAnalyzing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = _diagnosisResult?['is_correct'] == true;
    final failedStep = _diagnosisResult?['failed_step_index'];
    final errorCategory = _diagnosisResult?['error_category'] ?? 'Algebraic Error';
    final explanation = _diagnosisResult?['explanation_text'] ??
        'Please review your intermediate algebraic steps against the benchmark solution below.';
    final guidance = _diagnosisResult?['pedagogical_guidance'];
    final finalAnswer = _diagnosisResult?['final_answer'] ?? 'x = -3 or x = 1/2';
    final List<dynamic> rawSteps = _diagnosisResult?['correct_steps'] ?? [];
    final correctSteps = rawSteps.map((e) => e.toString()).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Diagnostic Feedback & Solution'),
        centerTitle: true,
      ),
      body: _isAnalyzing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Analyzing Step-by-Step Derivation & Solving Problem...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Component 4 AI Error Diagnosis Engine (Ranathunga K.P.B.S)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
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
                                'Evaluated Mathematical Question',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.questionTitle,
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

                  // Error Diagnostic Status Banner
                  Container(
                    padding: const EdgeInsets.all(18),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_circle_outline : Icons.error_outline,
                            color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCorrect
                                    ? 'All Steps Mathematically Valid!'
                                    : (failedStep != null
                                        ? 'Line $failedStep Transformation Error Detected'
                                        : 'Mathematical Error Detected'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isCorrect
                                      ? 'Status: Verified Sound Working (Component 4)'
                                      : 'Taxonomy: $errorCategory (Component 4)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pedagogical Feedback Card
                  Text(
                    'Pedagogical Analysis & Guidance',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          explanation,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        if (guidance != null && guidance.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline, color: Color(0xFFD97706), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    guidance,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF92400E),
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
                  const SizedBox(height: 24),

                  // Correct Final Answer Box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Correct Final Answer:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Verified Root(s)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.successBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                    ),
                    child: Text(
                      finalAnswer,
                      style: GoogleFonts.firaCode(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full Step-by-Step Benchmark Solution
                  Text(
                    'Step-by-Step Correct Solution Derivation:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (correctSteps.isNotEmpty)
                    ...correctSteps.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final stepText = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                stepText,
                                style: GoogleFonts.firaCode(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Full derivation steps generated dynamically by AI solver.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Revise / Re-solve'),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Return to Hub'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
