import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kuta Learning',
                  style: AppTypography.kidsHeadlineLg.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange900,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    'Hey, Little\nExplorer!',
                    style: AppTypography.kidsHeadlineLg.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: AppColors.orange900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your learning garden is blooming beautifully today!',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Growing Your Brain',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProgressCard(
                    title: 'English Fun',
                    subtitle: 'Chapter 4: Spelling Bees',
                    progress: 0.65,
                    progressText: '65%',
                    icon: Icons.text_fields_rounded,
                    iconBackground: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 12),
                  _ProgressCard(
                    title: 'Cool Math',
                    subtitle: 'Topic: Big Numbers',
                    progress: 0.82,
                    progressText: '82%',
                    icon: Icons.add_rounded,
                    iconBackground: const Color(0xFFFFEDD5),
                    iconColor: AppColors.orange500,
                  ),
                  const SizedBox(height: 12),
                  _ProgressCard(
                    title: 'Super Science',
                    subtitle: 'Unit: Planet Earth',
                    progress: 0.40,
                    progressText: '40%',
                    icon: Icons.rocket_launch_rounded,
                    iconBackground: const Color(0xFFE0F2FE),
                    iconColor: AppColors.info,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Badges Earned',
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'See All Gallery',
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BadgeCard(
                          title: 'Word Wizard',
                          subtitle: 'Spelled 50 words',
                          gradientColors: const [
                            Color(0xFFFFEE55),
                            Color(0xFFFF8800),
                          ],
                          icon: Icons.auto_fix_high_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BadgeCard(
                          title: 'Math Genius',
                          subtitle: 'No mistakes day!',
                          gradientColors: const [
                            Color(0xFF88AAFF),
                            Color(0xFF4455CC),
                          ],
                          icon: Icons.grid_view_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.push(RouteNames.parentPin),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      label: Text(
                        'Parent Settings',
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String progressText;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      progressText,
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.borderVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
