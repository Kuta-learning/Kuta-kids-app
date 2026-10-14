import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart'; // AppSpacing, AppRadius, AppElevation

/// The large rounded illustration card shown on each onboarding page.
/// Features a top-right icon badge and a bottom-left icon badge, exactly
/// as shown in the Figma design.
class OnboardingIllustrationCard extends StatelessWidget {
  final String illustrationAsset;
  final IconData topBadgeIcon;
  final IconData bottomBadgeIcon;

  const OnboardingIllustrationCard({
    super.key,
    required this.illustrationAsset,
    required this.topBadgeIcon,
    required this.bottomBadgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main illustration card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE8F8), // light blue-lavender as in Figma
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            boxShadow: AppElevation.elevation2,
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _illustrationWidget(),
          ),
        ),

        // Top-right icon badge
        Positioned(
          top: -(AppSpacing.space2),
          right: -(AppSpacing.space2),
          child: _IconBadge(icon: topBadgeIcon),
        ),

        // Bottom-left icon badge
        Positioned(
          bottom: AppSpacing.space4,
          left: -(AppSpacing.space2),
          child: _IconBadge(
            icon: bottomBadgeIcon,
            iconColor: AppColors.kgGreen,
          ),
        ),
      ],
    );
  }

  Widget _illustrationWidget() {
    // Try to load the asset; fall back to a placeholder if not found.
    return Image.asset(
      illustrationAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const _IllustrationPlaceholder();
      },
    );
  }
}

/// Small white rounded square icon badge used as floating decorators on the card.
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _IconBadge({
    required this.icon,
    this.iconColor = AppColors.secondAccent,
  });

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

/// Fallback placeholder shown when illustration asset is missing.
class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDDE8F8),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
