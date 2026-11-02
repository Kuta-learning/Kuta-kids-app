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
  ///
  /// Strategy:
  /// 1. Read the persisted grade level (default 1).
  /// 2. GET /courses?gradeLevel=N to obtain the course list.
  /// 3. For each course GET /progress/courses/:id.
  /// 4. Return the combined list. Falls back to [_mockEntries] on any error.
  Future<List<CourseProgressEntry>> getCourseProgressList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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

      if (courseList.isEmpty) return mockEntries;

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
            // Fallback progress derived from the course model itself.
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

      return entries.isNotEmpty ? entries : mockEntries;
    } catch (_) {
      return mockEntries;
    }
  }
}
