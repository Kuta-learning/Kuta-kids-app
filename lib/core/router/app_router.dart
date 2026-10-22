import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/common/screens/splash_screen.dart';
import '../../features/kids/games/screens/games_screen.dart';
import '../../features/kids/practice/presentation/pages/practice_home_page.dart';
import '../../features/kids_home/screens/kids_home_screen.dart';
import '../../features/kids_home/screens/kids_shell_screen.dart';
import '../../features/learning/screens/learn_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      // Auth flow
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Kids shell with persistent bottom nav
      ShellRoute(
        builder: (context, state, child) =>
            KidsShellScreen(child: child),
        routes: [
          GoRoute(
            path: RouteNames.kidsDashboard,
            name: 'kidsDashboard',
            builder: (context, state) => const KidsHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.kidsLearn,
            name: 'kidsLearn',
            builder: (context, state) => const LearnScreen(),
          ),
          GoRoute(
            path: RouteNames.kidsPractice,
            name: 'kidsPractice',
            builder: (context, state) => const PracticeHomePage(),
          ),
          GoRoute(
            path: RouteNames.kidsGames,
            name: 'kidsGames',
            builder: (context, state) => const GamesScreen(),
          ),
          GoRoute(
            path: RouteNames.kidsProfile,
            name: 'kidsProfile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Legacy stubs
      GoRoute(
        path: RouteNames.kgHome,
        name: 'kgHome',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('KG Home'))),
      ),
      GoRoute(
        path: RouteNames.gradeDashboard,
        name: 'gradeDashboard',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Grade Dashboard'))),
      ),
      GoRoute(
        path: RouteNames.subjectDetail,
        name: 'subjectDetail',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Subject Detail'))),
      ),
      GoRoute(
        path: RouteNames.quiz,
        name: 'quiz',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Quiz'))),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile'))),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('No route defined for ${state.uri}')),
    ),
  );

  AppRouter._();
}
