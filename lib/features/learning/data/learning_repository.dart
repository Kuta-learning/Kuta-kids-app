import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chapter_model.dart';

class LearningRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';

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
    try {
      final dio = await _client();
      final response = await dio.get('/courses/$courseId');
      final model = CourseDetailModel.fromJson(
          response.data as Map<String, dynamic>);
      // If API returns no chapters, use mock data
      if (model.chapters.isEmpty) return _mockCourse(courseId);
      return model;
    } catch (_) {
      return _mockCourse(courseId);
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
