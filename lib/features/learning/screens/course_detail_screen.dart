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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 18, color: Colors.black87),
          ),
        ),
        title: Text(
          courseTitle,
          style: AppTypography.kidsHeadlineLg.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          if (state is LearningLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange500),
            );
          }
          if (state is LearningError) {
            return _buildError(context, state.message);
          }
          if (state is LearningLoaded) {
            return _buildContent(context, state.course);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CourseDetailModel course) {
    if (course.chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📚', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'No content yet',
              style: AppTypography.kidsHeadlineLg.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Chapters will appear here once added.',
              style: AppTypography.kidsBodyMd
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Progress bar header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${course.completedLessons}/${course.totalLessons} lessons',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: (course.progressPercentage / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.orange500),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: course.chapters.length,
            itemBuilder: (context, i) {
              return _ChapterCard(
                chapter: course.chapters[i],
                index: i + 1,
              );
            },
          ),
        ),
      ],
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
              'Something went wrong',
              style: AppTypography.kidsHeadlineLg.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.kidsBodyMd
                  .copyWith(color: AppColors.textSecondary, fontSize: 13),
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
    );
  }
}

class _ChapterCard extends StatefulWidget {
  final ChapterModel chapter;
  final int index;

  const _ChapterCard({required this.chapter, required this.index});

  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard> {
  bool _expanded = false;

  static const _chapterColors = [
    Color(0xFFDDE8F8),
    Color(0xFFFFEDD5),
    Color(0xFFDCFCE7),
    Color(0xFFFCE7F3),
    Color(0xFFFFF9C4),
    Color(0xFFE0F2FE),
  ];

  static const _chapterIconColors = [
    Color(0xFF2563EB),
    Color(0xFFF97316),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFFEAB308),
    Color(0xFF0EA5E9),
  ];

  @override
  Widget build(BuildContext context) {
    final colorIndex = (widget.index - 1) % _chapterColors.length;
    final bgColor = _chapterColors[colorIndex];
    final iconColor = _chapterIconColors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          // Chapter header
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
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chapter.title,
                          style: AppTypography.kidsBodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${widget.chapter.topics.length} topics',
                          style: AppTypography.kidsBodyMd.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Topics list (expanded)
          if (_expanded && widget.chapter.topics.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            ...widget.chapter.topics.map(
              (topic) => _TopicTile(topic: topic, accentColor: iconColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final TopicModel topic;
  final Color accentColor;

  const _TopicTile({required this.topic, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  topic.title,
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${topic.lessons.length} lessons',
                style: AppTypography.kidsBodyMd.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.black26),
            ],
          ),
        ),
        if (topic != topic) // divider between topics
          const Divider(height: 1, indent: 44, color: Color(0xFFE2E8F0)),
      ],
    );
  }
}
