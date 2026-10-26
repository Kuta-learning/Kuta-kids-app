import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../kids_home/bloc/home_bloc.dart';
import '../../kids_home/bloc/home_event.dart';
import '../../kids_home/bloc/home_state.dart';
import '../../kids_home/data/home_repository.dart';
import '../../kids_home/models/course_model.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const _courseEmojis = [
    '📖', '🔢', '🌿', '🎨', '🎵', '🌍', '🔬', '🏃'
  ];
  static const _courseColors = [
    Color(0xFFDDE8F8),
    Color(0xFFFFEDD5),
    Color(0xFFDCFCE7),
    Color(0xFFFCE7F3),
    Color(0xFFFFF9C4),
    Color(0xFFE0F2FE),
    Color(0xFFF3E8FF),
    Color(0xFFFFEDD5),
  ];
  static const _progressColors = [
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFFEAB308),
    Color(0xFF0EA5E9),
    Color(0xFF9333EA),
    Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(HomeRepository())..add(const HomeRequested()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange500,
                        ),
                      );
                    }
                    if (state is HomeError) {
                      return _buildError(context, state.message);
                    }
                    if (state is HomeLoaded) {
                      return _buildCourseList(context, state.courses);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Text('📚', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Text(
            'My Courses',
            style: AppTypography.kidsHeadlineLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, List<CourseModel> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'No courses yet!',
              style: AppTypography.kidsHeadlineLg.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Your courses will appear here.',
              style: AppTypography.kidsBodyMd
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: courses.length,
      itemBuilder: (context, i) {
        final course = courses[i];
        final color = _courseColors[i % _courseColors.length];
        final progressColor = _progressColors[i % _progressColors.length];
        final emoji = _courseEmojis[i % _courseEmojis.length];
        final progress = course.totalLessons > 0
            ? course.completedLessons / course.totalLessons
            : 0.0;

        return _CourseListTile(
          courseId: course.id,
          title: course.title,
          description: course.description ?? '${course.totalLessons} lessons',
          emoji: emoji,
          color: color,
          progressColor: progressColor,
          completedLessons: course.completedLessons,
          totalLessons: course.totalLessons,
          progress: progress,
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: AppTypography.kidsHeadlineLg.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.kidsBodyMd.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () =>
                  context.read<HomeBloc>().add(const HomeRequested()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Try Again 🔄',
                  style: AppTypography.kidsBodyMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseListTile extends StatelessWidget {
  final String courseId;
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final Color progressColor;
  final int completedLessons;
  final int totalLessons;
  final double progress;

  const _CourseListTile({
    required this.courseId,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.progressColor,
    required this.completedLessons,
    required this.totalLessons,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '${RouteNames.kidsLearn}/course',
        extra: {'courseId': courseId, 'courseTitle': title},
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            // Title + progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.kidsHeadlineLg.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedLessons/$totalLessons lessons',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}
