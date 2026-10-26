class LessonModel {
  final String id;
  final String title;
  final String? type;
  final String? videoUrl;
  final String? noteUrl;
  final String? thumbnailUrl;
  final int? duration;
  final bool isCompleted;

  const LessonModel({
    required this.id,
    required this.title,
    this.type,
    this.videoUrl,
    this.noteUrl,
    this.thumbnailUrl,
    this.duration,
    this.isCompleted = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      noteUrl: json['noteUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      duration: (json['duration'] as num?)?.toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class TopicModel {
  final String id;
  final String title;
  final List<LessonModel> lessons;

  const TopicModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    final lessonList = json['lessons'] as List<dynamic>? ?? [];
    return TopicModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      lessons: lessonList
          .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChapterModel {
  final String id;
  final String title;
  final List<TopicModel> topics;

  const ChapterModel({
    required this.id,
    required this.title,
    required this.topics,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final topicList = json['topics'] as List<dynamic>? ?? [];
    return ChapterModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      topics: topicList
          .map((t) => TopicModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CourseDetailModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final List<ChapterModel> chapters;
  final int completedLessons;
  final int totalLessons;
  final double progressPercentage;

  const CourseDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.chapters,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercentage,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    final chapterList = json['chapters'] as List<dynamic>? ?? [];
    return CourseDetailModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      chapters: chapterList
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
