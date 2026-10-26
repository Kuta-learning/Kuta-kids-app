import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_model.dart';

class HomeRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';

  // Mock data shown while the API is unavailable — mirrors real API courses
  static final List<CourseModel> _mockCourses = [
    const CourseModel(
      id: 'mock-art',
      title: 'Art',
      description: 'Explore creativity through drawing, colors, and art projects.',
      chapterCount: 3,
      completedLessons: 0,
      totalLessons: 10,
      progressPercentage: 0.0,
    ),
    const CourseModel(
      id: 'mock-math',
      title: 'Mathematics',
      description: 'Learn numbers, counting, addition, subtraction, shapes, measurement, time, and money through fun lessons, pictures, activities, and quizzes.',
      chapterCount: 3,
      completedLessons: 8,
      totalLessons: 10,
      progressPercentage: 0.8,
    ),
  ];

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
    try {
      final dio = await _client();
      final response = await dio.get('/courses');
      final data = response.data;

      List<CourseModel> courses = [];

      if (data is List) {
        courses = data
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        // Some APIs wrap the list in a key
        final list = data['courses'] ?? data['data'] ?? [];
        courses = (list as List)
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Fall back to mock data if API returns empty
      return courses.isNotEmpty ? courses : _mockCourses;
    } catch (_) {
      // API unreachable — use mock data
      return _mockCourses;
    }
  }
}
