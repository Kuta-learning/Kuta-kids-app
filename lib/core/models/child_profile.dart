import 'kids_level.dart';

/// Represents a child's profile stored locally and/or on the backend.
class ChildProfile {
  final String id;
  final String name;
  final KidsLevel level;
  final String avatarId; // references an asset avatar image key
  final int? ageYears;
  final DateTime createdAt;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.level,
    required this.avatarId,
    this.ageYears,
    required this.createdAt,
  });

  ChildProfile copyWith({
    String? id,
    String? name,
    KidsLevel? level,
    String? avatarId,
    int? ageYears,
    DateTime? createdAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      avatarId: avatarId ?? this.avatarId,
      ageYears: ageYears ?? this.ageYears,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level.toStorageString(),
        'avatarId': avatarId,
        'ageYears': ageYears,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        level: KidsLevel.fromString(json['level'] as String),
        avatarId: json['avatarId'] as String,
        ageYears: json['ageYears'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
