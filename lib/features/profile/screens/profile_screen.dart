import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
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
                      fontWeight: FontWeight.w800,
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildStatCard(
                    icon: Icons.star_rounded,
                    iconBackground: const Color(0xFFE0F2FE),
                    iconColor: AppColors.info,
                    title: 'Total Stars Collected',
                    value: '1,250',
                    valueColor: AppColors.info,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    icon: Icons.military_tech_rounded,
                    iconBackground: const Color(0xFFFFEDD5),
                    iconColor: AppColors.orange500,
                    title: 'Badges Won',
                    value: '24',
                    valueColor: AppColors.orange500,
                  ),
                  const SizedBox(height: 16),
                  _buildRecentBadges(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.progress),
                      icon: const Icon(Icons.insights_rounded),
                      label: const Text('View Progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange500,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.read<AuthBloc>().add(
                        const AuthLogoutRequested(),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.orange900,
                        side: const BorderSide(color: AppColors.orange500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.info, width: 4),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE2ECF8), Color(0xFFC3D8F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.pets_rounded,
                  size: 60,
                  color: AppColors.info,
                ),
              ),
            ),
            Positioned(
              bottom: -12,
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
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Super Leo',
          textAlign: TextAlign.center,
          style: AppTypography.kidsHeadlineLg.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.orange900,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF93C5FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'Level 5 Explorer',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Keep exploring, Leo! You're only 50 stars away from your next big discovery!",
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
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconBackground,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.kidsHeadlineLg.copyWith(
              fontSize: 32,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBadges() {
    final badges = [
      ('Fast Reader', Icons.menu_book_rounded, const Color(0xFFFFB020)),
      ('Math Whiz', Icons.calculate_rounded, const Color(0xFF3B82F6)),
      ('Earth Hero', Icons.eco_rounded, const Color(0xFF10B981)),
      ('Pixel Artist', Icons.palette_rounded, const Color(0xFF8B5CF6)),
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
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'View All',
                style: AppTypography.kidsBodyMd.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange900,
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
                    color: badge.$3,
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
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
