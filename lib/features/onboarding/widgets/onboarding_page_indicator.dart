import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Row of page indicator dots.
/// The active dot is an elongated pill; inactive dots are small circles.
/// Matches the Figma design exactly.
class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.orange500
                : AppColors.borderVariant,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
