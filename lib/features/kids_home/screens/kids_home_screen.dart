import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../data/home_repository.dart';
import '../models/course_model.dart';
import '../widgets/adventure_card.dart';
import '../widgets/recommended_card.dart';

class KidsHomeScreen extends StatefulWidget {
  const KidsHomeScreen({super.key});

  @override
  State<KidsHomeScreen> createState() => _KidsHomeScreenState();
}

class _KidsHomeScreenState extends State<KidsHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  static const _courseEmojis = ['📖', '🔢', '🌿', '🎨', '🎵', '🌍', '🔬', '🏃'];
  static const _courseColors = [
    Color(0xFFDDE8F8),
    Color(0xFFFFEDD5),
    Color(0xFFDCFCE7),
    Color(0xFFFCE7F3),
    Color(0xFFFFF9C4),
    Color(0xFFE0F2FE),
    Color(0xFFF3E8FF),
    Color(0xFFFFEDD5),
  ];
  static const _progressColors = [
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFFEAB308),
    Color(0xFF0EA5E9),
    Color(0xFF9333EA),
    Color(0xFFF97316),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(HomeRepository())..add(const HomeRequested()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange500,
                        ),
                      );
                    }
                    if (state is HomeError) {
                      return _buildError(context, state.message);
                    }
                    if (state is HomeLoaded) {
                      return _buildContent(context, state.courses);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<CourseModel> courses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Your Adventures 🗺️', 'View All →'),
          if (courses.isEmpty)
            _buildEmptyState()
          else
            ...courses.asMap().entries.map((entry) {
              final i = entry.key;
              final course = entry.value;
              return AdventureCard(
                title: course.title,
                emoji: _courseEmojis[i % _courseEmojis.length],
                color: _courseColors[i % _courseColors.length],
                progress: course.completedLessons,
                total: course.totalLessons,
                progressColor: _progressColors[i % _progressColors.length],
              );
            }),
          const SizedBox(height: 8),
          _buildSectionHeader('Recommended for You ⭐', 'View All →'),
          _buildRecommendedGrid(courses),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: AppTypography.kidsHeadlineLg.copyWith(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.kidsBodyMd.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () =>
                  context.read<HomeBloc>().add(const HomeRequested()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.orange500,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange500.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Try Again 🔄',
                  style: AppTypography.kidsBodyMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Text('🎒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'No adventures yet!',
              style: AppTypography.kidsHeadlineLg.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your courses will appear here.',
              style: AppTypography.kidsBodyMd
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _waveAnimation.value),
              child: child,
            ),
            child: const Text('🌟', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 10),
          Text(
            'Kuta Learning',
            style: AppTypography.kidsHeadlineLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.kidsHeadlineLg.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Text(
              action,
              style: AppTypography.kidsBodyMd.copyWith(
                color: AppColors.orange500,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedGrid(List<CourseModel> courses) {
    final recommended = courses
        .where((c) => c.progressPercentage < 1.0)
        .take(6)
        .toList();

    if (recommended.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            '🎉 You\'ve completed everything!',
            style: AppTypography.kidsBodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: recommended.length,
        itemBuilder: (context, i) {
          final course = recommended[i];
          return RecommendedCard(
            title: course.title,
            level: '${course.completedLessons}/${course.totalLessons} lessons',
            color: _courseColors[i % _courseColors.length],
          );
        },
      ),
    );
  }
}
