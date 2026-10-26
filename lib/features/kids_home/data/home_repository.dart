import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course_model.dart';

class HomeRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';

  // Mock data shown while the API is unavailable
  static final List<CourseModel> _mockCourses = [
    const CourseModel(
      id: 'mock-1',
      title: 'Arabic Letters',
      description: 'Learn the Arabic alphabet step by step',
      chapterCount: 4,
      completedLessons: 3,
      totalLessons: 12,
      progressPercentage: 0.25,
    ),
    const CourseModel(
      id: 'mock-2',
      title: 'Numbers & Counting',
      description: 'Fun with numbers from 1 to 100',
      chapterCount: 3,
      completedLessons: 0,
      totalLessons: 10,
      progressPercentage: 0.0,
    ),
    const CourseModel(
      id: 'mock-3',
      title: 'Colors & Shapes',
      description: 'Explore the world of colors and shapes',
      chapterCount: 2,
      completedLessons: 5,
      totalLessons: 8,
      progressPercentage: 0.625,
    ),
    const CourseModel(
      id: 'mock-4',
      title: 'Animals & Nature',
      description: 'Discover amazing animals and nature',
      chapterCount: 5,
      completedLessons: 1,
      totalLessons: 15,
      progressPercentage: 0.067,
    ),
    const CourseModel(
      id: 'mock-5',
      title: 'Stories & Reading',
      description: 'Short fun stories for early readers',
      chapterCount: 3,
      completedLessons: 0,
      totalLessons: 9,
      progressPercentage: 0.0,
    ),
    const CourseModel(
      id: 'mock-6',
      title: 'Music & Rhymes',
      description: 'Songs, rhymes, and musical fun',
      chapterCount: 2,
      completedLessons: 2,
      totalLessons: 6,
      progressPercentage: 0.333,
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
