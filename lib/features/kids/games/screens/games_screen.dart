import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: SafeArea(
        child: Column(
          children: [
            // Orange gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎮', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Text(
                        'Games Hub',
                        style: AppTypography.kidsHeadlineLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick a game and start playing!',
                    style: AppTypography.kidsBodyMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: const [
                    _GameCard(
                      title: 'Number Race',
                      emoji: '🏁',
                      description: 'Race to solve math problems the fastest!',
                      bgColor: Color(0xFFFFEDD5),
                    ),
                    _GameCard(
                      title: 'Word Builder',
                      emoji: '🔤',
                      description: 'Build words letter by letter and score big!',
                      bgColor: Color(0xFFEFF6FF),
                    ),
                    _GameCard(
                      title: 'Shape Sorter',
                      emoji: '🔷',
                      description: 'Sort shapes by color, size, and type!',
                      bgColor: Color(0xFFF3E8FF),
                    ),
                    _GameCard(
                      title: 'Memory Match',
                      emoji: '🧠',
                      description: 'Flip cards and find matching pairs!',
                      bgColor: Color(0xFFF0FDF4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final Color bgColor;

  const _GameCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title coming soon! 🚀')),
        );
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.kidsBodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.kidsBodyMd.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange500,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
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
