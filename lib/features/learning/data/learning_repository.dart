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
    final dio = await _client();
    final response = await dio.get('/courses/$courseId');
    return CourseDetailModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
