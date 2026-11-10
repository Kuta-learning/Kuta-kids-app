import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../kids_home/bloc/home_bloc.dart';
import '../../kids_home/bloc/home_event.dart';
import '../../kids_home/bloc/home_state.dart';
import '../../kids_home/data/home_repository.dart';
import '../../kids_home/models/course_model.dart';
import '../bloc/learning_bloc.dart';
import '../bloc/learning_event.dart';
import '../bloc/learning_state.dart';
import '../data/learning_repository.dart';
import '../models/chapter_model.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(HomeRepository())..add(const HomeRequested()),
      child: const _LearnBody(),
    );
  }
}

// Separate widget so it can access the HomeBloc provided above.
class _LearnBody extends StatelessWidget {
  const _LearnBody();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.orange500,
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRequested());
        await context
            .read<HomeBloc>()
            .stream
            .firstWhere((s) => s is! HomeLoading);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.orange500),
              );
            }
            if (state is HomeError) {
              return _buildError(context, state.message,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeRequested()));
            }
            if (state is HomeLoaded) {
              if (state.courses.isEmpty) return _buildEmpty();
              final course = state.courses.first;
              return _CourseView(course: course);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📚', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('No courses yet!',
              style: AppTypography.kidsHeadlineLg.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Your courses will appear here.',
              style: AppTypography.kidsBodyMd
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message,
      {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Oops! Something went wrong.',
                style: AppTypography.kidsHeadlineLg
                    .copyWith(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTypography.kidsBodyMd
                    .copyWith(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
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
                child: Text('Try Again 🔄',
                    style: AppTypography.kidsBodyMd
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Course view: loads the first course's full detail and renders it inline
// (no back button, no draggable sheet — it's embedded in the Learn tab)
// ─────────────────────────────────────────────────────────────────────────────

class _CourseView extends StatelessWidget {
  final CourseModel course;

  const _CourseView({required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LearningBloc(LearningRepository())
        ..add(CourseDetailRequested(course.id)),
      child: _CourseDetailBody(course: course),
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  final CourseModel course;

  const _CourseDetailBody({required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningBloc, LearningState>(
      builder: (context, state) {
        if (state is LearningLoading) {
          return _buildShell(course);
        }
        if (state is LearningError) {
          return _buildShell(course, error: state.message);
        }
        if (state is LearningLoaded) {
          return _buildFull(context, state.course, state.progress);
        }
        return _buildShell(course);
      },
    );
  }

  Widget _buildShell(CourseModel course, {String? error}) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _CourseHeaderCard(course: course)),
        SliverFillRemaining(
          child: Center(
            child: error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error,
                        style: AppTypography.kidsBodyMd
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                  )
                : const CircularProgressIndicator(color: AppColors.orange500),
          ),
        ),
      ],
    );
  }

  Widget _buildFull(BuildContext context, CourseDetailModel detail,
      CourseProgress? progress) {
    // Flatten all topics from all chapters into a single list
    final allTopics = <({TopicModel topic, int chapterIndex, bool isFirst})>[];
    for (var ci = 0; ci < detail.chapters.length; ci++) {
      final chapter = detail.chapters[ci];
      for (var ti = 0; ti < chapter.topics.length; ti++) {
        allTopics.add((
          topic: chapter.topics[ti],
          chapterIndex: ci,
          isFirst: ti == 0,
        ));
      }
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CourseHeaderCard(
            course: CourseModel(
              id: detail.id,
              title: detail.title,
              description: detail.description,
              chapterCount: detail.chapters.length,
              completedLessons: progress?.completedLessons ??
                  detail.completedLessons,
              totalLessons:
                  progress?.totalLessons ?? detail.totalLessons,
              progressPercentage: progress?.progressPercentage ??
                  detail.progressPercentage,
              thumbnailUrl: detail.thumbnailUrl,
            ),
          ),
        ),
        if (allTopics.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('📚 No modules yet',
                  style: TextStyle(fontSize: 18)),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final entry = allTopics[i];
                  // Determine status based on lesson completion
                  final lessons = entry.topic.lessons;
                  final completed =
                      lessons.where((l) => l.isCompleted).length;
                  final total = lessons.length;

                  _TopicStatus status;
                  if (total == 0) {
                    status = _TopicStatus.locked;
                  } else if (completed == total) {
                    status = _TopicStatus.completed;
                  } else if (completed > 0) {
                    status = _TopicStatus.inProgress;
                  } else {
                    // First topic is unlocked, rest locked until previous done
                    status = i == 0 ? _TopicStatus.inProgress : _TopicStatus.locked;
                  }

                  return _TopicCard(
                    topic: entry.topic,
                    index: i,
                    status: status,
                    isLast: i == allTopics.length - 1,
                  );
                },
                childCount: allTopics.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Blue gradient header card
// ─────────────────────────────────────────────────────────────────────────────

class _CourseHeaderCard extends StatelessWidget {
  final CourseModel course;

  const _CourseHeaderCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final gradeLevel = 'Level 1';
    final modules = course.chapterCount;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7BB8F0), Color(0xFF5B9BD5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // "Kuta Learnig" label
          Text(
            'Kuta Learning',
            style: AppTypography.kidsBodyMd.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Course title
          Text(
            course.title,
            style: AppTypography.kidsHeadlineLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          if (course.description != null &&
              course.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              course.description!,
              style: AppTypography.kidsBodyMd.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          // Pills row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Pill(label: gradeLevel),
              const SizedBox(width: 8),
              _Pill(label: '$modules Modules'),
            ],
          ),
          const SizedBox(height: 16),
          // Illustration area
          Container(
            width: 160,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: course.thumbnailUrl != null &&
                    course.thumbnailUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      course.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, s) =>
                          const _FallbackIllustration(),
                    ),
                  )
                : const _FallbackIllustration(),
          ),
        ],
      ),
    );
  }
}

