import '../../../core/constants/grade_level.dart';

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final GradeLevel gradeLevel;
  final int gradeLevelInt;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.gradeLevel,
    required this.gradeLevelInt,
  });
}
