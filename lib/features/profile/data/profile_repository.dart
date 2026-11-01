import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/storage_keys.dart';
import 'profile_model.dart';

class ProfileRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';

  static const ProfileModel _mockProfile = ProfileModel(
    name: 'Super Leo',
    email: 'leo@example.com',
    gradeLevel: 1,
    avatarUrl: null,
    stars: 1250,
    badges: null,
  );

  Future<Dio> _client() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));
  }

  /// GET /auth/me — returns the student's profile.
  /// Falls back to [_mockProfile] on any error.
  Future<ProfileModel> getProfile() async {
    try {
      final dio = await _client();
      final response = await dio.get('/auth/me');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ProfileModel.fromJson(data);
      }
      return _mockProfile;
    } catch (_) {
      return _mockProfile;
    }
  }

  /// PUT /auth/profile — updates the student's name or avatar.
  /// Returns `true` on 2xx, `false` on error.
  Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    try {
      final dio = await _client();
      final body = <String, String>{
        'name': name ?? '',
        'avatarUrl': avatarUrl ?? '',
      }..removeWhere((_, v) => v.isEmpty);
      await dio.put('/auth/profile', data: body);
      return true;
    } catch (_) {
      return false;
    }
  }
}