class _FallbackIllustration extends StatelessWidget {
  const _FallbackIllustration();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.menu_book_rounded, size: 56, color: Colors.white),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.kidsBodyMd.copyWith(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Topic card — matches the screenshot design
// ─────────────────────────────────────────────────────────────────────────────

enum _TopicStatus { completed, inProgress, locked }

class _TopicCard extends StatelessWidget {
  final TopicModel topic;
  final int index;
  final _TopicStatus status;
  final bool isLast;

  static const _icons = [
    Icons.abc_rounded,
    Icons.auto_stories_rounded,
    Icons.palette_rounded,
    Icons.pets_rounded,
    Icons.calculate_rounded,
    Icons.science_rounded,
    Icons.music_note_rounded,
    Icons.public_rounded,
  ];

  static const _iconColors = [
    Color(0xFF16A34A),   // green
    Color(0xFFF97316),   // orange
    Color(0xFF8B5CF6),   // purple
    Color(0xFF6B7280),   // gray
    Color(0xFF3B82F6),   // blue
    Color(0xFF0EA5E9),   // sky
    Color(0xFFEC4899),   // pink
    Color(0xFF14B8A6),   // teal
  ];

  static const _iconBgs = [
    Color(0xFFDCFCE7),
    Color(0xFFFFEDD5),
    Color(0xFFF3E8FF),
    Color(0xFFF1F5F9),
    Color(0xFFEFF6FF),
    Color(0xFFE0F2FE),
    Color(0xFFFCE7F3),
    Color(0xFFCCFBF1),
  ];

  const _TopicCard({
    required this.topic,
    required this.index,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = status == _TopicStatus.locked;
    final isCompleted = status == _TopicStatus.completed;
    final isInProgress = status == _TopicStatus.inProgress;

    final iconColor = isLocked
        ? const Color(0xFFCBD5E1)
        : _iconColors[index % _iconColors.length];
    final iconBg = isLocked
        ? const Color(0xFFF1F5F9)
        : _iconBgs[index % _iconBgs.length];

    // Border color based on status
    final Color? borderColor = isInProgress
        ? AppColors.orange500
        : isCompleted
            ? const Color(0xFF16A34A)
            : null;

    // Bottom progress bar color
    final Color barColor = isInProgress
        ? AppColors.orange500
        : isCompleted
            ? const Color(0xFF16A34A)
            : Colors.transparent;

    final lessons = topic.lessons;
    final completed = lessons.where((l) => l.isCompleted).length;
    final total = lessons.length;
    final pct = total > 0 ? completed / total : 0.0;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isLocked
                ? const Color(0xFFF8FAFC)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 2)
                : Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isLocked
                            ? const Icon(Icons.lock_rounded,
                                size: 22, color: Color(0xFFCBD5E1))
                            : Icon(_icons[index % _icons.length],
                                size: 26, color: iconColor),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title + description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: AppTypography.kidsBodyMd.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isLocked
                                  ? AppColors.textSecondary
                                  : Colors.black87,
                            ),
                          ),
                          if (total > 0) ...[
                            const SizedBox(height: 3),
                            Text(
                              '$total lessons',
                              style: AppTypography.kidsBodyMd.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    _StatusBadge(status: status),
                  ],
                ),
              ),
              // Colored progress bar at bottom
              if (!isLocked && total > 0)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
            ],
          ),
        ),
        // Connector dot between cards
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _TopicStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _TopicStatus.completed:
        return Column(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFEAB308), size: 22),
            const SizedBox(height: 2),
            Text(
              'Completed',
              style: AppTypography.labelSm.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF16A34A),
              ),
            ),
          ],
        );
      case _TopicStatus.inProgress:
        return Column(
          children: [
            const Icon(Icons.star_rounded,
                color: Color(0xFFEAB308), size: 22),
            const SizedBox(height: 2),
            Text(
              'In Progress',
              style: AppTypography.labelSm.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.orange500,
              ),
            ),
          ],
        );
      case _TopicStatus.locked:
        return Column(
          children: [
            const Icon(Icons.lock_rounded,
                color: Color(0xFFCBD5E1), size: 22),
            const SizedBox(height: 2),
            Text(
              'Locked',
              style: AppTypography.labelSm.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
    }
  }
}
