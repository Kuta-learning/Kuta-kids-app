import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kuta_learning_app/core/constants/app_colors.dart'
    show AppColors, cardTextColorOn;
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
  static const _challengeGradients = [
    [Color(0xFF60A5FA), Color(0xFF2563EB)],
    [Color(0xFFFFB347), Color(0xFFFF8C00)],
    [Color(0xFF4ADE80), Color(0xFF16A34A)],
    [Color(0xFFF472B6), Color(0xFFEC4899)],
    [Color(0xFFFACC15), Color(0xFFF59E0B)],
    [Color(0xFF0EA5E9), Color(0xFF0284C7)],
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
        backgroundColor: const Color(0xFFFFFBF5),
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

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ChallengeCard(
                              title: topic.title,
                              description: topic.description,
                              stars: '0 / ${topic.questionCount}',
                              progress: 0.0,
                              icon: icon,
                              iconColor: iconColor,
                              accentColor: iconColor,
                              gradient: PracticeHomePage._challengeGradients[
                                  i % PracticeHomePage._challengeGradients.length],
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
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Text(
            'Kuta Learning',
            style: AppTypography.kidsHeadlineLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 26,
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD166), Color(0xFFFF8C00)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🚀', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Pick a Challenge',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What do you want to master today? Every challenge earns you stars!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
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
    required this.accentColor,
    required this.gradient,
    required this.isDone,
    this.onTap,
  });

  final String title;
  final String description;
  final String stars;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final List<Color> gradient;
  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(icon, color: iconColor, size: 50),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: cardTextColorOn(gradient),
                                ),
                              ),
                            ),
                            if (isDone)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.orange900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'DONE!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: cardTextColorOn(gradient).withValues(alpha: 0.9),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFBBF24),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stars,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cardTextColorOn(gradient),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.4),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(accentColor),
                                  minHeight: 8,
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
