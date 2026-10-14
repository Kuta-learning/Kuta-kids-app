import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart'; // AppSpacing, AppRadius, AppElevation

/// The large rounded illustration card shown on each onboarding page.
/// Features a top-right icon badge and a bottom-left icon badge, exactly
/// as shown in the Figma design.
///
/// Replace [illustrationAsset] with your Figma-exported PNG.
/// Until the asset is added, a styled color placeholder is shown.
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
        // Main illustration card
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

        // Top-right floating icon badge
        Positioned(
          top: -(AppSpacing.space2),
          right: -(AppSpacing.space2),
          child: _IconBadge(
            icon: topBadgeIcon,
            iconColor: AppColors.secondAccent,
          ),
        ),

        // Bottom-left floating icon badge
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
    return Image.asset(
      illustrationAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Styled placeholder shown until real Figma illustrations are added
        return _IllustrationPlaceholder(
          color: placeholderColor,
          icon: topBadgeIcon,
        );
      },
    );
  }
}

/// Small white rounded square icon badge — floating decorator on the card.
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

/// Placeholder shown when illustration PNG asset is not yet added.
/// Displays a large centered icon on the page's background color.
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              'Add illustration to\nassets/images/',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
