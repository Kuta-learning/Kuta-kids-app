import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';
import '../../kids_home/models/course_model.dart';
import '../../learning/models/chapter_model.dart';

/// A pair of a course and its aggregated progress.
class CourseProgressEntry {
  final CourseModel course;
  final CourseProgress progress;

  const CourseProgressEntry({required this.course, required this.progress});
}

class ProgressRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';
  static const int _ttlMs = 300000; // 5 minutes

  // Mock fallback — three hardcoded entries used when API is unreachable.
  static final List<CourseProgressEntry> mockEntries = [
    CourseProgressEntry(
      course: const CourseModel(
        id: 'mock-english',
        title: 'English Fun',
        description: null,
        chapterCount: 0,
        completedLessons: 13,
        totalLessons: 20,
        progressPercentage: 0.65,
      ),
      progress: const CourseProgress(
        totalLessons: 20,
        completedLessons: 13,
        progressPercentage: 65.0,
      ),
    ),
    CourseProgressEntry(
      course: const CourseModel(
        id: 'mock-math',
        title: 'Cool Math',
        description: null,
        chapterCount: 0,
        completedLessons: 8,
        totalLessons: 10,
        progressPercentage: 0.82,
      ),
      progress: const CourseProgress(
        totalLessons: 10,
        completedLessons: 8,
        progressPercentage: 82.0,
      ),
    ),
    CourseProgressEntry(
      course: const CourseModel(
        id: 'mock-science',
        title: 'Super Science',
        description: null,
        chapterCount: 0,
        completedLessons: 4,
        totalLessons: 10,
        progressPercentage: 0.40,
      ),
      progress: const CourseProgress(
        totalLessons: 10,
        completedLessons: 4,
        progressPercentage: 40.0,
      ),
    ),
  ];

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

  /// Fetches all courses for the student's grade and the progress for each.
  /// Uses stale-while-revalidate cache (5 min TTL).
  Future<List<CourseProgressEntry>> getCourseProgressList() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(StorageKeys.cacheProgress);
    final ts = prefs.getInt(StorageKeys.cacheProgressTs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cached != null && (now - ts) < _ttlMs) {
      final entries = _decodeEntries(cached);
      if (entries != null) {
        unawaited(_fetchAndCache(prefs));
        return entries;
      }
    }

    return _fetchAndCache(prefs);
  }

  Future<List<CourseProgressEntry>> _fetchAndCache(
      SharedPreferences prefs) async {
    try {
      final gradeLevel = prefs.getInt(StorageKeys.gradeLevel) ?? 1;
      final dio = await _client();

      // Step 1: fetch courses
      final coursesResp = await dio.get(
        '/courses',
        queryParameters: {'gradeLevel': gradeLevel},
      );
      final rawCourses = coursesResp.data;
      List<dynamic> courseList;
      if (rawCourses is List) {
        courseList = rawCourses;
      } else if (rawCourses is Map) {
        courseList = rawCourses['courses'] as List<dynamic>? ??
            rawCourses['data'] as List<dynamic>? ?? [];
      } else {
        courseList = [];
      }

      if (courseList.isEmpty) return _cachedOrMock(prefs);

      final courses = courseList
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Step 2: fetch progress for each course in parallel
      final entries = await Future.wait(
        courses.map((course) async {
          try {
            final progressResp =
                await dio.get('/progress/courses/${course.id}');
            final progress = CourseProgress.fromJson(
                progressResp.data as Map<String, dynamic>);
            return CourseProgressEntry(course: course, progress: progress);
          } catch (_) {
            return CourseProgressEntry(
              course: course,
              progress: CourseProgress(
                totalLessons: course.totalLessons,
                completedLessons: course.completedLessons,
                progressPercentage: course.totalLessons > 0
                    ? (course.completedLessons / course.totalLessons) * 100
                    : 0.0,
              ),
            );
          }
        }),
      );

      final result = entries.isNotEmpty ? entries : mockEntries;
      await _writeCache(prefs, result);
      return result;
    } catch (_) {
      return _cachedOrMock(prefs);
    }
  }

  Future<void> _writeCache(
      SharedPreferences prefs, List<CourseProgressEntry> entries) async {
    final list = entries
        .map((e) => {
              'courseId': e.course.id,
              'courseTitle': e.course.title,
              'courseDescription': e.course.description,
              'chapterCount': e.course.chapterCount,
              'completedLessons': e.course.completedLessons,
              'totalLessons': e.course.totalLessons,
              'progressPercentage': e.course.progressPercentage,
              'thumbnailUrl': e.course.thumbnailUrl,
              'progressTotalLessons': e.progress.totalLessons,
              'progressCompletedLessons': e.progress.completedLessons,
              'progressPercentage2': e.progress.progressPercentage,
            })
        .toList();
    await prefs.setString(StorageKeys.cacheProgress, jsonEncode(list));
    await prefs.setInt(
        StorageKeys.cacheProgressTs, DateTime.now().millisecondsSinceEpoch);
  }

  List<CourseProgressEntry>? _decodeEntries(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        final course = CourseModel(
          id: m['courseId']?.toString() ?? '',
          title: m['courseTitle']?.toString() ?? '',
          description: m['courseDescription']?.toString(),
          chapterCount: (m['chapterCount'] as num?)?.toInt() ?? 0,
          completedLessons: (m['completedLessons'] as num?)?.toInt() ?? 0,
          totalLessons: (m['totalLessons'] as num?)?.toInt() ?? 0,
          progressPercentage:
              (m['progressPercentage'] as num?)?.toDouble() ?? 0.0,
          thumbnailUrl: m['thumbnailUrl']?.toString(),
        );
        final progress = CourseProgress(
          totalLessons: (m['progressTotalLessons'] as num?)?.toInt() ?? 0,
          completedLessons:
              (m['progressCompletedLessons'] as num?)?.toInt() ?? 0,
          progressPercentage:
              (m['progressPercentage2'] as num?)?.toDouble() ?? 0.0,
        );
        return CourseProgressEntry(course: course, progress: progress);
      }).toList();
    } catch (_) {
      return null;
    }
  }

  List<CourseProgressEntry> _cachedOrMock(SharedPreferences prefs) {
    final cached = prefs.getString(StorageKeys.cacheProgress);
    if (cached != null) {
      final entries = _decodeEntries(cached);
      if (entries != null) return entries;
    }
    return mockEntries;
  }
}
