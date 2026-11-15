import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../data/profile_model.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileBloc(ProfileRepository())..add(const ProfileRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Kuta Learning',
                    style: AppTypography.kidsHeadlineLg.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        ),
                    tooltip: 'Log out',
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  ProfileModel? profile;
                  if (state is ProfileLoaded) {
                    profile = state.profile;
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildProfileHeader(context, profile),
                      const SizedBox(height: 20),
                      _buildStatCard(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.info,
                        title: 'Total Stars Collected',
                        value:
                            profile?.stars != null ? '${profile!.stars}' : '–',
                        gradient: const [
                          Color(0xFF60A5FA),
                          Color(0xFF2563EB)
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        icon: Icons.military_tech_rounded,
                        iconColor: AppColors.orange500,
                        title: 'Badges Won',
                        value: profile?.badges != null
                            ? '${profile!.badges!.length}'
                            : '–',
                        gradient: const [
                          Color(0xFFFFB347),
                          Color(0xFFFF8C00)
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecentBadges(context),
                      const SizedBox(height: 24),
                      // View Progress — playful gradient button
                      GestureDetector(
                        onTap: () => context.push(RouteNames.progress),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF97316),
                                Color(0xFFEC4899)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899)
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.insights_rounded,
                                  color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'View Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Log out — playful outlined button
                      GestureDetector(
                        onTap: () => context.read<AuthBloc>().add(
                              const AuthLogoutRequested(),
                            ),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                                color: AppColors.orange500, width: 2),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded,
                                  color: AppColors.orange900, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Log out',
                                style: TextStyle(
                                  color: AppColors.orange900,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel? profile) {
    final name = profile?.name ?? '';
    final gradeLabel = profile != null ? 'Grade ${profile.gradeLevel}' : '';
    final avatarUrl = profile?.avatarUrl;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Colorful gradient ring
            Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context2, err, stack) => const Icon(
                              Icons.pets_rounded,
                              size: 72,
                              color: AppColors.info,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.pets_rounded,
                              size: 72,
                              color: AppColors.info,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            // Animated sparkle
            const Positioned(
              top: -4,
              right: 6,
              child: _Sparkle(),
            ),
            // Change avatar pill
            Positioned(
              bottom: -12,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar customisation coming soon!'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange500,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange500.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Change Avatar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        name.isEmpty
            ? Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              )
            : Text(
                name,
                textAlign: TextAlign.center,
                style: AppTypography.kidsHeadlineLg.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.orange900,
                ),
              ),
        const SizedBox(height: 8),
        gradeLabel.isEmpty
            ? Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      gradeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            name.isEmpty
                ? "Keep exploring! You're doing great!"
                : "Keep exploring, $name! You're doing great — every lesson brings you closer to mastery!",
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.kidsHeadlineLg.copyWith(
              fontSize: 34,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBadges(BuildContext context) {
    final badges = [
      (
        'Fast Reader',
        Icons.menu_book_rounded,
        const [Color(0xFFFFD166), Color(0xFFF59E0B)]
      ),
      (
        'Math Whiz',
        Icons.calculate_rounded,
        const [Color(0xFF60A5FA), Color(0xFF2563EB)]
      ),
      (
        'Earth Hero',
        Icons.eco_rounded,
        const [Color(0xFF4ADE80), Color(0xFF16A34A)]
      ),
      (
        'Pixel Artist',
        Icons.palette_rounded,
        const [Color(0xFFF472B6), Color(0xFFEC4899)]
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Recent Badges',
                style: AppTypography.kidsBodyMd.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Badge gallery coming soon! 🏆')),
                  );
                },
                child: Text(
                  'View All',
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: badges
                .map(
                  (badge) => _buildBadgeItem(
                    title: badge.$1,
                    icon: badge.$2,
                    gradient: badge.$3,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required String title,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: gradient.last, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A gently pulsing sparkle for the avatar.
// ─────────────────────────────────────────────────────────────────────────────

class _Sparkle extends StatefulWidget {
  const _Sparkle();

  @override
  State<_Sparkle> createState() => _SparkleState();
}

class _SparkleState extends State<_Sparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1.15).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
      ),
      child: const Text('✨', style: TextStyle(fontSize: 30)),
    );
  }
}
