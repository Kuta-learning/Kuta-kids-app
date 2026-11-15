import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart'
    show AppColors, cardTextColorOn;
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

  static const _progressGradients = [
    [Color(0xFF60A5FA), Color(0xFF2563EB)],
    [Color(0xFFFFB347), Color(0xFFFF8C00)],
    [Color(0xFF4ADE80), Color(0xFF16A34A)],
    [Color(0xFFF472B6), Color(0xFFEC4899)],
    [Color(0xFFFACC15), Color(0xFFF59E0B)],
    [Color(0xFF0EA5E9), Color(0xFF0284C7)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
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
                    fontWeight: FontWeight.w900,
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

                  return RefreshIndicator(
                    color: AppColors.orange500,
                    onRefresh: () async {
                      context
                          .read<ProgressBloc>()
                          .add(const ProgressRequested());
                      await context
                          .read<ProgressBloc>()
                          .stream
                          .firstWhere((s) => s is! ProgressLoading);
                    },
                    child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const Text('🦊', style: TextStyle(fontSize: 52)),
                      const SizedBox(height: 4),
                      Text(
                        'Hey, Little\nExplorer!',
                        style: AppTypography.kidsHeadlineLg.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
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
                      const SizedBox(height: 22),
                      Text(
                        'Growing Your Brain',
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
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
                          final iconColor = _iconColorForIndex(idx);
                          final pct = entry.progress.progressPercentage;
                          // API may return 0–100 or 0.0–1.0 — normalise.
                          final displayPct =
                              pct > 1.0 ? pct : pct * 100;
                          final progressValue =
                              pct > 1.0 ? pct / 100 : pct;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ProgressCard(
                              title: entry.course.title,
                              subtitle:
                                  '${entry.progress.completedLessons}/${entry.progress.totalLessons} lessons',
                              progress: progressValue.clamp(0.0, 1.0),
                              progressText:
                                  '${displayPct.round()}%',
                              icon: icon,
                              iconColor: iconColor,
                              gradient: _progressGradients[
                                  idx % _progressGradients.length],
                            ),
                          );
                        }),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Badges Earned',
                            style: AppTypography.kidsBodyMd.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Badge gallery coming soon! 🏆')),
                              );
                            },
                            child: Text(
                              'See All Gallery',
                              style: AppTypography.kidsBodyMd.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.orange900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
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
                  ),
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
    required this.iconColor,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String progressText;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: cardTextColorOn(gradient),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      progressText,
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: cardTextColorOn(gradient),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 11,
                    color: cardTextColorOn(gradient).withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 12,
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
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
