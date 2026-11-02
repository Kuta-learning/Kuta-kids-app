import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final gradeLevel = prefs.getInt(StorageKeys.gradeLevel);

      // Build query — only add gradeLevel when we have a stored value
      final Map<String, dynamic> query = {};
      if (gradeLevel != null) query['gradeLevel'] = gradeLevel;

      final response = await dio.get('/courses', queryParameters: query);
      final courses = _parseCourses(response.data);

      // Fall back to mock only when the API truly returns nothing
      return courses.isNotEmpty ? courses : _mockCourses;
    } on DioException catch (e) {
      // If we got a 400/401 with gradeLevel, retry without it once
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        try {
          final dio = await _client();
          final response = await dio.get('/courses');
          final courses = _parseCourses(response.data);
          return courses.isNotEmpty ? courses : _mockCourses;
        } catch (_) {
          return _mockCourses;
        }
      }
      return _mockCourses;
    } catch (_) {
      return _mockCourses;
    }
  }

  List<CourseModel> _parseCourses(dynamic data) {
    if (data is List) {
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map) {
      final list = data['courses'] ?? data['data'] ?? data['results'] ?? [];
      return (list as List)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
