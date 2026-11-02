/// Profile data returned by GET /auth/me, used by the Profile screen.
class ProfileModel {
  final String name;
  final String email;
  final int gradeLevel;
  final String? avatarUrl;
  final int? stars;
  final List<String>? badges;

  const ProfileModel({
    required this.name,
    required this.email,
    required this.gradeLevel,
    this.avatarUrl,
    this.stars,
    this.badges,
  });

  /// Parses the /auth/me response, which may wrap the student under a
  /// `student` key or return the user data at the top level.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Defensively unwrap a possible `student` wrapper.
    final Map<String, dynamic> data =
        json['student'] is Map<String, dynamic>
            ? json['student'] as Map<String, dynamic>
            : json;

    final rawBadges = data['badges'];
    List<String>? badges;
    if (rawBadges is List) {
      badges = rawBadges.map((e) => e.toString()).toList();
    }

    return ProfileModel(
      name: data['name']?.toString() ??
          data['fullName']?.toString() ??
          data['username']?.toString() ??
          'Student',
      email: data['email']?.toString() ?? '',
      gradeLevel: (data['gradeLevel'] as num?)?.toInt() ?? 1,
      avatarUrl: data['avatarUrl']?.toString(),
      stars: (data['stars'] as num?)?.toInt(),
      badges: badges,
    );
  }
}
