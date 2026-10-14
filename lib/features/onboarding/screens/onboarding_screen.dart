import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../widgets/onboarding_illustration_card.dart';
import '../widgets/onboarding_page_indicator.dart';

/// Data model for a single onboarding page.
class _OnboardingPage {
  final String title;
  final String body;

  /// Local asset path — place your Figma-exported PNG here.
  /// Falls back to [placeholderColor] if the asset is missing.
  final String illustrationAsset;
  final Color placeholderColor;
  final IconData topBadgeIcon;
  final IconData bottomBadgeIcon;

  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.illustrationAsset,
    required this.placeholderColor,
    required this.topBadgeIcon,
    required this.bottomBadgeIcon,
  });
}

/// Onboarding screen with 3 swipeable pages, page indicator, and Get Started button.
/// Navigation flow: Splash → Onboarding → Login
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Learn & Play',
      body:
          'Fun lessons designed for Nursery, Lower KG, and Upper KG children with pictures, sounds, and games.',
      illustrationAsset: 'assets/images/onboarding_1.png',
      placeholderColor: const Color(0xFFDDE8F8),
      topBadgeIcon: Icons.star_rounded,
      bottomBadgeIcon: Icons.music_note_rounded,
    ),
    _OnboardingPage(
      title: 'Track Progress',
      body:
          'Watch your child grow with daily goals, streaks, and achievements they will love to collect.',
      illustrationAsset: 'assets/images/onboarding_2.png',
      placeholderColor: const Color(0xFFE8F5E9),
      topBadgeIcon: Icons.emoji_events_rounded,
      bottomBadgeIcon: Icons.bar_chart_rounded,
    ),
    _OnboardingPage(
      title: 'Excel in Your Exams',
      body:
          'Personalized learning paths for Nursery, Lower KG, and Upper KG. Master topics with interactive practice and expert guidance.',
      illustrationAsset: 'assets/images/onboarding_3.png',
      placeholderColor: const Color(0xFFFFF3E0),
      topBadgeIcon: Icons.calculate_rounded,
      bottomBadgeIcon: Icons.menu_book_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _onGetStarted() {
    context.go(RouteNames.login);
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
          // ── Background ambient glows (same as splash) ────
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

          // ── Main content ─────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Illustration page view
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.space8,
                          left: AppSpacing.space6,
                          right: AppSpacing.space6,
                        ),
                        child: OnboardingIllustrationCard(
                          illustrationAsset: page.illustrationAsset,
                          placeholderColor: page.placeholderColor,
                          topBadgeIcon: page.topBadgeIcon,
                          bottomBadgeIcon: page.bottomBadgeIcon,
                        ),
                      );
                    },
                  ),
                ),

                // Title + body text
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _PageText(
                        key: ValueKey(_currentPage),
                        title: _pages[_currentPage].title,
                        body: _pages[_currentPage].body,
                      ),
                    ),
                  ),
                ),

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

          // ── Get Started button pinned to bottom ──────────
          Positioned(
            left: AppSpacing.space6,
            right: AppSpacing.space6,
            bottom: AppSpacing.space6,
            child: _GetStartedButton(onPressed: _onGetStarted),
          ),
        ],
      ),
    );
  }
}

/// Title + body text for a single onboarding page.
class _PageText extends StatelessWidget {
  final String title;
  final String body;

  const _PageText({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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

/// Orange pill "Get Started →" button.
class _GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GetStartedButton({required this.onPressed});

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
              'Get Started',
              style: AppTypography.titleMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
