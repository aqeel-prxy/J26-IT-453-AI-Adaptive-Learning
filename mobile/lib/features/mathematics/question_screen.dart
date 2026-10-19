import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _solutionController = TextEditingController(
    text: 'x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3',
  );

  void _onSolvePressed() {
    Navigator.pushNamed(
      context,
      AppRouter.submit,
      arguments: _solutionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Problem Solving Workspace'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Problem 1 of 5',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Difficulty: 0.5 (Moderate)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warningAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Question Statement Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Statement',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Solve for x: x² + 5x + 6 = 0',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enter Your Step-by-Step Solution:',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '1 step / line',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Math Code/Text Input Container
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight, width: 1.5),
              ),
              child: TextField(
                controller: _solutionController,
                maxLines: null,
                expands: true,
                style: GoogleFonts.firaCode(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                  height: 1.6,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write each transformation step on a new line...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _onSolvePressed,
              icon: const Icon(Icons.psychology, size: 20),
              label: const Text('Submit Solution for AI Error Diagnosis'),
            ),
          ],
        ),
      ),
    );
  }
}
