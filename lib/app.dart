import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/bloc/auth_bloc.dart';
import 'features/authentication/bloc/auth_event.dart';
import 'features/authentication/data/auth_repository.dart';

class KutaApp extends StatelessWidget {
  const KutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final localStorage = LocalStorage();
    final authRepository = AuthRepository(apiClient, localStorage);

    return BlocProvider(
      create: (_) => AuthBloc(authRepository)..add(AuthCheckRequested()),
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
