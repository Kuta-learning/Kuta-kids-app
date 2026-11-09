import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';

class _Page {
  final String title;
  final String body;
  final String asset;

  const _Page({
    required this.title,
    required this.body,
    required this.asset,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _Page(
      title: 'Learn\nWith Fun',
      body:
          'Letters, numbers, colors and shapes — made just for little learners like you!',
      asset: 'assets/images/onboarding_1.png',
    ),
    _Page(
      title: 'Learn\nStep-by-Step',
      body: 'Master new subjects with\nclear video guides and easy lessons.',
      asset: 'assets/images/onboarding_2.png',
    ),
    _Page(
      title: 'Track\nYour Progress',
      body: 'Complete quick quizzes, review your answers, and improve every day!',
      asset: 'assets/images/onboarding_3.png',
    ),
  ];

  bool get _isLast => _currentPage == _pages.length - 1;

  void _next() {
    if (!_isLast) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(RouteNames.register);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Swipeable image area ────────────────────────────────────
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, i) =>
                    _IllustrationPage(asset: _pages[i].asset),
              ),
            ),

            // ── Text + dots + button ────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _pages[_currentPage].title,
                        key: ValueKey('title$_currentPage'),
                        style: AppTypography.kidsDisplayLg.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1A2E),
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _pages[_currentPage].body,
                        key: ValueKey('body$_currentPage'),
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 14,
                          color: Colors.black45,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Spacer(),

                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.orange500
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLast ? 'Get Started' : 'Next',
                              style: AppTypography.kidsBodyMd.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 20, color: Colors.white),
                          ],
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Illustration for each page — no clipping, no border, full natural size
// ─────────────────────────────────────────────────────────────────────────────

class _IllustrationPage extends StatelessWidget {
  final String asset;

  const _IllustrationPage({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, e, s) => const Center(
          child: Icon(Icons.menu_book_rounded, size: 80, color: Color(0xFFFFB060)),
        ),
      ),
    );
  }
}
