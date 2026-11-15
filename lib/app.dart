import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/bloc/auth_bloc.dart';
import 'features/authentication/bloc/auth_state.dart';

class KutaApp extends StatelessWidget {
  const KutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          AppRouter.router.go(RouteNames.login);
        } else if (state is AuthAuthenticated) {
          // Only redirect on login/register — not on every rebuild.
          // go_router handles the initial route via splash.
          final location =
              AppRouter.router.routerDelegate.currentConfiguration.uri.toString();
          final isOnAuthScreen = location == RouteNames.login ||
              location == RouteNames.register ||
              location == RouteNames.splash;
          if (isOnAuthScreen) {
            AppRouter.router.go(RouteNames.kidsDashboard);
          }
        }
      },
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
