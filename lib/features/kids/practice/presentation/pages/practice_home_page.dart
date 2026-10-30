import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuta_learning_app/core/constants/app_colors.dart';
import 'package:kuta_learning_app/core/constants/app_typography.dart';
import 'package:kuta_learning_app/core/router/route_names.dart';

class PracticeHomePage extends StatelessWidget {
  const PracticeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeItems = <PracticeChallenge>[
      PracticeChallenge(
        title: 'Speed Math',
        description: 'Beat the clock and solve as many sums as you can!',
        stars: '3 / 5',
        progress: 0.6,
        icon: Icons.grid_view_rounded,
        iconColor: AppColors.orange500,
        iconBg: const Color(0xFFFFECE0),
        accentColor: AppColors.orange500,
        isDone: false,
      ),
      PracticeChallenge(
        title: 'Word Puzzles',
        description: 'Connect the letters and find all the hidden words.',
        stars: '5 / 5',
        progress: 1.0,
        icon: Icons.text_fields_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBg: const Color(0xFFEFF6FF),
        accentColor: const Color(0xFF3B82F6),
        isDone: true,
      ),
      PracticeChallenge(
        title: 'Science Quiz',
        description: 'Explore the world of space, plants, and animals!',
        stars: '0 / 5',
        progress: 0.1,
        icon: Icons.biotech_rounded,
        iconColor: const Color(0xFF0EA5E9),
        iconBg: const Color(0xFFE0F2FE),
        accentColor: const Color(0xFF0EA5E9),
        isDone: false,
      ),
      PracticeChallenge(
        title: 'Picture Match',
        description: 'Test your memory and match the pairs of pictures.',
        stars: '1 / 5',
        progress: 0.3,
        icon: Icons.image_rounded,
        iconColor: const Color(0xFFF97316),
        iconBg: const Color(0xFFFFEDD5),
        accentColor: const Color(0xFFF97316),
        isDone: false,
      ),
      PracticeChallenge(
        title: 'Creative Arts',
        description: 'Follow the dots or color by numbers for fun!',
        stars: '4 / 5',
        progress: 0.8,
        icon: Icons.palette_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBg: const Color(0xFFCFFAFE),
        accentColor: const Color(0xFF06B6D4),
        isDone: false,
      ),
      PracticeChallenge(
        title: 'Music Beats',
        description: 'Listen to the melody and repeat the sequence correctly.',
        stars: '2 / 5',
        progress: 0.4,
        icon: Icons.music_note_rounded,
        iconColor: const Color(0xFF6366F1),
        iconBg: const Color(0xFFEEF2FF),
        accentColor: const Color(0xFF6366F1),
        isDone: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
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
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 150,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFFF6600),
                              borderRadius: BorderRadius.all(
                                Radius.circular(36),
                              ),
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
                        const SizedBox(height: 20),
                        const Text(
                          'Pick a Challenge',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
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
                  ),
                  const SizedBox(height: 20),
                  ...challengeItems.map(
                    (challenge) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ChallengeCard(
                        title: challenge.title,
                        description: challenge.description,
                        stars: challenge.stars,
                        progress: challenge.progress,
                        icon: challenge.icon,
                        iconColor: challenge.iconColor,
                        iconBg: challenge.iconBg,
                        accentColor: challenge.accentColor,
                        isDone: challenge.isDone,
                        onTap: challenge.title == 'Word Puzzles'
                            ? () => context.push(RouteNames.practiceQuestion)
                            : challenge.title == 'Speed Math'
                            ? () => context.push(RouteNames.speedMath)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeChallenge {
  const PracticeChallenge({
    required this.title,
    required this.description,
    required this.stars,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.accentColor,
    required this.isDone,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accentColor,
                                  ),
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
