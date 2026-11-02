// Models for the practice/quiz feature.

class PracticeOption {
  final String id;
  final String text;

  const PracticeOption({required this.id, required this.text});

  factory PracticeOption.fromJson(Map<String, dynamic> json) {
    return PracticeOption(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? json['label']?.toString() ?? '',
    );
  }
}

class PracticeQuestion {
  final String id;
  final String question;
  final List<PracticeOption> options;

  const PracticeQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] as List<dynamic>? ?? [];
    return PracticeQuestion(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: opts
          .map((e) => PracticeOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PracticeTopic {
  final String id;
  final String title;
  final String description;
  final int questionCount;

  const PracticeTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.questionCount,
  });

  factory PracticeTopic.fromJson(Map<String, dynamic> json) {
    return PracticeTopic(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      questionCount: (json['questionCount'] as num?)?.toInt() ??
          (json['questions'] is List
              ? (json['questions'] as List).length
              : 0),
    );
  }
}

class PracticeAttemptStart {
  final String attemptId;
  final List<PracticeQuestion> questions;

  const PracticeAttemptStart({
    required this.attemptId,
    required this.questions,
  });
}
