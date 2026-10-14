import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../widgets/onboarding_illustration_card.dart';
import '../widgets/onboarding_page_indicator.dart';

class _OnboardingPage {
  final String title;
  final String body;
  final String illustrationAsset; // Replace with Figma export
  final Color cardColor;
  final IconData badgeIcon;
  final Color badgeIconColor;

  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.illustrationAsset,
    required this.cardColor,
    required this.badgeIcon,
    required this.badgeIconColor,
  });
}

/// 3-page onboarding. Children tap Next / Get Started to advance —
/// they can also swipe. Designed to be bright, friendly, and inviting.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Learn with Fun! 🎨',
      body: 'Colorful lessons made just for you — letters, numbers, shapes, animals, and so much more!',
      illustrationAsset: 'assets/images/onboarding_1.png',
      cardColor: Color(0xFFDDE8F8), // light blue
      badgeIcon: Icons.abc_rounded,
      badgeIconColor: Color(0xFF2563EB),
    ),
    _OnboardingPage(
      title: 'Play & Discover! 🌟',
      body: 'Fun games and activities that make learning feel like playtime every single day.',
      illustrationAsset: 'assets/images/onboarding_2.png',
      cardColor: Color(0xFFFFF0D6), // warm yellow
      badgeIcon: Icons.extension_rounded,
      badgeIconColor: Color(0xFFF59E0B),
    ),
    _OnboardingPage(
      title: 'Grow Every Day! 🚀',
      body: 'Earn stars, badges, and rewards as you learn. Your parents can see how amazing you are!',
      illustrationAsset: 'assets/images/onboarding_3.png',
      cardColor: Color(0xFFDCF5EB), // soft green
      badgeIcon: Icons.emoji_events_rounded,
      badgeIconColor: Color(0xFF06D6A0),
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(RouteNames.login);
    }
  }

  void _skip() => context.go(RouteNames.login);

  void _onPageChanged(int index) => setState(() => _currentPage = index);

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double glowSize = size.width * 0.9;
    const double glowOffset = -80.0;

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Ambient background glows ────────────────────
          Positioned(
            top: glowOffset,
            right: glowOffset,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orange500.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: glowOffset,
            left: glowOffset,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  width: glowSize,
                  height: glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.navy700.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Skip button (top-right)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.space4,
                      top: AppSpacing.space2,
                    ),
                    child: _isLastPage
                        ? const SizedBox(height: 40)
                        : TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Skip',
                              style: AppTypography.bodyMdMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                  ),
                ),

                // Illustration cards (swipeable)
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space6,
                        ),
                        child: OnboardingIllustrationCard(
                          illustrationAsset: page.illustrationAsset,
                          cardColor: page.cardColor,
                          badgeIcon: page.badgeIcon,
                          badgeIconColor: page.badgeIconColor,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.space6),

                // Title + body — animates between pages
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _PageText(
                      key: ValueKey(_currentPage),
                      title: _pages[_currentPage].title,
                      body: _pages[_currentPage].body,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.space6),

                // Page indicator dots
                OnboardingPageIndicator(
                  count: _pages.length,
                  currentIndex: _currentPage,
                ),

                // Space before button
                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Next / Get Started button ────────────────────
          Positioned(
            left: AppSpacing.space6,
            right: AppSpacing.space6,
            bottom: AppSpacing.space6,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLastPage
                  ? _BigButton(
                      key: const ValueKey('start'),
                      label: 'Get Started',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _next,
                    )
                  : _BigButton(
                      key: const ValueKey('next'),
                      label: 'Next',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageText extends StatelessWidget {
  final String title;
  final String body;
  const _PageText({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.displayLg.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          body,
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Large orange pill button — used for both Next and Get Started.
class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _BigButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange500,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.titleMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Icon(icon, size: 20),
          ],
        ),
      ),
    );
  }
}
