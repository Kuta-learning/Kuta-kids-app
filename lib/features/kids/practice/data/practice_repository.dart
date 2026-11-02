import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/storage_keys.dart';
import 'models.dart';

class PracticeRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';

  // Mock fallback topics that mirror the original hardcoded challenges.
  static final List<PracticeTopic> _mockTopics = const [
    PracticeTopic(
      id: 'mock-speed-math',
      title: 'Speed Math',
      description: 'Beat the clock and solve as many sums as you can!',
      questionCount: 5,
    ),
    PracticeTopic(
      id: 'mock-word-puzzles',
      title: 'Word Puzzles',
      description: 'Connect the letters and find all the hidden words.',
      questionCount: 5,
    ),
    PracticeTopic(
      id: 'mock-science-quiz',
      title: 'Science Quiz',
      description: 'Explore the world of space, plants, and animals!',
      questionCount: 5,
    ),
    PracticeTopic(
      id: 'mock-picture-match',
      title: 'Picture Match',
      description: 'Test your memory and match the pairs of pictures.',
      questionCount: 5,
    ),
    PracticeTopic(
      id: 'mock-creative-arts',
      title: 'Creative Arts',
      description: 'Follow the dots or color by numbers for fun!',
      questionCount: 5,
    ),
    PracticeTopic(
      id: 'mock-music-beats',
      title: 'Music Beats',
      description: 'Listen to the melody and repeat the sequence correctly.',
      questionCount: 5,
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

  /// GET /practice/topics — returns all available practice topics.
  /// Falls back to [_mockTopics] on any error.
  Future<List<PracticeTopic>> getTopics() async {
    try {
      final dio = await _client();
      final response = await dio.get('/practice/topics');
      final data = response.data;

      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map) {
        list = data['topics'] as List<dynamic>? ??
            data['data'] as List<dynamic>? ?? [];
      } else {
        list = [];
      }

      final topics = list
          .map((e) => PracticeTopic.fromJson(e as Map<String, dynamic>))
          .toList();
      return topics.isNotEmpty ? topics : _mockTopics;
    } catch (_) {
      return _mockTopics;
    }
  }

  /// POST /practice/topics/:topicId/start — starts a quiz attempt.
  /// Returns a [PracticeAttemptStart] with the attempt id and questions.
  Future<PracticeAttemptStart> startTopic(String topicId) async {
    try {
      final dio = await _client();
      final response =
          await dio.post('/practice/topics/$topicId/start');
      final data = response.data as Map<String, dynamic>? ?? {};

      final attemptId = data['attemptId']?.toString() ??
          data['_id']?.toString() ??
          data['id']?.toString() ??
          'mock-attempt';

      final rawQuestions = data['questions'] as List<dynamic>? ?? [];
      final questions = rawQuestions
          .map((e) =>
              PracticeQuestion.fromJson(e as Map<String, dynamic>))
          .toList();

      return PracticeAttemptStart(
        attemptId: attemptId,
        questions: questions,
      );
    } catch (_) {
      // Return a minimal mock session so the user can still play.
      return PracticeAttemptStart(
        attemptId: 'mock-attempt-$topicId',
        questions: const [
          PracticeQuestion(
            id: 'mock-q1',
            question: 'What is 2 + 2?',
            options: [
              PracticeOption(id: 'a', text: '3'),
              PracticeOption(id: 'b', text: '4'),
              PracticeOption(id: 'c', text: '5'),
            ],
          ),
          PracticeQuestion(
            id: 'mock-q2',
            question: 'Which animal says "Moo"?',
            options: [
              PracticeOption(id: 'a', text: 'Dog'),
              PracticeOption(id: 'b', text: 'Cat'),
              PracticeOption(id: 'c', text: 'Cow'),
            ],
          ),
        ],
      );
    }
  }

  /// POST /practice/attempts/:attemptId/submit — submits the quiz answers.
  /// [answers] is a list of maps with `questionId` and `selectedOptionId`.
  /// Returns `true` on a 2xx response, `false` on error.
  Future<bool> submitAttempt(
    String attemptId,
    List<Map<String, String>> answers,
  ) async {
    try {
      final dio = await _client();
      await dio.post(
        '/practice/attempts/$attemptId/submit',
        data: {
          'answers': answers,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
