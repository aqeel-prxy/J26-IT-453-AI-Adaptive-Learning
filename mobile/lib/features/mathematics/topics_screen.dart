import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      {
        'title': 'Indices and Logarithms',
        'sinhala': 'දර්ශක හා ලඝුගණක',
        'grade': 'Grade 11',
        'concepts': 7,
        'badge': 'AI Prerequisite DAG Active',
        'badgeColor': AppTheme.primaryBlue,
        'icon': Icons.functions,
        'route': AppRouter.learningPath,
        'isFeatured': true,
        'description': 'Laws of indices, fractional exponents, scientific notation, and log law reduction.',
      },
      {
        'title': 'Quadratic Equations',
        'sinhala': 'වර්ගජ සමීකරණ',
        'grade': 'Grade 10',
        'concepts': 4,
        'badge': 'Step Error Diagnosis',
        'badgeColor': AppTheme.accentTeal,
        'icon': Icons.linear_scale,
        'route': AppRouter.concept,
        'isFeatured': false,
        'description': 'Solving quadratic equations by factorization, completing the square, and quadratic formula.',
      },
      {
        'title': 'Perimeter and Area of Plane Figures',
        'sinhala': 'තල රූපවල පරිමිතිය හා වර්ගඵලය',
        'grade': 'Grade 10',
        'concepts': 3,
        'badge': 'Geometry Representations',
        'badgeColor': AppTheme.successGreen,
        'icon': Icons.crop_square,
        'route': AppRouter.concept,
        'isFeatured': false,
        'description': 'Area and perimeter of composite shapes, triangles, sectors, and quadrilaterals.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Curriculum Topics'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18.0),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final item = topics[index];
          final isFeatured = item['isFeatured'] as bool;
          final badgeColor = item['badgeColor'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isFeatured ? AppTheme.primaryBlue : AppTheme.borderLight,
                width: isFeatured ? 2.0 : 1.0,
              ),
              boxShadow: isFeatured
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: InkWell(
              onTap: () {
                if (item['title'] == 'Quadratic Equations') {
                  Navigator.pushNamed(context, AppRouter.learningGoal, arguments: {
                    'grade': 10,
                    'topic': 'Quadratic Equations',
                  });
                } else if (item['title'] == 'Indices and Logarithms') {
                  Navigator.pushNamed(context, AppRouter.learningGoal, arguments: {
                    'grade': 11,
                    'topic': 'Indices and Logarithms',
                  });
                } else {
                  Navigator.pushNamed(context, item['route'] as String);
                }
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        Text(
                          '${item['grade']} • ${item['concepts']} Concepts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isFeatured ? AppTheme.primaryLight : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: isFeatured ? AppTheme.primaryBlue : AppTheme.textSecondary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                item['sinhala'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      item['description'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, item['route'] as String);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFeatured ? AppTheme.primaryBlue : const Color(0xFFF1F5F9),
                        foregroundColor: isFeatured ? Colors.white : AppTheme.textPrimary,
                        elevation: isFeatured ? 2 : 0,
                        minimumSize: const Size(double.infinity, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(
                        isFeatured ? Icons.alt_route : Icons.menu_book,
                        size: 18,
                      ),
                      label: Text(
                        isFeatured ? 'Open AI Learning Path (Aqeel)' : 'Explore Concepts',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
