import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';

class AuthRepository {
  final ApiClient _api;
  final LocalStorage _storage;

  AuthRepository(this._api, this._storage);

  // Kids register — gradeLevel: 1=Nursery, 2=LKG, 3=UKG
  Future<Map<String, dynamic>> registerKids({
    required String name,
    required String email,
    required String password,
    required int gradeLevel,
  }) async {
    final response = await _api.dio.post('/auth/register/kids', data: {
      'name': name,
      'email': email,
      'password': password,
      'gradeLevel': gradeLevel,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['token'] != null) {
      await _storage.saveTokens(
        data['token'] as String,
        data['refreshToken'] as String? ?? '',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['token'] != null) {
      await _storage.saveTokens(
        data['token'] as String,
        data['refreshToken'] as String? ?? '',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _api.dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword(String email) async {
    await _api.dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _api.dio.post('/auth/verify-otp', data: {
      'email': email,
      'otp': otp,
      'type': 'FORGOT_PASSWORD',
    });
    return (response.data as Map<String, dynamic>)['resetToken'] as String;
  }

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
  }) async {
    await _api.dio.post('/auth/reset-password', data: {
      'email': email,
      'resetToken': resetToken,
      'password': password,
    });
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<bool> isLoggedIn() => _storage.hasToken();

  static String errorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (e.response?.statusCode == 401) return 'Invalid email or password.';
      if (e.response?.statusCode == 409) return 'An account with this email already exists.';
      if (e.response?.statusCode == 400) return 'Please check your details and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
