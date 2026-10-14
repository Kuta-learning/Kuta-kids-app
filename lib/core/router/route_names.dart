/// Centralized named route identifiers for the Kuta Kids Learning App.
class RouteNames {
  RouteNames._();

  // ── Entry ──────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // ── Onboarding ─────────────────────────────────
  static const String onboarding = '/onboarding';

  // ── Parent PIN Gate ────────────────────────────
  static const String parentPin = '/parent-pin';

  // ── Child Profile ──────────────────────────────
  static const String childProfiles = '/child-profiles';
  static const String createChildProfile = '/child-profiles/create';

  // ── Level Selection ────────────────────────────
  static const String levelSelection = '/level-selection';

  // ── Kids Home ──────────────────────────────────
  static const String kidsHome = '/kids';
  static const String kidsDashboard = '/kids/home';

  // ── Learning ───────────────────────────────────
  static const String categories = '/kids/learn';
  static const String lessonList = '/kids/learn/lessons';
  static const String lessonDetail = '/kids/learn/lesson';
  static const String storyLesson = '/kids/learn/story';
  static const String videoLesson = '/kids/learn/video';
  static const String audioLesson = '/kids/learn/audio';

  // ── Activities (Developer 2) ───────────────────
  static const String activities = '/kids/activities';
  static const String matchingGame = '/kids/activities/matching';
  static const String tracingActivity = '/kids/activities/tracing';

  // ── Rewards & Progress (Developer 2) ───────────
  static const String rewards = '/kids/rewards';
  static const String progress = '/kids/progress';

  // ── Parent Dashboard (Developer 2) ─────────────
  static const String parentDashboard = '/parent/dashboard';
  static const String parentSettings = '/parent/settings';
  static const String notifications = '/parent/notifications';

  // ── Legacy stubs (kept for router compatibility) ─
  static const String kgHome = '/kg-home';
  static const String gradeDashboard = '/grade-dashboard';
  static const String subjectDetail = '/subject-detail';
  static const String quiz = '/quiz';
  static const String profile = '/profile';
}
