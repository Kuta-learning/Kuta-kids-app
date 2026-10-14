import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../widgets/onboarding_illustration_card.dart';
import '../widgets/onboarding_page_indicator.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String body;
  final String illustrationAsset;
  final Color cardColor;
  final Color bgTop;
  final Color bgBottom;
  final IconData badgeIcon;
  final Color badgeIconColor;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.illustrationAsset,
    required this.cardColor,
    required this.bgTop,
    required this.bgBottom,
    required this.badgeIcon,
    required this.badgeIconColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      emoji: '🎨',
      title: 'Learn with Fun!',
      body: 'Letters, numbers, colors and shapes — made just for little learners like you!',
      illustrationAsset: 'assets/images/onboarding_1.png',
      cardColor: Color(0xFFDDE8F8),
      bgTop: Color(0xFFFFE0B2),
      bgBottom: Color(0xFFBBDEFB),
      badgeIcon: Icons.abc_rounded,
      badgeIconColor: Color(0xFF1565C0),
    ),
    _OnboardingPage(
      emoji: '🧩',
      title: 'Play & Discover!',
      body: 'Games, puzzles and activities that make every lesson feel like playtime!',
      illustrationAsset: 'assets/images/onboarding_2.png',
      cardColor: Color(0xFFFFF9C4),
      bgTop: Color(0xFFF8BBD0),
      bgBottom: Color(0xFFC8E6C9),
      badgeIcon: Icons.extension_rounded,
      badgeIconColor: Color(0xFFF57F17),
    ),
    _OnboardingPage(
      emoji: '🏆',
      title: 'Earn Stars!',
      body: 'Complete lessons, collect badges and show your parents how brilliant you are!',
      illustrationAsset: 'assets/images/onboarding_3.png',
      cardColor: Color(0xFFDCEDC8),
      bgTop: Color(0xFFE1BEE7),
      bgBottom: Color(0xFFB2EBF2),
      badgeIcon: Icons.emoji_events_rounded,
      badgeIconColor: Color(0xFF2E7D32),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _next() {
    _bounceController.forward(from: 0);
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(RouteNames.register);
    }
  }

  void _skip() => context.go(RouteNames.register);

  void _onPageChanged(int index) => setState(() => _currentPage = index);

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Card height: ~42% of screen height
    final cardHeight = screenHeight * 0.42;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [page.bgTop, page.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative blur circles
              Positioned(
                top: -40,
                right: -40,
                child: _BlurCircle(color: page.bgTop, size: 200),
              ),
              Positioned(
                bottom: 80,
                left: -60,
                child: _BlurCircle(color: page.bgBottom, size: 220),
              ),

              // Main layout
              Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, top: 8),
                      child: _isLastPage
                          ? const SizedBox(height: 36)
                          : GestureDetector(
                              onTap: _skip,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Skip',
                                  style: AppTypography.bodyMdMedium.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── PageView with fixed height ──────────────
                  SizedBox(
                    height: cardHeight,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final p = _pages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: OnboardingIllustrationCard(
                            illustrationAsset: p.illustrationAsset,
                            cardColor: p.cardColor,
                            badgeIcon: p.badgeIcon,
                            badgeIconColor: p.badgeIconColor,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Emoji
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      page.emoji,
                      key: ValueKey('emoji_$_currentPage'),
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        page.title,
                        key: ValueKey('title_$_currentPage'),
                        style: AppTypography.kidsDisplayLg.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Body
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        page.body,
                        key: ValueKey('body_$_currentPage'),
                        style: AppTypography.kidsBodyMd.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Page dots
                  OnboardingPageIndicator(
                    count: _pages.length,
                    currentIndex: _currentPage,
                  ),

                  const Spacer(),

                  // Next / Get Started button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ScaleTransition(
                      scale: _bounceAnimation,
                      child: GestureDetector(
                        onTap: _next,
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.orange500,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.orange500
                                    .withValues(alpha: 0.45),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isLastPage ? "Let's Go! 🚀" : 'Next  →',
                              style: AppTypography.kidsHeadlineLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
