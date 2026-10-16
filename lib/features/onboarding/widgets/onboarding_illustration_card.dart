import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class OnboardingIllustrationCard extends StatelessWidget {
  final String asset;
  final Color cardColor;
  final IconData badgeIcon;
  final Color badgeIconColor;

  const OnboardingIllustrationCard({
    super.key,
    required this.asset,
    required this.cardColor,
    required this.badgeIcon,
    required this.badgeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Placeholder(
                color: cardColor,
                icon: badgeIcon,
                iconColor: badgeIconColor,
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: -10,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(badgeIcon, color: badgeIconColor, size: 26),
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;

  const _Placeholder({
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(const Color(0xFFFF6B6B), 14),
                const SizedBox(width: 8),
                _dot(const Color(0xFFFFD166), 20),
                const SizedBox(width: 8),
                _dot(const Color(0xFF06D6A0), 12),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(const Color(0xFF06D6A0), 10),
                const SizedBox(width: 8),
                _dot(AppColors.navy700, 14),
                const SizedBox(width: 8),
                _dot(const Color(0xFFFFD166), 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
