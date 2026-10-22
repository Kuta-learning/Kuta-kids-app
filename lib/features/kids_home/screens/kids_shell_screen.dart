import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../widgets/bottom_nav_bar.dart';

class KidsShellScreen extends StatelessWidget {
  final Widget child;

  const KidsShellScreen({super.key, required this.child});

  static const _tabs = [
    RouteNames.kidsDashboard,
    RouteNames.kidsLearn,
    RouteNames.kidsPractice,
    RouteNames.kidsGames,
    RouteNames.kidsProfile,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: child,
      bottomNavigationBar: KidsBottomNavBar(
        selectedIndex: _currentIndex(context),
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}
