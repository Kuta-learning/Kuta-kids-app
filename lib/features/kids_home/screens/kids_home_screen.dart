import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';
import '../models/home_models.dart';
import '../widgets/adventure_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/recommended_card.dart';

class KidsHomeScreen extends StatefulWidget {
  const KidsHomeScreen({super.key});

  @override
  State<KidsHomeScreen> createState() => _KidsHomeScreenState();
}

class _KidsHomeScreenState extends State<KidsHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNav = 0;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  static final _adventures = [
    AdventureData(
      title: 'English Adventure',
      emoji: '📖',
      color: const Color(0xFFDDE8F8),
      iconColor: const Color(0xFF2563EB),
      progress: 8,
      total: 12,
      progressColor: const Color(0xFF3B82F6),
    ),
    AdventureData(
      title: 'Math Magic',
      emoji: '🔢',
      color: const Color(0xFFFFEDD5),
      iconColor: const Color(0xFFF97316),
      progress: 4,
      total: 15,
      progressColor: const Color(0xFFF97316),
    ),
    AdventureData(
      title: 'Science Safari',
      emoji: '🌿',
      color: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF16A34A),
      progress: 10,
      total: 10,
      progressColor: const Color(0xFF16A34A),
    ),
    AdventureData(
      title: 'Art Studio',
      emoji: '🎨',
      color: const Color(0xFFFCE7F3),
      iconColor: const Color(0xFFDB2777),
      progress: 3,
      total: 8,
      progressColor: const Color(0xFFDB2777),
    ),
  ];

  static final _recommended = [
    RecommendedData(title: 'Match the Shapes', level: 'Form 35', color: const Color(0xFFFFF7ED)),
    RecommendedData(title: 'Coloring Fun', level: 'Form 11', color: const Color(0xFFF0FDF4)),
    RecommendedData(title: 'Math Safari', level: 'Form 55', color: const Color(0xFFFFF7ED)),
    RecommendedData(title: 'Spelling Bee', level: 'Form 31', color: const Color(0xFFEFF6FF)),
    RecommendedData(title: 'Logic Lights', level: 'Form 46', color: const Color(0xFFFDF4FF)),
    RecommendedData(title: 'Animal Sounds', level: 'MATCH LEVEL', color: const Color(0xFFFFF1F2), locked: true),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Your Adventures 🗺️', 'View All →'),
                    ..._adventures.map((a) => AdventureCard(data: a)),
                    const SizedBox(height: 8),
                    _buildSectionHeader('Recommended for You ⭐', 'View All →'),
                    _buildRecommendedGrid(),
                  ],
                ),
              ),
            ),
            KidsBottomNavBar(
              selectedIndex: _selectedNav,
              onTap: (i) => setState(() => _selectedNav = i),
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
            onTap: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
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

  Widget _buildRecommendedGrid() {
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
        itemCount: _recommended.length,
        itemBuilder: (context, i) => RecommendedCard(data: _recommended[i]),
      ),
    );
  }
}
