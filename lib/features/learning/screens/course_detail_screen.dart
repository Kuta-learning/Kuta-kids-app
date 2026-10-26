import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../bloc/learning_bloc.dart';
import '../bloc/learning_event.dart';
import '../bloc/learning_state.dart';
import '../data/learning_repository.dart';
import '../models/chapter_model.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LearningBloc(LearningRepository())
        ..add(CourseDetailRequested(courseId)),
      child: _CourseDetailView(courseTitle: courseTitle),
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  final String courseTitle;

  const _CourseDetailView({required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          if (state is LearningLoading) {
            return _buildLoadingShell(context);
          }
          if (state is LearningError) {
            return _buildError(context, state.message);
          }
          if (state is LearningLoaded) {
            return _buildContent(context, state.course);
          }
          return _buildLoadingShell(context);
        },
      ),
    );
  }

  Widget _buildLoadingShell(BuildContext context) {
    return Stack(
      children: [
        _buildHeader(context, courseTitle, null),
        DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, controller) => _buildWhiteSheet(
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.orange500),
            ),
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, CourseDetailModel course) {
    return Stack(
      children: [
        _buildHeader(context, course.title, course),
        DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, controller) => _buildWhiteSheet(
            controller: controller,
            child: course.chapters.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: course.chapters.length,
                    itemBuilder: (context, i) => _ModuleCard(
                      chapter: course.chapters[i],
                      index: i + 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title,
      CourseDetailModel? course) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5B9BD5), Color(0xFF4A8BC4)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'KUTA LEARNING',
              style: AppTypography.labelSm.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 1.4,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: AppTypography.kidsDisplayLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (course?.description != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  course!.description!,
                  style: AppTypography.kidsBodyMd.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeaderPill(label: 'Grade 1'),
                const SizedBox(width: 8),
                _HeaderPill(
                    label:
                        '${course?.chapters.length ?? 0} Modules'),
              ],
            ),
            const SizedBox(height: 16),
            // Course illustration placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 52, color: Colors.white),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteSheet(
      {required Widget child, required ScrollController controller}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📚', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            'No modules yet',
            style: AppTypography.kidsHeadlineLg.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B9BD5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          courseTitle,
          style: AppTypography.kidsHeadlineLg
              .copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style:
                    AppTypography.kidsHeadlineLg.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTypography.kidsBodyMd.copyWith(
                    color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context
                    .read<LearningBloc>()
                    .add(CourseDetailRequested('')),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.orange500,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Try Again',
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
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;

  const _HeaderPill({required this.label});

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
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final ChapterModel chapter;
  final int index;

  const _ModuleCard({required this.chapter, required this.index});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final completedLessons = widget.chapter.topics
        .expand((t) => t.lessons)
        .where((l) => l.isCompleted)
        .length;
    final totalLessons =
        widget.chapter.topics.expand((t) => t.lessons).length;
    final pct = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_rounded,
                        color: Color(0xFF3B82F6), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MODULE ${widget.index}',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          widget.chapter.title,
                          style: AppTypography.kidsBodyMd.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(pct * 100).toInt()}%',
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 64,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3B82F6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ...widget.chapter.topics
                .map((topic) => _TopicSection(topic: topic)),
          ],
        ],
      ),
    );
  }
}

class _TopicSection extends StatelessWidget {
  final TopicModel topic;

  const _TopicSection({required this.topic});

  @override
  Widget build(BuildContext context) {
    final completedCount =
        topic.lessons.where((l) => l.isCompleted).length;
    final total = topic.lessons.length;
    final pct = total > 0 ? completedCount / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Topic header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book_rounded,
                    color: Color(0xFF16A34A), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 5,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppColors.orange500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(pct * 100).toInt()}%',
                          style: AppTypography.kidsBodyMd.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lessons list
        ...topic.lessons.asMap().entries.map((entry) {
          final i = entry.key;
          final lesson = entry.value;
          return _LessonTile(
            lesson: lesson,
            index: i + 1,
          );
        }),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonModel lesson;
  final int index;

  const _LessonTile({required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: lesson.isCompleted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: lesson.isCompleted
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white)
                        : Text(
                            '$index',
                            style: AppTypography.kidsBodyMd.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lesson.title,
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (lesson.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: AppTypography.labelSm.copyWith(
                        color: const Color(0xFF16A34A),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (index < index + 1)
            const Divider(
                height: 1, indent: 40, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}
