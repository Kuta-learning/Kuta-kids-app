import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// The large rounded illustration card shown on each onboarding page.
/// Has a top-right icon badge and a bottom-left icon badge overlapping
/// the card edges, exactly as in the Figma design.
class OnboardingIllustrationCard extends StatelessWidget {
  final String illustrationAsset;
  final Color placeholderColor;
  final IconData topBadgeIcon;
  final IconData bottomBadgeIcon;

  const OnboardingIllustrationCard({
    super.key,
    required this.illustrationAsset,
    required this.placeholderColor,
    required this.topBadgeIcon,
    required this.bottomBadgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main illustration card ────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            boxShadow: AppElevation.elevation2,
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _illustrationWidget(),
          ),
        ),

        // ── Top-right floating badge ──────────────────────
        Positioned(
          top: 12,
          right: -8,
          child: _IconBadge(
            icon: topBadgeIcon,
            iconColor: AppColors.secondAccent,
          ),
        ),

        // ── Bottom-left floating badge ────────────────────
        Positioned(
          bottom: 16,
          left: -8,
          child: _IconBadge(
            icon: bottomBadgeIcon,
            iconColor: AppColors.kgGreen,
          ),
        ),
      ],
    );
  }

  Widget _illustrationWidget() {
    return Image.asset(
      illustrationAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _IllustrationPlaceholder(
          color: placeholderColor,
          icon: bottomBadgeIcon,
        );
      },
    );
  }
}

/// Small white rounded square floating icon badge.
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _IconBadge({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.roundedXl,
        boxShadow: AppElevation.elevation2,
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}

/// Shown when illustration PNG has not been added yet.
/// Uses a learning-relevant icon matching the page topic.
class _IllustrationPlaceholder extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _IllustrationPlaceholder({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: AppColors.textSecondary.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
