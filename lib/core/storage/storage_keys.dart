/// Central registry of all local storage keys used across the application.
/// Always use these constants instead of raw strings to avoid typos and collisions.
abstract class StorageKeys {
  StorageKeys._();

  // ── Authentication ────────────────────────────────────────────────────────
  /// Serialized JSON string of the authenticated [UserModel].
  static const String authUser = 'auth_user';

  /// Bearer token returned by the auth API (store in secure storage in prod).
  static const String authToken = 'auth_token';

  /// Refresh token for silent re-authentication.
  static const String authRefreshToken = 'auth_refresh_token';

  // ── Onboarding ────────────────────────────────────────────────────────────
  /// Set to `"true"` once the user completes the onboarding flow.
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // ── User Preferences ─────────────────────────────────────────────────────
  /// App locale code (e.g. "en", "am").
  static const String preferredLocale = 'preferred_locale';

  /// Theme mode: "light", "dark", or "system".
  static const String themeMode = 'theme_mode';

  // ── Student Profile ──────────────────────────────────────────────────────
  /// Numeric grade level of the authenticated student (persisted as int).
  static const String gradeLevel = 'grade_level';

  // ── API Response Cache ────────────────────────────────────────────────────
  /// Cached JSON string for the courses list (home screen).
  static const String cacheCourses = 'cache_courses';
  static const String cacheCoursesTs = 'cache_courses_ts';

  /// Cached JSON string for a specific course detail (by id).
  static String cacheCourseDetail(String id) => 'cache_course_$id';
  static String cacheCourseDetailTs(String id) => 'cache_course_${id}_ts';

  /// Cached JSON string for the student profile.
  static const String cacheProfile = 'cache_profile';
  static const String cacheProfileTs = 'cache_profile_ts';

  /// Cached JSON string for the progress list.
  static const String cacheProgress = 'cache_progress';
  static const String cacheProgressTs = 'cache_progress_ts';
}
