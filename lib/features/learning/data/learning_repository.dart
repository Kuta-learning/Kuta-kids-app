import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';
import '../models/chapter_model.dart';

class LearningRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';
  static const int _ttlMs = 300000; // 5 minutes

  Future<Dio> _client() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
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

  Future<CourseDetailModel> getCourseDetail(String courseId) async {
    // Only use mock data for placeholder IDs — real IDs go to the API
    if (courseId.startsWith('mock-')) return _mockCourse(courseId);

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = StorageKeys.cacheCourseDetail(courseId);
    final tsKey = StorageKeys.cacheCourseDetailTs(courseId);
    final cached = prefs.getString(cacheKey);
    final ts = prefs.getInt(tsKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && (now - ts) < _ttlMs) {
      // Return cached immediately and re-fetch in background.
      try {
        final detail = CourseDetailModel.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
        unawaited(_fetchAndCacheCourse(courseId, prefs, cacheKey, tsKey));
        return detail;
      } catch (_) {
        // Fall through to network fetch on decode error.
      }
    }

    return _fetchAndCacheCourse(courseId, prefs, cacheKey, tsKey);
  }

  Future<CourseDetailModel> _fetchAndCacheCourse(
    String courseId,
    SharedPreferences prefs,
    String cacheKey,
    String tsKey,
  ) async {
    try {
      final dio = await _client();
      final response = await dio.get('/courses/$courseId');
      final raw = response.data;
      final Map<String, dynamic> json;
      if (raw is Map<String, dynamic>) {
        if (raw.containsKey('course') && raw['course'] is Map) {
          json = raw['course'] as Map<String, dynamic>;
        } else if (raw.containsKey('data') && raw['data'] is Map) {
          json = raw['data'] as Map<String, dynamic>;
        } else {
          json = raw;
        }
      } else {
        return _cachedDetailOrMock(prefs, cacheKey, courseId);
      }

      // Persist raw json for cache.
      await prefs.setString(cacheKey, jsonEncode(json));
      await prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);

      return CourseDetailModel.fromJson(json);
    } catch (_) {
      return _cachedDetailOrMock(prefs, cacheKey, courseId);
    }
  }

  CourseDetailModel _cachedDetailOrMock(
      SharedPreferences prefs, String cacheKey, String courseId) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        return CourseDetailModel.fromJson(
            jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    return _mockCourse(courseId);
  }

  /// GET /progress/courses/:id — total/completed lessons + percentage.
  /// Returns null when the API is unreachable so the UI keeps its mock path.
  Future<CourseProgress?> getCourseProgress(String courseId) async {
    if (courseId.startsWith('mock-')) return null;
    try {
      final dio = await _client();
      final response = await dio.get('/progress/courses/$courseId');
      return CourseProgress.fromJson(
          response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// POST /progress/lessons/:id/complete — marks a lesson complete.
  /// Returns true on a 2xx response, false on any error.
  Future<bool> completeLesson(String lessonId) async {
    try {
      final dio = await _client();
      await dio.post('/progress/lessons/$lessonId/complete');
      return true;
    } catch (_) {
      return false;
    }
  }

  CourseDetailModel _mockCourse(String courseId) {
    return CourseDetailModel(
      id: courseId,
      title: 'Mathematics',
      description:
          'Learn numbers, counting, addition, subtraction, shapes, measurement, time, and money through fun lessons, pictures, activities, and quizzes.',
      thumbnailUrl: null,
      completedLessons: 6,
      totalLessons: 10,
      progressPercentage: 60,
      chapters: [
        ChapterModel(
          id: 'ch1',
          title: 'Numbers and Counting',
          topics: [
            TopicModel(
              id: 't1',
              title: 'Counting Numbers 1–10',
              lessons: [
                LessonModel(
                  id: 'l1',
                  title: 'Counting Objects',
                  type: 'video',
                  isCompleted: true,
                ),
                LessonModel(
                  id: 'l2',
                  title: 'Number Order',
                  type: 'video',
                  isCompleted: true,
                ),
                LessonModel(
                  id: 'l3',
                  title: 'Counting Practice',
                  type: 'activity',
                  isCompleted: false,
                ),
              ],
            ),
            TopicModel(
              id: 't2',
              title: 'Counting Numbers 11–20',
              lessons: [
                LessonModel(
                  id: 'l4',
                  title: 'Numbers 11 to 15',
                  type: 'video',
                  isCompleted: false,
                ),
                LessonModel(
                  id: 'l5',
                  title: 'Numbers 16 to 20',
                  type: 'video',
                  isCompleted: false,
                ),
              ],
            ),
          ],
        ),
        ChapterModel(
          id: 'ch2',
          title: 'Addition and Subtraction',
          topics: [
            TopicModel(
              id: 't3',
              title: 'Basic Addition',
              lessons: [
                LessonModel(
                  id: 'l6',
                  title: 'Adding Numbers 1–5',
                  type: 'video',
                  isCompleted: true,
                ),
                LessonModel(
                  id: 'l7',
                  title: 'Adding Numbers 6–10',
                  type: 'video',
                  isCompleted: true,
                ),
                LessonModel(
                  id: 'l8',
                  title: 'Addition Practice',
                  type: 'activity',
                  isCompleted: false,
                ),
              ],
            ),
            TopicModel(
              id: 't4',
              title: 'Basic Subtraction',
              lessons: [
                LessonModel(
                  id: 'l9',
                  title: 'Taking Away Numbers',
                  type: 'video',
                  isCompleted: false,
                ),
                LessonModel(
                  id: 'l10',
                  title: 'Subtraction Practice',
                  type: 'activity',
                  isCompleted: false,
                ),
              ],
            ),
          ],
        ),
        ChapterModel(
          id: 'ch3',
          title: 'Shapes and Patterns',
          topics: [
            TopicModel(
              id: 't5',
              title: 'Basic Shapes',
              lessons: [
                LessonModel(
                  id: 'l11',
                  title: 'Circle and Square',
                  type: 'video',
                  isCompleted: false,
                ),
                LessonModel(
                  id: 'l12',
                  title: 'Triangle and Rectangle',
                  type: 'video',
                  isCompleted: false,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
