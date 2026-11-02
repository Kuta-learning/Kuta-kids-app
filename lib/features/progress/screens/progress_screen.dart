import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';
import '../bloc/progress_state.dart';
import '../data/progress_repository.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProgressBloc(ProgressRepository())..add(const ProgressRequested()),
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

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
              child: BlocBuilder<ProgressBloc, ProgressState>(
                builder: (context, state) {
                  List<CourseProgressEntry>? entries;
                  if (state is ProgressLoaded) {
                    entries = state.entries;
                  }

                  return ListView(
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
                      if (state is ProgressLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(
                              color: AppColors.orange500,
                            ),
                          ),
                        )
                      else
                        ...( entries ?? _fallbackEntries())
                            .asMap()
                            .entries
                            .map((e) {
                          final idx = e.key;
                          final entry = e.value;
                          final icon = _iconForIndex(idx);
                          final iconBg = _iconBgForIndex(idx);
                          final iconColor = _iconColorForIndex(idx);
                          final pct = entry.progress.progressPercentage;
                          // API may return 0–100 or 0.0–1.0 — normalise.
                          final displayPct =
                              pct > 1.0 ? pct : pct * 100;
                          final progressValue =
                              pct > 1.0 ? pct / 100 : pct;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProgressCard(
                              title: entry.course.title,
                              subtitle:
                                  '${entry.progress.completedLessons}/${entry.progress.totalLessons} lessons',
                              progress: progressValue.clamp(0.0, 1.0),
                              progressText:
                                  '${displayPct.round()}%',
                              icon: icon,
                              iconBackground: iconBg,
                              iconColor: iconColor,
                            ),
                          );
                        }),
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
                          onPressed: () =>
                              context.push(RouteNames.parentPin),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CourseProgressEntry> _fallbackEntries() {
    return ProgressRepository.mockEntries;
  }

  IconData _iconForIndex(int i) {
    const icons = [
      Icons.text_fields_rounded,
      Icons.add_rounded,
      Icons.rocket_launch_rounded,
      Icons.palette_rounded,
      Icons.biotech_rounded,
      Icons.music_note_rounded,
    ];
    return icons[i % icons.length];
  }

  Color _iconBgForIndex(int i) {
    const bgs = [
      Color(0xFFEFF6FF),
      Color(0xFFFFEDD5),
      Color(0xFFE0F2FE),
      Color(0xFFCFFAFE),
      Color(0xFFF0FDF4),
      Color(0xFFEEF2FF),
    ];
    return bgs[i % bgs.length];
  }

  Color _iconColorForIndex(int i) {
    const colors = [
      Color(0xFF3B82F6),
      AppColors.orange500,
      AppColors.info,
      Color(0xFF06B6D4),
      Color(0xFF16A34A),
      Color(0xFF6366F1),
    ];
    return colors[i % colors.length];
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
