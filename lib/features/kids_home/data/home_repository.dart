import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';
import '../models/course_model.dart';

class HomeRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';
  static const int _ttlMs = 300000; // 5 minutes

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
      description:
          'Learn numbers, counting, addition, subtraction, shapes, measurement, time, and money through fun lessons, pictures, activities, and quizzes.',
      chapterCount: 3,
      completedLessons: 8,
      totalLessons: 10,
      progressPercentage: 0.8,
    ),
  ];

  Future<Dio> _client() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);
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
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(StorageKeys.cacheCourses);
    final ts = prefs.getInt(StorageKeys.cacheCoursesTs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && (now - ts) < _ttlMs) {
      // Return cached data immediately and re-fetch in the background.
      final courses = _decodeCourses(cached);
      if (courses != null) {
        unawaited(_fetchAndCache(prefs));
        return courses;
      }
    }

    // Cache miss or expired — fetch normally.
    return _fetchAndCache(prefs);
  }

  Future<List<CourseModel>> _fetchAndCache(SharedPreferences prefs) async {
    try {
      final gradeLevel = prefs.getInt(StorageKeys.gradeLevel);
      final Map<String, dynamic> query = {};
      if (gradeLevel != null) query['gradeLevel'] = gradeLevel;

      final dio = await _client();
      final response = await dio.get('/courses', queryParameters: query);
      final courses = _parseCourses(response.data);
      final result = courses.isNotEmpty ? courses : _mockCourses;
      await _writeCache(prefs, result);
      return result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        try {
          final dio = await _client();
          final response = await dio.get('/courses');
          final courses = _parseCourses(response.data);
          final result = courses.isNotEmpty ? courses : _mockCourses;
          await _writeCache(prefs, result);
          return result;
        } catch (_) {
          return _cachedOrMock(prefs);
        }
      }
      return _cachedOrMock(prefs);
    } catch (_) {
      return _cachedOrMock(prefs);
    }
  }

  Future<void> _writeCache(
      SharedPreferences prefs, List<CourseModel> courses) async {
    await prefs.setString(
      StorageKeys.cacheCourses,
      jsonEncode(courses.map((c) => c.toJson()).toList()),
    );
    await prefs.setInt(
      StorageKeys.cacheCoursesTs,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<CourseModel> _cachedOrMock(SharedPreferences prefs) {
    final cached = prefs.getString(StorageKeys.cacheCourses);
    if (cached != null) {
      final courses = _decodeCourses(cached);
      if (courses != null) return courses;
    }
    return _mockCourses;
  }

  List<CourseModel>? _decodeCourses(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
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
