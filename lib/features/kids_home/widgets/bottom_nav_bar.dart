import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class KidsBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const KidsBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'Learn'),
    _NavItem(icon: Icons.edit_rounded, label: 'Practice'),
    _NavItem(icon: Icons.sports_esports_rounded, label: 'Games'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == selectedIndex;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFF97316),
                                    Color(0xFFEC4899)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFEC4899)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          item.icon,
                          size: 24,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: selected
                              ? AppColors.orange500
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
