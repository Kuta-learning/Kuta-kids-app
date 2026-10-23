import '../../../core/constants/grade_level.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final GradeLevel gradeLevel;
  final int gradeLevelInt;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.gradeLevel,
    required this.gradeLevelInt,
  });
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
