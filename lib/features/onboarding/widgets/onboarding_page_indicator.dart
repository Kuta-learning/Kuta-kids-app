import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

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
      children: List.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.orange500 : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: active ? null : Border.all(color: Colors.black26, width: 1.5),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.orange500.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
