import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';

class GamificationHubScreen extends StatefulWidget {
  const GamificationHubScreen({super.key});

  @override
  State<GamificationHubScreen> createState() => _GamificationHubScreenState();
}

class _GamificationHubScreenState extends State<GamificationHubScreen> {
  int _petHealth = 95;
  int _petEnergy = 88;
  int _petXP = 240;
  String _petMood = 'Happy & Ready to Learn! 🐾';

  void _feedPet() {
    setState(() {
      _petHealth = (_petHealth + 5).clamp(0, 100);
      _petEnergy = (_petEnergy + 10).clamp(0, 100);
      _petXP += 15;
      _petMood = 'MathPaws loved the practice problem! 🌟 (+15 XP)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('MathPaws gained +15 XP from practicing! Keep your streak alive!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MathPaws Learning Companion',
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              'Engagement, Milestones & Adaptive Retention Ecosystem',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Researcher Banner -> Professional Feature Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'GAMIFICATION ECOSYSTEM',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'DAILY MOTIVATION',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Engagement, Gamification & Feedback Adaptation',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Virtual Companion & Continuous Retention Engine',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Maintains high motivation and retention for secondary mathematics students using virtual-pet dynamics, daily streak multipliers, and contextual encouragement.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Virtual Pet Card (MathPaws)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.pets, color: Colors.white, size: 36),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'MathPaws (Level 2)',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_petXP XP',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _petMood,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Next Evolution: Level 3 at 300 XP (Requires 2 more completed prerequisite modules)',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Health & Energy Progress Bars
                  _buildPetStatBar('Pet Health', _petHealth, AppTheme.successGreen, Icons.favorite),
                  const SizedBox(height: 10),
                  _buildPetStatBar('Pet Energy', _petEnergy, Colors.amber[700]!, Icons.bolt),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _feedPet,
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('Interact & Practice with MathPaws (+15 XP)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Streaks & Milestones
            Text(
              'Meaningful Daily Streaks',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '4 Consecutive Days Active',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Multiplier: 1.5x XP Boost Active',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Target: 7 Days',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStreakDay('Thu', true),
                      _buildStreakDay('Fri', true),
                      _buildStreakDay('Sat', true),
                      _buildStreakDay('Sun', true),
                      _buildStreakDay('Mon', false),
                      _buildStreakDay('Tue', false),
                      _buildStreakDay('Wed', false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Achievement Badges
            Text(
              'Gamification Badges',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBadgeCard('Algebra Novice', 'Mastered Linear Equations', Icons.military_tech, true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBadgeCard('Prereq Explorer', 'Finished Pathway Step 1', Icons.alt_route, true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBadgeCard('Logarithm Knight', 'Unlocked at Stage 6', Icons.lock_outline, false),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Direct Pipeline to Pathway
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
                        'Direct Integration with Pathway Engine',
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
                    'Gamification XP and pet health rewards are strictly gated by actual prerequisite completions verified by the Adaptive Pathway Engine, preventing superficial gaming.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.learningPath);
                      },
                      icon: const Icon(Icons.play_circle_fill, size: 18),
                      label: const Text('Solve Next Prerequisite in Pathway'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPetStatBar(String label, int value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value/100',
          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildStreakDay(String day, bool isDone) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDone ? Colors.orange : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? Colors.orange[700]! : const Color(0xFFE2E8F0),
            ),
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check : Icons.lock_clock,
              color: isDone ? Colors.white : AppTheme.textMuted,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
            color: isDone ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String name, String desc, IconData icon, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: unlocked ? Colors.amber[700] : AppTheme.textMuted),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: unlocked ? AppTheme.textPrimary : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
