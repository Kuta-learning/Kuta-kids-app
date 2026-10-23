class CourseModel {
  final String id;
  final String title;
  final String? description;
  final int chapterCount;
  final int completedLessons;
  final int totalLessons;
  final double progressPercentage;
  final String? thumbnailUrl;

  const CourseModel({
    required this.id,
    required this.title,
    this.description,
    required this.chapterCount,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercentage,
    this.thumbnailUrl,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      chapterCount: (json['chapterCount'] as num?)?.toInt() ?? 0,
      completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnailUrl']?.toString(),
    );
  }
}
