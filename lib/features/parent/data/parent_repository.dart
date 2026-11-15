import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';

/// A single selectable option for a parent-gate math question.
class ParentGateOption {
  const ParentGateOption({required this.id, required this.text});

  final String id;
  final String text;

  factory ParentGateOption.fromJson(Map<String, dynamic> json) {
    return ParentGateOption(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? json['label']?.toString() ?? '',
    );
  }
}

/// A random math question used to verify that an adult is present.
class ParentGateQuestion {
  const ParentGateQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  final String id;
  final String question;
  final List<ParentGateOption> options;

  factory ParentGateQuestion.fromJson(Map<String, dynamic> json) {
    final opts = json['options'];
    return ParentGateQuestion(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      // API returns field as 'text' — also handle 'question' for future-proofing
      question: json['text']?.toString() ?? json['question']?.toString() ?? '',
      options: opts is List
          ? opts
              .map((e) => ParentGateOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}

/// Fetches and verifies the parent-gate math question.
///
/// Mirrors the repository pattern in [HomeRepository]: a private `_client()`
/// helper that reads the bearer token from SharedPreferences, and public
/// methods that fall back to mock data on any error so the gate never breaks.
class ParentRepository {
  static const String _baseUrl = 'https://kuta-learning.onrender.com/api';

  // Mock fallback shown while the API is unavailable — mirrors a real question.
  static final ParentGateQuestion _mockQuestion = ParentGateQuestion(
    id: 'mock-7-plus-8',
    question: '7 + 8 = ?',
    options: const [
      ParentGateOption(id: '12', text: '12'),
      ParentGateOption(id: '15', text: '15'),
      ParentGateOption(id: '18', text: '18'),
    ],
  );

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

  /// Fetches a random math question for parent verification.
  ///
  /// Falls back to a hardcoded question on any error so the gate never shows
  /// a blank question.
  Future<ParentGateQuestion> getRandomQuestion() async {
    try {
      final dio = await _client();
      final response = await dio.get('/practice/random-question');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final question = ParentGateQuestion.fromJson(data);
        // Only trust a parsed question that actually has options to choose.
        if (question.options.isNotEmpty) {
          return question;
        }
      }

      return _mockQuestion;
    } catch (_) {
      // API unreachable — use the hardcoded question.
      return _mockQuestion;
    }
  }

  /// Verifies the parent's selected answer for [questionId].
  ///
  /// Returns `true` only when the API confirms the answer is correct. On any
  /// error the gate stays locked (returns `false`), so an offline or failed
  /// request never unlocks parent settings.
  Future<bool> verifyAnswer({
    required String questionId,
    required String selectedOptionId,
  }) async {
    try {
      final dio = await _client();
      final response = await dio.post(
        '/practice/random-question/verify',
        data: {
          'questionId': questionId,
          'selectedOptionId': selectedOptionId,
        },
      );
      final data = response.data;
      if (data is Map) {
        // API returns { isCorrect: bool }
        return data['isCorrect'] == true || data['correct'] == true;
      }
      return false;
    } catch (_) {
      // API unreachable — treat as incorrect so the gate stays locked.
      return false;
    }
  }
}
