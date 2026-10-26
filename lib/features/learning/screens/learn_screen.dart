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
import '../../kids_home/widgets/adventure_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const _courseEmojis = [
    '🎨', '📐', '🔬', '📖', '🎵', '🌍', '🔢', '🌿',
  ];
  static const _courseColors = [
    Color(0xFFE8F4FD),
    Color(0xFFDDE8F8),
    Color(0xFFDCFCE7),
    Color(0xFFFCE7F3),
    Color(0xFFFFF9C4),
    Color(0xFFE0F2FE),
    Color(0xFFFFEDD5),
    Color(0xFFF3E8FF),
  ];
  static const _progressColors = [
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFFEAB308),
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF9333EA),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(HomeRepository())..add(const HomeRequested()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.orange500),
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
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: courses.length,
      itemBuilder: (context, i) {
        final course = courses[i];
        return AdventureCard(
          courseId: course.id,
          title: course.title,
          emoji: _courseEmojis[i % _courseEmojis.length],
          color: _courseColors[i % _courseColors.length],
          progress: course.completedLessons,
          total: course.totalLessons,
          progressColor: _progressColors[i % _progressColors.length],
          thumbnailUrl: course.thumbnailUrl,
          onTap: () => context.push(
            '${RouteNames.kidsLearn}/course',
            extra: {
              'courseId': course.id,
              'courseTitle': course.title,
            },
          ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.orange500,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange500.withValues(alpha: 0.4),
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
