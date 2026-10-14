import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Rounded illustration card with a floating icon badge (top-right).
/// When the image asset is not yet available, shows a bright kid-friendly
/// placeholder with a large learning icon.
class OnboardingIllustrationCard extends StatelessWidget {
  final String illustrationAsset;
  final Color cardColor;
  final IconData badgeIcon;
  final Color badgeIconColor;

  const OnboardingIllustrationCard({
    super.key,
    required this.illustrationAsset,
    required this.cardColor,
    required this.badgeIcon,
    required this.badgeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            boxShadow: AppElevation.elevation2,
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.asset(
              illustrationAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _KidsPlaceholder(
                color: cardColor,
                icon: badgeIcon,
                iconColor: badgeIconColor,
              ),
            ),
          ),
        ),

        // Top-right floating badge
        Positioned(
          top: 12,
          right: -8,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: AppRadius.roundedXl,
              boxShadow: AppElevation.elevation2,
            ),
            child: Icon(badgeIcon, color: badgeIconColor, size: 24),
          ),
        ),
      ],
    );
  }
}

/// Kid-friendly placeholder: bright background + large learning icon + label.
class _KidsPlaceholder extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;

  const _KidsPlaceholder({
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
            // Decorative circles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(const Color(0xFFFF6B6B), 14),
                const SizedBox(width: 8),
                _dot(const Color(0xFFFFD166), 18),
                const SizedBox(width: 8),
                _dot(const Color(0xFF06D6A0), 12),
              ],
            ),
            const SizedBox(height: 16),
            // Main icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: iconColor),
            ),
            const SizedBox(height: 16),
            // Decorative dots (bottom)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(const Color(0xFF06D6A0), 10),
                const SizedBox(width: 8),
                _dot(const Color(0xFF2563EB), 14),
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
