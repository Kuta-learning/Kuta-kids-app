import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kuta_learning_app/core/constants/app_colors.dart';
import 'package:kuta_learning_app/core/constants/app_typography.dart';
import 'package:kuta_learning_app/core/router/route_names.dart';

import '../../bloc/practice_bloc.dart';
import '../../bloc/practice_event.dart';
import '../../bloc/practice_state.dart';
import '../../data/models.dart';
import '../../data/practice_repository.dart';

class PracticeHomePage extends StatelessWidget {
  const PracticeHomePage({super.key});

  // Icon/color palettes cycled by index to give each topic a distinct look.
  static const _icons = [
    Icons.grid_view_rounded,
    Icons.text_fields_rounded,
    Icons.biotech_rounded,
    Icons.image_rounded,
    Icons.palette_rounded,
    Icons.music_note_rounded,
  ];
  static const _iconColors = [
    AppColors.orange500,
    Color(0xFF3B82F6),
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFF6366F1),
  ];
  static const _iconBgs = [
    Color(0xFFFFECE0),
    Color(0xFFEFF6FF),
    Color(0xFFE0F2FE),
    Color(0xFFFFEDD5),
    Color(0xFFCFFAFE),
    Color(0xFFEEF2FF),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PracticeBloc(PracticeRepository())..add(const PracticeTopicsRequested()),
      child: const _PracticeHomeView(),
    );
  }
}

class _PracticeHomeView extends StatelessWidget {
  const _PracticeHomeView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PracticeBloc, PracticeState>(
      listener: (context, state) {
        if (state is PracticeSessionReady) {
          context.push(RouteNames.practiceQuestion, extra: {
            'attemptId': state.attemptId,
            'questions': state.questions,
          });
        } else if (state is PracticeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<PracticeBloc, PracticeState>(
                  builder: (context, state) {
                    if (state is PracticeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange500,
                        ),
                      );
                    }

                    final topics = state is PracticeLoaded
                        ? state.topics
                        : _fallbackTopics();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildBanner(),
                        const SizedBox(height: 20),
                        ...topics.asMap().entries.map((entry) {
                          final i = entry.key;
                          final topic = entry.value;
                          final icon = PracticeHomePage._icons[
                              i % PracticeHomePage._icons.length];
                          final iconColor = PracticeHomePage._iconColors[
                              i % PracticeHomePage._iconColors.length];
                          final iconBg = PracticeHomePage._iconBgs[
                              i % PracticeHomePage._iconBgs.length];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ChallengeCard(
                              title: topic.title,
                              description: topic.description,
                              stars: '0 / ${topic.questionCount}',
                              progress: 0.0,
                              icon: icon,
                              iconColor: iconColor,
                              iconBg: iconBg,
                              accentColor: iconColor,
                              isDone: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (topic.id == 'mock-speed-math') {
                                  context.push(RouteNames.speedMath);
                                } else if (topic.id.startsWith('mock-')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${topic.title} coming soon 🚀'),
                                    ),
                                  );
                                } else {
                                  context
                                      .read<PracticeBloc>()
                                      .add(PracticeTopicStarted(topic.id));
                                }
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    );
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Text(
            'Kuta Learning',
            style: AppTypography.kidsHeadlineLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE2ECF8), Color(0xFFC3D8F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: const Column(
        children: [
          SizedBox(
            height: 150,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFF6600),
                borderRadius: BorderRadius.all(Radius.circular(36)),
              ),
              child: Center(
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 88,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Pick a Challenge',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'What do you want to master today? Every challenge earns you stars!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<PracticeTopic> _fallbackTopics() {
    return const [
      PracticeTopic(
        id: 'mock-speed-math',
        title: 'Speed Math',
        description: 'Beat the clock and solve as many sums as you can!',
        questionCount: 5,
      ),
      PracticeTopic(
        id: 'mock-word-puzzles',
        title: 'Word Puzzles',
        description: 'Connect the letters and find all the hidden words.',
        questionCount: 5,
      ),
      PracticeTopic(
        id: 'mock-science-quiz',
        title: 'Science Quiz',
        description: 'Explore the world of space, plants, and animals!',
        questionCount: 5,
      ),
      PracticeTopic(
        id: 'mock-picture-match',
        title: 'Picture Match',
        description: 'Test your memory and match the pairs of pictures.',
        questionCount: 5,
      ),
      PracticeTopic(
        id: 'mock-creative-arts',
        title: 'Creative Arts',
        description: 'Follow the dots or color by numbers for fun!',
        questionCount: 5,
      ),
      PracticeTopic(
        id: 'mock-music-beats',
        title: 'Music Beats',
        description: 'Listen to the melody and repeat the sequence correctly.',
        questionCount: 5,
      ),
    ];
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.stars,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accentColor,
    required this.isDone,
    this.onTap,
  });

  final String title;
  final String description;
  final String stars;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color accentColor;
  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(icon, color: iconColor, size: 48),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            if (isDone)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.orange900,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'DONE!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFBBF24),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stars,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(accentColor),
                                  minHeight: 6,
                                ),
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
          ),
        ),
      ],
    );
  }
}
