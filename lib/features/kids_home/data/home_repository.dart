import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_model.dart';

class HomeRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';

  Future<Dio> _client() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));
    return dio;
  }

  Future<List<CourseModel>> getCourses() async {
    final dio = await _client();
    final response = await dio.get('/courses');
    final data = response.data;

    if (data is List) {
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Some APIs wrap the list in a key
    if (data is Map) {
      final list = data['courses'] ?? data['data'] ?? [];
      return (list as List)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
