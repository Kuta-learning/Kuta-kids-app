import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'features/authentication/bloc/auth_bloc.dart';
import 'features/authentication/bloc/auth_event.dart';
import 'features/authentication/services/dio_auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(DioAuthService())..add(const AuthCheckRequested()),
      child: const KutaApp(),
    ),
  );
}
