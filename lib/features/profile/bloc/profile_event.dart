abstract class ProfileEvent {
  const ProfileEvent();
}

/// Request the student's profile from the API.
class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

/// Request a profile update (name and/or avatar).
class ProfileUpdateRequested extends ProfileEvent {
  final String? name;
  final String? avatarUrl;

  const ProfileUpdateRequested({this.name, this.avatarUrl});
}
