import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/grade_level.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class DioAuthService implements AuthService {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  late final Dio _dio;

  DioAuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return null;
      final response = await _dio.get('/auth/me');
      return _userFromResponse(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await _saveTokens(data);
      return _userFromResponse(data);
    } on DioException catch (e) {
      throw AuthException(_errorMessage(e));
    }
  }

  @override
  Future<UserModel> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/auth/register/kids', data: {
        'name': request.name,
        'email': request.email,
        'password': request.password,
        'gradeLevel': _gradeLevelToInt(request.gradeLevel),
      });
      final data = response.data as Map<String, dynamic>;
      await _saveTokens(data);
      return _userFromResponse(data);
    } on DioException catch (e) {
      throw AuthException(_errorMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['token'] != null) {
      await prefs.setString(_tokenKey, data['token'] as String);
    }
    if (data['refreshToken'] != null) {
      await prefs.setString(_refreshTokenKey, data['refreshToken'] as String);
    }
  }

  UserModel _userFromResponse(Map<String, dynamic> data) {
    final student = data['student'] as Map<String, dynamic>? ?? data;
    return UserModel(
      id: student['_id']?.toString() ?? student['id']?.toString() ?? '',
      email: student['email']?.toString() ?? '',
      name: student['name']?.toString() ?? '',
      gradeLevel: _gradeLevelFromInt(student['gradeLevel'] as int? ?? 1),
    );
  }

  GradeLevel _gradeLevelFromInt(int level) {
    switch (level) {
      case 1:
      case 2:
      case 3:
      case 4:
        return GradeLevel.kg;
      case 6:
        return GradeLevel.grade6;
      case 8:
        return GradeLevel.grade8;
      case 12:
        return GradeLevel.grade12;
      default:
        return GradeLevel.kg;
    }
  }

  int _gradeLevelToInt(GradeLevel level) {
    switch (level) {
      case GradeLevel.kg:
        return 2; // default LKG
      case GradeLevel.grade6:
        return 6;
      case GradeLevel.grade8:
        return 8;
      case GradeLevel.grade12:
        return 12;
    }
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Invalid email or password.';
      case 409:
        return 'An account with this email already exists.';
      case 400:
        return 'Please check your details and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
