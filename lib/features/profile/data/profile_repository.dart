import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/storage_keys.dart';
import 'profile_model.dart';

class ProfileRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';
  static const int _ttlMs = 300000; // 5 minutes

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
  /// Uses stale-while-revalidate cache (5 min TTL).
  Future<ProfileModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(StorageKeys.cacheProfile);
    final ts = prefs.getInt(StorageKeys.cacheProfileTs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && (now - ts) < _ttlMs) {
      try {
        final profile = ProfileModel.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
        unawaited(_fetchAndCacheProfile(prefs));
        return profile;
      } catch (_) {}
    }

    return _fetchAndCacheProfile(prefs);
  }

  Future<ProfileModel> _fetchAndCacheProfile(SharedPreferences prefs) async {
    try {
      final dio = await _client();
      final response = await dio.get('/auth/me');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final profile = ProfileModel.fromJson(data);
        await prefs.setString(
          StorageKeys.cacheProfile,
          jsonEncode({
            'name': profile.name,
            'email': profile.email,
            'gradeLevel': profile.gradeLevel,
            'avatarUrl': profile.avatarUrl,
            'stars': profile.stars,
            'badges': profile.badges,
          }),
        );
        await prefs.setInt(
          StorageKeys.cacheProfileTs,
          DateTime.now().millisecondsSinceEpoch,
        );
        return profile;
      }
      return _cachedOrMock(prefs);
    } catch (_) {
      return _cachedOrMock(prefs);
    }
  }

  ProfileModel _cachedOrMock(SharedPreferences prefs) {
    final cached = prefs.getString(StorageKeys.cacheProfile);
    if (cached != null) {
      try {
        return ProfileModel.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    return _mockProfile;
  }

  /// PUT /auth/profile — updates the student's name, avatar, or grade.
  /// Returns `true` on 2xx, `false` on error.
  /// Also clears the profile cache so the next fetch gets fresh data.
  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
    int? gradeLevel,
  }) async {
    try {
      final dio = await _client();
      final body = <String, dynamic>{
        if (name != null && name.isNotEmpty) 'name': name,
        if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
        'gradeLevel': ?gradeLevel,
      };
      await dio.put('/auth/profile', data: body);

      // Clear the cache so the next getProfile() fetches fresh data.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.cacheProfile);
      await prefs.remove(StorageKeys.cacheProfileTs);

      // Persist grade level locally too.
      if (gradeLevel != null) {
        await prefs.setInt(StorageKeys.gradeLevel, gradeLevel);
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
