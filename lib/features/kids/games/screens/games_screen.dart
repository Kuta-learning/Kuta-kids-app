import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_typography.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            // Purple/indigo gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎮', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Text(
                        'Games Hub',
                        style: AppTypography.kidsHeadlineLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a game and start playing!',
                    style: AppTypography.kidsBodyMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                  children: const [
                    _GameCard(
                      title: 'Number Race',
                      emoji: '🏁',
                      description: 'Race to solve math problems the fastest!',
                      gradient: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                    ),
                    _GameCard(
                      title: 'Word Builder',
                      emoji: '🔤',
                      description: 'Build words letter by letter and score big!',
                      gradient: [Color(0xFFF472B6), Color(0xFFEC4899)],
                    ),
                    _GameCard(
                      title: 'Shape Sorter',
                      emoji: '🔷',
                      description: 'Sort shapes by color, size, and type!',
                      gradient: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                    ),
                    _GameCard(
                      title: 'Memory Match',
                      emoji: '🧠',
                      description: 'Flip cards and find matching pairs!',
                      gradient: [Color(0xFF4ADE80), Color(0xFF16A34A)],
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
  final List<Color> gradient;

  const _GameCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.gradient,
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
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 38)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.kidsBodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
