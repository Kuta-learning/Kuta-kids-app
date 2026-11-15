import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart'
    show AppColors, cardTextColorOn;
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
        backgroundColor: const Color(0xFFFFFBF5),
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
// Vibrant blue gradient header card
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
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // "Kuta Learning" label
          Text(
            'Kuta Learning',
            style: AppTypography.kidsBodyMd.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // Course title
          Text(
            course.title,
            style: AppTypography.kidsHeadlineLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 32,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          if (course.description != null &&
              course.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              course.description!,
              style: AppTypography.kidsBodyMd.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          // Pills row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Pill(label: gradeLevel),
              const SizedBox(width: 8),
              _Pill(label: '$modules Modules'),
            ],
          ),
          const SizedBox(height: 18),
          // Illustration area
          Container(
            width: 180,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: course.thumbnailUrl != null &&
                    course.thumbnailUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
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
      child: Icon(Icons.menu_book_rounded, size: 64, color: Colors.white),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: AppTypography.kidsBodyMd.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Topic card — colorful gradient background per topic
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
    Color(0xFF16A34A), // green
    Color(0xFFF97316), // orange
    Color(0xFF8B5CF6), // purple
    Color(0xFF6B7280), // gray
    Color(0xFF3B82F6), // blue
    Color(0xFF0EA5E9), // sky
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
  ];

  static const _cardGradients = [
    [Color(0xFF60A5FA), Color(0xFF2563EB)],
    [Color(0xFFFFB347), Color(0xFFFF8C00)],
    [Color(0xFF4ADE80), Color(0xFF16A34A)],
    [Color(0xFFF472B6), Color(0xFFEC4899)],
    [Color(0xFFFACC15), Color(0xFFF59E0B)],
    [Color(0xFF0EA5E9), Color(0xFF0284C7)],
    [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    [Color(0xFF2DD4BF), Color(0xFF0D9488)],
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
    final lessons = topic.lessons;
    final completed = lessons.where((l) => l.isCompleted).length;
    final total = lessons.length;
    final pct = total > 0 ? completed / total : 0.0;
    final gradient = _cardGradients[index % _cardGradients.length];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            gradient: isLocked
                ? null
                : LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isLocked ? const Color(0xFFF1F5F9) : null,
            borderRadius: BorderRadius.circular(28),
            border: isLocked
                ? Border.all(color: const Color(0xFFE2E8F0), width: 1)
                : null,
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: gradient.last.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? const Color(0xFFE2E8F0)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isLocked
                            ? const Icon(Icons.lock_rounded,
                                size: 26, color: Color(0xFF94A3B8))
                            : Icon(
                                _icons[index % _icons.length],
                                size: 30,
                                color:
                                    _iconColors[index % _iconColors.length],
                              ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isLocked
                                  ? AppColors.textSecondary
                                  : cardTextColorOn(gradient),
                            ),
                          ),
                          if (total > 0) ...[
                            const SizedBox(height: 3),
                            Text(
                              '$total lessons',
                              style: AppTypography.kidsBodyMd.copyWith(
                                fontSize: 12,
                                color: isLocked
                                    ? AppColors.textSecondary
                                    : cardTextColorOn(gradient)
                                        .withValues(alpha: 0.85),
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
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
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
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
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
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 22),
              SizedBox(width: 4),
              Text('Done',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        );
      case _TopicStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.orange500,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange500.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingStar(color: Colors.white),
              SizedBox(width: 4),
              Text('Go!',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        );
      case _TopicStatus.locked:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, color: Color(0xFF94A3B8), size: 20),
              SizedBox(width: 4),
              Text('Locked',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B))),
            ],
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A gently pulsing star used for the "in progress" badge.
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingStar extends StatefulWidget {
  final Color color;

  const _PulsingStar({required this.color});

  @override
  State<_PulsingStar> createState() => _PulsingStarState();
}

class _PulsingStarState extends State<_PulsingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Icon(Icons.star_rounded, color: widget.color, size: 22),
    );
  }
}
