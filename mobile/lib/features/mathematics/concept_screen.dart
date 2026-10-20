import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';

class ConceptScreen extends StatelessWidget {
  final String conceptTitle;
  final String topicCategory;

  const ConceptScreen({
    super.key,
    this.conceptTitle = 'Solving Quadratic Equations by Factorization',
    this.topicCategory = 'Quadratic Equations',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(topicCategory),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Grade 10 • Concept Code: MATH-G10-QUAD-01',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    conceptTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Learner Mastery & Cognitive Calibration',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      value: 0.42,
                      minHeight: 8,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Estimated Mastery Probability: 42% (Time-Decay Monitored)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Multi-Modal Concept Representations',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            _buildRepresentationTile(
              title: 'Step-by-Step Factoring Technique',
              subtitle: '1. Standard Form  2. Factor Product  3. Zero Roots',
              type: 'STEP_BY_STEP',
              icon: Icons.format_list_numbered,
            ),
            const SizedBox(height: 10),

            _buildRepresentationTile(
              title: 'Geometric Parabola Roots Diagram',
              subtitle: 'Visual roots at x-intercepts (-2, -3) of curve',
              type: 'DIAGRAM',
              icon: Icons.pie_chart_outline,
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.question);
              },
              icon: const Icon(Icons.edit_note, size: 22),
              label: const Text('Start Problem Solving Session'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepresentationTile({
    required String title,
    required String subtitle,
    required String type,
    required IconData icon,
  }) {
    return Container(
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
            child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
