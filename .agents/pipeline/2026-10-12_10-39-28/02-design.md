# Technical Design: Kuta Kids Learning Module — Flutter Application

## Overview

The Kuta Kids Learning Module is a Flutter mobile application (Android API 24+, iOS 14+) built with BLoC state management, go_router navigation, Dio networking, and get_it dependency injection. The codebase starts from a minimal scaffold: only `lib/main.dart` (the default counter app), `lib/core/errors/exceptions.dart` (six exception types), `lib/core/constants/api_endpoints.dart`, and `lib/core/constants/app_constants.dart` contain any code. All feature directories exist but are empty. `pubspec.yaml` already declares every required dependency plus `dartz ^0.10.1` (used for `Either<Failure, T>` returns in repository contracts), `bloc_test ^9.1.7`, and `mocktail ^1.0.4` for testing.

The architecture follows Clean Architecture in three layers per feature: **data** (remote data sources, models/DTOs, repository implementations), **domain** (entities, repository interfaces, use-cases), and **presentation** (BLoC, pages, widgets). The `core` layer provides cross-cutting infrastructure shared by all features. All repository methods return `Either<AppFailure, T>` from dartz; callers treat `Left` as failure and `Right` as success. BLoCs emit typed states extending `Equatable`. Navigation is declared in `lib/app/app_router.dart` using go_router shell routes.

Technology stack (locked): Flutter 3.x / Dart 3.x, `flutter_bloc ^8.1.6`, `equatable ^2.0.5`, `go_router ^14.2.7`, `dio ^5.7.0`, `dartz ^0.10.1`, `shared_preferences ^2.3.2`, `cached_network_image ^3.4.1`, `video_player ^2.9.2`, `chewie ^1.8.5`, `flutter_pdfview ^1.3.2`, `just_audio ^0.9.40`, `lottie ^3.1.2`, `flutter_animate ^4.5.0`, `intl ^0.19.0`, `get_it ^8.0.2`, `bloc_test ^9.1.7`, `mocktail ^1.0.4`.

---

## 1. Entry Point & Dependency Injection

**`lib/main.dart`** is replaced entirely. It calls `WidgetsFlutterBinding.ensureInitialized()`, then `await ServiceLocator.init()` (a top-level async function in `lib/core/di/service_locator.dart`), then `runApp(const KutaKidsApp())`.

**`lib/core/di/service_locator.dart`** registers all dependencies with `GetIt.instance` (aliased as `sl`). Registration order: infrastructure singletons first (Dio client, `LocalStorage`), then data sources, then repositories, then use-cases, then BLoCs. BLoCs are registered as **factories** (new instance per resolution) because each screen owns its own BLoC lifetime. Repositories and data sources are registered as **lazy singletons**.

Registration groups:
1. `LocalStorageImpl` as `LocalStorage` (lazy singleton)
2. `DioFactory` builds a `Dio` instance with `AuthInterceptor`, `TokenRefreshInterceptor`, and `ErrorInterceptor` attached — registered as lazy singleton
3. Each remote data source registered against its abstract interface
4. Each repository implementation registered against its abstract interface
5. Use-cases registered as lazy singletons (they are stateless)
6. BLoCs registered as factories: `AuthBloc`, `GradeRoutingBloc`, `KidsDashboardBloc`, `SubjectsBloc`, `ContentExplorerBloc`, `LessonBloc`, `PracticeBloc`, `QuizBloc`, `MockExamBloc`, `ProgressBloc`, `SearchBloc`, `NotificationBloc`, `SubscriptionBloc`, `ParentLinkBloc`

**`lib/app/app.dart`** defines `KutaKidsApp extends StatelessWidget`. It wraps the app in `MultiBlocProvider` providing `AuthBloc` and `GradeRoutingBloc` (the two BLoCs that outlive any single screen), then returns `MaterialApp.router` with the kids `ThemeData` from `KidsTheme.themeData` and the `GoRouter` instance from `AppRouter.router`.

---

## 2. Core Infrastructure

### 2.1 Theme — `lib/core/theme/`

**`kids_theme.dart`** exposes `KidsTheme.themeData` returning a `ThemeData`. Key values:

| Token | Value |
|---|---|
| Primary | `Color(0xFF4CAF50)` (bright green) |
| Secondary | `Color(0xFFFF9800)` (orange) |
| Tertiary | `Color(0xFF2196F3)` (blue) |
| Error | `Color(0xFFF44336)` |
| Background | `Color(0xFFFFFDE7)` (warm cream) |
| `fontFamily` | `'Nunito'` (falls back to system sans-serif) |
| Button min size | `Size(88, 52)` |
| Border radius | `BorderRadius.circular(16)` |

`TextTheme` sets `displayLarge` through `bodySmall` with the Nunito family and slightly increased letter-spacing for readability. `ElevatedButtonThemeData` enforces `minimumSize: Size(88, 52)` and `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))`. `CardThemeData` sets `elevation: 2` and `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))`.

**`kids_colors.dart`** is a pure `abstract final class` (no instances) exposing all named colour constants referenced in widgets.

### 2.2 Errors — `lib/core/errors/`

`exceptions.dart` already exists with six exception types. Add **`failures.dart`**:

```dart
abstract class AppFailure extends Equatable {
  final String message;
  const AppFailure(this.message);
  @override List<Object> get props => [message];
}
class NetworkFailure extends AppFailure { const NetworkFailure(super.message); }
class AuthFailure extends AppFailure { const AuthFailure(super.message); }
class NotFoundFailure extends AppFailure { const NotFoundFailure(super.message); }
class ServerFailure extends AppFailure { const ServerFailure(super.message); }
class CacheFailure extends AppFailure { const CacheFailure(super.message); }
class PermissionFailure extends AppFailure { const PermissionFailure(super.message); }
```

### 2.3 Network — `lib/core/network/`

**`dio_factory.dart`** — static `create(LocalStorage storage)` method returns a configured `Dio` with `BaseOptions(baseUrl: ApiEndpoints.baseUrl, connectTimeout: Duration(seconds: 15), receiveTimeout: Duration(seconds: 30))`. Interceptors are added in order: `AuthInterceptor`, `TokenRefreshInterceptor`, `ErrorInterceptor`.

**`auth_interceptor.dart`** — `onRequest` reads the access token from `LocalStorage` and sets `Authorization: Bearer <token>`. Requests to `ApiEndpoints.login` and `ApiEndpoints.refreshToken` skip token injection (checked by path match).

**`token_refresh_interceptor.dart`** — `onError`: if `DioException.response?.statusCode == 401` and the failing request is not already a refresh attempt, POST to `ApiEndpoints.refreshToken` with the stored refresh token. On success: persist new tokens via `LocalStorage`, retry the original request. On failure (4xx from refresh endpoint, or no refresh token stored): clear both tokens, fire `AuthBloc.add(AuthLoggedOut())`, return a `DioException` wrapping `AuthException`. This is fatal — the interceptor does not retry again. The `AuthBloc` reference is passed to the interceptor constructor (registered in `ServiceLocator` after `AuthBloc` factory is registered — the interceptor receives `GetIt<AuthBloc>` as a provider function, not a direct instance, to avoid circular dependency at construction time).

**`error_interceptor.dart`** — `onError` maps HTTP status codes to typed exceptions:
- 400 → `ServerException` with response body message
- 401 → `AuthException`
- 403 → `PermissionException`
- 404 → `NotFoundException`
- 5xx → `ServerException`
- `DioExceptionType.connectionTimeout` / `sendTimeout` / `receiveTimeout` / `connectionError` → `NetworkException`

**`api_client.dart`** — thin wrapper exposing `get`, `post`, `put`, `delete`, `patch` that delegate to `_dio` methods. Callers (data sources) use this wrapper to avoid importing Dio directly outside `core/network`.

Error mapping from exception to failure happens in **repository implementations**, not in data sources. Data sources throw exceptions; repositories catch them and return `Left<AppFailure>`.

### 2.4 Storage — `lib/core/storage/`

**`local_storage.dart`** defines the abstract interface:

```dart
abstract class LocalStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
}
```

**`local_storage_impl.dart`** implements this using `SharedPreferences`. Keys come from `AppConstants` (`tokenKey`, `refreshTokenKey`). `clearTokens` removes both token keys with `Future.wait`.

### 2.5 Shared Widgets — `lib/core/widgets/`

All widgets here take no BLoC dependency.

- **`loading_indicator.dart`** — `LoadingIndicator({double size = 48})`. Uses a Lottie animation if `assets/animations/loading.json` exists, otherwise falls back to `CircularProgressIndicator` with primary colour.
- **`error_view.dart`** — `ErrorView({required String message, required VoidCallback onRetry})`. Shows a sad-face illustration (or `Icon(Icons.cloud_off)`), the message, and a `KidButton` labelled "Try Again". Minimum button touch target 48 × 48 dp.
- **`empty_view.dart`** — `EmptyView({required String message, String? illustrationAsset})`. Shows an optional Lottie illustration and the message.
- **`kid_button.dart`** — `KidButton({required String label, required VoidCallback? onPressed, KidButtonVariant variant = KidButtonVariant.primary, Widget? icon})`. Wraps `ElevatedButton` / `OutlinedButton` using the kids theme. Enforces `SizedBox(height: 52)` via the theme's `minimumSize`.
- **`kid_card.dart`** — `KidCard({required Widget child, EdgeInsets? padding, Color? color, VoidCallback? onTap})`. Wraps `Card` with `InkWell`; enforces border radius 16.
- **`app_scaffold.dart`** — `AppScaffold({required Widget body, String? title, List<Widget>? actions, bool showBackButton = true})`. Wraps `Scaffold` with an `AppBar` using the kids theme's primary colour and consistent title text style.

### 2.6 Constants — `lib/core/constants/`

`api_endpoints.dart` and `app_constants.dart` already exist and are complete. Add:

**`route_constants.dart`** — named route constants used by both the router and deep-link handlers:

```dart
class RouteConstants {
  RouteConstants._();
  static const String splash = '/';
  static const String login = '/login';
  static const String kidsShell = '/kids';
  static const String kidsDashboard = '/kids/home';
  static const String kidsLearn = '/kids/learn';
  static const String kidsLearnSubject = '/kids/learn/subject/:subjectId';
  static const String kidsLearnChapter = '/kids/learn/chapter/:chapterId';
  static const String kidsLearnTopic = '/kids/learn/topic/:topicId';
  static const String kidsLearnLesson = '/kids/learn/lesson/:lessonId';
  static const String kidsPractice = '/kids/practice';
  static const String kidsPracticeSession = '/kids/practice/session/:topicId';
  static const String kidsQuiz = '/kids/practice/quiz/:quizId';
  static const String kidsExam = '/kids/practice/exam/:examId';
  static const String kidsProgress = '/kids/progress';
  static const String kidsProfile = '/kids/profile';
  static const String kidsNotifications = '/kids/profile/notifications';
  static const String middle = '/middle';
  static const String highSchool = '/highschool';
}
```

**`asset_constants.dart`** — paths into `assets/`:

```dart
abstract final class AssetConstants {
  static const String correctAnimation = 'assets/animations/correct.json';
  static const String wrongAnimation = 'assets/animations/wrong.json';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String emptyAnimation = 'assets/animations/empty.json';
  static const String celebrationAnimation = 'assets/animations/celebration.json';
  static const String logoImage = 'assets/images/logo.png';
}
```

---

## 3. Domain Entities — `lib/features/*/domain/entities/`

All entities are **immutable** Dart classes extending `Equatable`. Every field is `final`. `props` includes all fields. No entity has mutable setters; `copyWith` is provided on entities that need in-BLoC updates.

### Student
```
String id, String username, String displayName, String? avatarUrl,
int grade, String email, DateTime createdAt,
bool isActive, String subscriptionStatus
```

### Grade
```
int level, String name, String description
```

### Subject
```
String id, String name, String iconUrl, String colorHex,
int gradeLevel, int chapterCount, double completionPercentage, bool isLocked
```

### Chapter
```
String id, String subjectId, String title, int order,
int topicCount, double completionPercentage, bool isLocked
```

### Topic
```
String id, String chapterId, String title, int order,
int lessonCount, double completionPercentage, bool isLocked,
String? thumbnailUrl
```

### Lesson
```
String id, String topicId, String title, LessonType type,
String contentUrl, int durationSeconds, int? lastPositionSeconds,
int? lastPage, bool isCompleted, String? thumbnailUrl
```
`LessonType` is an enum: `video`, `pdf`, `audio`.

### Question
```
String id, String text, String? imageUrl,
List<String> options, int correctOptionIndex, String? explanation
```

### QuestionResult (value object, not a top-level entity)
```
String questionId, int selectedOptionIndex, bool isCorrect
```

### PracticeAttempt
```
String id, String topicId, String studentId, int score,
int totalQuestions, int correctAnswers,
List<QuestionResult> questionResults, DateTime attemptedAt
```

### Quiz
```
String id, String title, String? chapterId, String? topicId,
int? timeLimitSeconds, int questionCount, QuizType quizType,
List<Question> questions
```
`QuizType` enum: `quiz`, `mockExam`.

### QuizAttempt
```
String id, String quizId, String studentId, int score,
int totalQuestions, double percentageScore, int? timeTakenSeconds,
List<QuestionResult> questionResults, DateTime submittedAt
```

### SubjectProgress (value object)
```
String subjectId, String subjectName, double completionPercentage,
int lessonsCompleted, int totalLessons
```

### WeeklyActivity (value object)
```
DateTime date, int minutesSpent
```

### ProgressRecord
```
String studentId, List<SubjectProgress> subjectProgress,
int streakDays, int totalLessonsCompleted,
double overallCompletion, List<WeeklyActivity> weeklyActivity
```

### Achievement
```
String id, String title, String description, String badgeUrl,
bool isUnlocked, DateTime? unlockedAt
```

### Notification
```
String id, String title, String body, NotificationType type,
bool isRead, DateTime createdAt,
String? deepLinkRoute, Map<String, String>? deepLinkParams
```
`NotificationType` enum: `lesson`, `achievement`, `quiz`, `general`.

### SubscriptionEntitlement
```
String studentId, SubscriptionPlan plan, DateTime? expiresAt,
bool isActive, List<String> unlockedSubjectIds
```
`SubscriptionPlan` enum: `free`, `basic`, `premium`.

### DashboardData (domain value object, lives in dashboard domain)
```
Student student, List<Subject> subjects,
Lesson? continueLesson, int streakDays,
List<Achievement> recentAchievements
```

---

## 4. Authentication Feature — `lib/features/authentication/`

### Data Layer

**`data/datasources/auth_remote_data_source.dart`** defines `AuthRemoteDataSource` (abstract) and `AuthRemoteDataSourceImpl`:

```dart
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<void> logout(String token);
}
```

`AuthRemoteDataSourceImpl` uses `ApiClient`. `login` POSTs `{"username": username, "password": password}` to `ApiEndpoints.login`. Returns the raw decoded JSON map. Exceptions are thrown as-is (already typed by `ErrorInterceptor`).

**`data/models/student_model.dart`** — `StudentModel extends Student`. Adds `factory StudentModel.fromJson(Map<String, dynamic> json)` and `Map<String, dynamic> toJson()`. Field access uses typed extraction: `json['grade'] as int`, `json['id'] as String`, with `?? ''` fallbacks on nullable strings.

**`data/repositories/auth_repository_impl.dart`** — `AuthRepositoryImpl implements AuthRepository`. `login` calls data source, constructs `StudentModel.fromJson`, persists tokens to `LocalStorage`, returns `Right(student)`. Exception-to-failure mapping:
- `AuthException` → `Left(AuthFailure(e.message))`
- `NetworkException` → `Left(NetworkFailure(e.message))`
- `NotFoundException` → `Left(NotFoundFailure(e.message))`
- all other `Exception` → `Left(ServerFailure(e.toString()))`

### Domain Layer

**`domain/repositories/auth_repository.dart`**:

```dart
abstract class AuthRepository {
  Future<Either<AppFailure, Student>> login(String username, String password);
  Future<Either<AppFailure, void>> logout();
  Future<Either<AppFailure, Student?>> getStoredStudent();
}
```

`getStoredStudent` reads the JSON-encoded student from `LocalStorage` (key `AppConstants.userProfileKey`). Returns `Right(null)` if no stored profile exists — this is not an error.

**`domain/usecases/login_usecase.dart`** — `LoginUseCase(AuthRepository)`. Takes `LoginParams(String username, String password)`, returns `Future<Either<AppFailure, Student>>`.

**`domain/usecases/logout_usecase.dart`** — calls `repository.logout()`. Clears local storage via the repository, which delegates to `LocalStorage.clearTokens()`.

**`domain/usecases/get_stored_student_usecase.dart`** — calls `repository.getStoredStudent()`.

### Presentation Layer

**`presentation/bloc/auth_bloc.dart`** — `AuthBloc(LoginUseCase, LogoutUseCase, GetStoredStudentUseCase)`.

Events: `AuthStarted`, `AuthLoginRequested(String username, String password)`, `AuthLoggedOut`.

States: `AuthInitial`, `AuthLoading`, `AuthAuthenticated(Student student)`, `AuthUnauthenticated`, `AuthError(String message)`.

- `AuthStarted` → call `GetStoredStudentUseCase`. `Right(Student?)`: if non-null emit `AuthAuthenticated`; if null emit `AuthUnauthenticated`. `Left(failure)` → emit `AuthUnauthenticated` (treat expired/missing token as unauthenticated, not an error the user sees).
- `AuthLoginRequested` → emit `AuthLoading` → call `LoginUseCase` → `Right` emits `AuthAuthenticated(student)`, `Left` emits `AuthError(failure.message)`.
- `AuthLoggedOut` → call `LogoutUseCase` (best-effort) → emit `AuthUnauthenticated` regardless.

**`presentation/pages/splash_page.dart`** — dispatches `AuthStarted` on build. Shows a centred logo with a `Lottie` loading animation. `BlocListener` transitions once state leaves `AuthInitial` / `AuthLoading`.

**`presentation/pages/login_page.dart`** — `BlocConsumer<AuthBloc, AuthState>`. Listener: `AuthAuthenticated` → `context.read<GradeRoutingBloc>().add(DetermineGradeRoute(state.student))`; `AuthError` → `ScaffoldMessenger.of(context).showSnackBar(...)`. Builder: form with two `TextFormField`s and a `KidButton`. Button shows `CircularProgressIndicator` when state is `AuthLoading` (disabled). Validation: username non-empty, password ≥ 6 chars, enforced on submit via `_formKey.currentState!.validate()`.

**`presentation/widgets/login_form.dart`** — extracted `StatefulWidget` holding the `GlobalKey<FormState>`, controllers, and the form layout. Accepts `onSubmit(String username, String password)` callback.

---

## 5. Grade Routing — `lib/features/grade_routing/`

`GradeRoutingBloc` reads `Student.grade` (already in memory from `AuthBloc`) and emits a destination. No API call is needed.

**`domain/usecases/determine_grade_route_usecase.dart`**:

```dart
enum GradeDestination { kids, middle, highSchool }

class DetermineGradeRouteUseCase {
  GradeDestination call(int grade) {
    if (grade <= AppConstants.kidsMaxGrade) return GradeDestination.kids;
    if (grade <= AppConstants.middleMaxGrade) return GradeDestination.middle;
    return GradeDestination.highSchool;
  }
}
```

This is a **synchronous** use-case (no `Either`, no async) — routing is a pure computation.

**`presentation/bloc/grade_routing_bloc.dart`**:

Events: `DetermineGradeRoute(Student student)`.
States: `GradeRoutingInitial`, `GradeRouteKids(Student student)`, `GradeRouteMiddle(Student student)`, `GradeRouteHighSchool(Student student)`.

The handler calls `DetermineGradeRouteUseCase` and emits the matching state.

**Navigation wiring**: the `App` widget has a `BlocListener<GradeRoutingBloc, GradeRoutingState>` that calls `context.go(RouteConstants.kidsDashboard)` for `GradeRouteKids`, and the placeholder routes for others. This listener lives in `KutaKidsApp` alongside the router.

Placeholder screens (`middle_placeholder_page.dart`, `high_school_placeholder_page.dart`) show a centred `Column` with a large emoji and `Text("Coming Soon 🚀")`.

---

## 6. Navigation — `lib/app/app_router.dart`

The router uses `GoRouter` with `refreshListenable: GoRouterRefreshStream(authBloc.stream)`. `GoRouterRefreshStream` is a small `ChangeNotifier` that listens to a `Stream` — implemented inline in `app_router.dart`:

```dart
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override void dispose() { _sub.cancel(); super.dispose(); }
}
```

`AppRouter.router` is a static `GoRouter` created once, receiving `AuthBloc` via constructor.

### Route tree

```
/ (splash — GoRoute, initial location)
/login  (GoRoute — LoginPage)
/kids   (StatefulShellRoute.indexedStack — KidsShellPage)
  branch 0: /kids/home     (DashboardPage)
  branch 1: /kids/learn    (ContentExplorerPage — SubjectsBloc + ContentExplorerBloc + SearchBloc)
    /kids/learn/subject/:subjectId  (SubjectChaptersPage)
    /kids/learn/chapter/:chapterId  (ChapterTopicsPage)
    /kids/learn/topic/:topicId      (TopicLessonsPage)
    /kids/learn/lesson/:lessonId    (LessonViewerPage — LessonBloc)
  branch 2: /kids/practice (PracticeTabPage — lists practice sessions + mock exams)
    /kids/practice/session/:topicId (PracticeSessionPage — PracticeBloc)
    /kids/practice/quiz/:quizId     (QuizPage — QuizBloc)
    /kids/practice/exam/:examId     (MockExamPage — MockExamBloc)
  branch 3: /kids/progress (ProgressPage — ProgressBloc)
  branch 4: /kids/profile  (ProfilePage — SubscriptionBloc + ParentLinkBloc)
    /kids/profile/notifications (NotificationsPage — NotificationBloc)
/middle      (MiddlePlaceholderPage)
/highschool  (HighSchoolPlaceholderPage)
```

**`route_guard.dart`** — `redirect` callback logic (pure function, no side-effects):

1. If `authState is AuthInitial || authState is AuthLoading` → return `RouteConstants.splash` (wait for auth check).
2. If `authState is AuthUnauthenticated` and `location != RouteConstants.login` and `location != RouteConstants.splash` → return `RouteConstants.login`.
3. If `authState is AuthAuthenticated` and (`location == RouteConstants.login` or `location == RouteConstants.splash`) → return the appropriate shell root based on `DetermineGradeRouteUseCase(student.grade)`.
4. Otherwise → return `null` (allow).

**Kids shell — `KidsShellPage`**: `StatefulWidget` receiving `StatefulNavigationShell`. `BottomNavigationBar` with five `BottomNavigationBarItem`s. The `onTap` calls `navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex)`. Active colour: `KidsColors.primary`. Each item icon uses `Semantics(label: ...)` for accessibility.

Each branch's page is wrapped in a `BlocProvider(create: (_) => sl<XBloc>()..add(InitialLoadEvent()))` in the route `builder`. BLoC instances are created fresh when the route is first built and disposed when the route is popped from the navigator stack.

---

## 7. Dashboard — `lib/features/kids/dashboard/`

### Data Layer

**`data/datasources/dashboard_remote_data_source.dart`**:

```dart
abstract class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> fetchDashboard();
}
```

`DashboardRemoteDataSourceImpl` GETs `ApiEndpoints.dashboard`. Returns raw JSON map.

**`data/models/`** — `DashboardModel` is a factory that delegates `fromJson` to `SubjectModel.fromJson`, `LessonModel.fromJson`, `AchievementModel.fromJson` etc. It produces a `DashboardData` domain object (not a model subclass, since `DashboardData` is a value object not needing `toJson`).

**`data/repositories/dashboard_repository_impl.dart`** — maps exceptions to failures. Returns `Either<AppFailure, DashboardData>`.

### Domain Layer

```dart
abstract class DashboardRepository {
  Future<Either<AppFailure, DashboardData>> fetchDashboard();
}
```

`FetchDashboardUseCase(DashboardRepository)` — no params, returns `Future<Either<AppFailure, DashboardData>>`.

### BLoC — `KidsDashboardBloc`

Events: `DashboardLoadRequested`.
States: `DashboardInitial`, `DashboardLoading`, `DashboardSuccess(DashboardData data)`, `DashboardFailure(String message)`.

Handler: emit `DashboardLoading` → call use-case → `Right` emits `DashboardSuccess`, `Left` emits `DashboardFailure(failure.message)`.

### UI — `presentation/pages/dashboard_page.dart`

`BlocProvider` wrapping the page creates `KidsDashboardBloc` and dispatches `DashboardLoadRequested` immediately. `BlocBuilder` renders:

- `DashboardLoading` → skeleton shimmer (three `flutter_animate`-driven `Container` placeholders with `shimmer` effect via `animate().shimmer()`).
- `DashboardFailure` → `ErrorView(message: state.message, onRetry: () => bloc.add(DashboardLoadRequested()))`.
- `DashboardSuccess` → `CustomScrollView` with:
  1. `SliverAppBar` — greeting text `"Hello, ${data.student.displayName}! 👋"` + avatar.
  2. `SliverToBoxAdapter` — `ContinueLearningCard` (shows lesson thumbnail, title, progress bar); if `data.continueLesson == null`, this card is omitted.
  3. `SliverToBoxAdapter` — `DailyStreakBanner` showing `"🔥 ${data.streakDays} day streak"`.
  4. `SliverPadding` + `SliverGrid` — subjects grid, `crossAxisCount: 2`, each cell a `SubjectCard`.
  5. `SliverToBoxAdapter` — `RecentAchievementsRow` horizontal `ListView`.

`SubjectCard` → `context.push('/kids/learn/subject/${subject.id}')` on tap.
`ContinueLearningCard` → `context.push('/kids/learn/lesson/${lesson.id}')` on tap.

---

## 8. Learning — `lib/features/kids/learning/`

### Data Layer

Three data-source abstractions + implementations:

**`SubjectsRemoteDataSource`**: `Future<List<Map<String, dynamic>>> fetchSubjects(int gradeLevel)` — GETs `ApiEndpoints.subjects` with query param `grade=gradeLevel`.

**`LearningRemoteDataSource`**:
```dart
Future<List<Map<String, dynamic>>> fetchChapters(String subjectId);
Future<List<Map<String, dynamic>>> fetchTopics(String chapterId);
Future<List<Map<String, dynamic>>> fetchLessons(String topicId);
Future<Map<String, dynamic>> fetchLesson(String lessonId);
Future<void> reportProgress(String lessonId, {int? positionSeconds, int? page});
```

Models: `SubjectModel`, `ChapterModel`, `TopicModel`, `LessonModel` — all with `fromJson`/`toJson`. `LessonModel.fromJson` reads `type` as a string and maps to `LessonType` enum using a `switch` with a default of `LessonType.video`.

### Domain Layer

```dart
abstract class SubjectsRepository {
  Future<Either<AppFailure, List<Subject>>> fetchSubjects(int gradeLevel);
}

abstract class LearningRepository {
  Future<Either<AppFailure, List<Chapter>>> fetchChapters(String subjectId);
  Future<Either<AppFailure, List<Topic>>> fetchTopics(String chapterId);
  Future<Either<AppFailure, List<Lesson>>> fetchLessons(String topicId);
  Future<Either<AppFailure, Lesson>> fetchLesson(String lessonId);
  Future<Either<AppFailure, void>> reportProgress(
      String lessonId, {int? positionSeconds, int? page});
}
```

Use-cases (one file each): `FetchSubjectsUseCase`, `FetchChaptersUseCase`, `FetchTopicsUseCase`, `FetchLessonsUseCase`, `FetchLessonUseCase`, `ReportLessonProgressUseCase`.

### BLoCs

**`SubjectsBloc`**:
- Events: `SubjectsLoadRequested(int gradeLevel)`
- States: `SubjectsInitial`, `SubjectsLoading`, `SubjectsSuccess(List<Subject> subjects)`, `SubjectsFailure(String message)`

**`ContentExplorerBloc`** — manages the drill-down hierarchy in a single BLoC:
- Events: `LoadSubjectChapters(String subjectId)`, `LoadChapterTopics(String chapterId)`, `LoadTopicLessons(String topicId)`
- States: `ContentExplorerInitial`, `ContentExplorerLoading`, `ChaptersLoaded(List<Chapter> chapters, String subjectId)`, `TopicsLoaded(List<Topic> topics, String chapterId)`, `LessonsLoaded(List<Lesson> lessons, String topicId)`, `ContentExplorerFailure(String message)`

Each event emits `ContentExplorerLoading` first, then the corresponding loaded state on success or `ContentExplorerFailure` on any failure.

### UI

**`content_explorer_page.dart`** — receives `subjectId` from route params. Dispatches `LoadSubjectChapters(subjectId)` on build. `BlocBuilder<ContentExplorerBloc, ContentExplorerState>` renders a `ListView.builder`. Each chapter/topic/lesson item is a `ContentItemCard` (title, `LinearProgressIndicator`, lock icon). Locked items show a paywall bottom sheet on tap instead of navigating.

Separate pages for each drill-down level are not needed — a single `ContentExplorerPage` handles all three levels, re-dispatching the appropriate event when the user taps down into a chapter or topic. The URL updates via `context.push` with the new path; the `BlocProvider` higher up keeps the `ContentExplorerBloc` alive across these pushes within the same tab branch.

**`lesson_viewer_page.dart`** — `BlocConsumer<LessonBloc, LessonState>`. Route param: `lessonId`. On build: dispatch `LessonFetchRequested(lessonId)`. On `WillPopScope` (or `PopScope` in Flutter 3.16+): dispatch `LessonProgressReportRequested()`. Renders the player widget based on `lesson.type`.

**Video player widget** (`video_player_widget.dart`): `StatefulWidget`. `initState` creates `VideoPlayerController.networkUrl(Uri.parse(lesson.contentUrl))` and a `ChewieController`. Disposes both in `dispose`. Shows `LoadingIndicator` until `controller.value.isInitialized`. On `onFinished` callback from Chewie: dispatch `LessonCompletionTriggered()`.

**PDF viewer widget** (`pdf_viewer_widget.dart`): `StatefulWidget`. Downloads PDF to a `Directory.systemTemp` file using `ApiClient.get` with `ResponseType.bytes` (if URL is authenticated) or directly via `flutter_pdfview`'s `fromUrl`. Shows page counter `X / N` via `PDFView`'s `onPageChanged` callback. On last page: dispatch `LessonCompletionTriggered()`.

**Audio player widget** (`audio_player_widget.dart`): `StatefulWidget`. Creates `AudioPlayer` in `initState`, calls `player.setUrl(lesson.contentUrl)`. Disposes player in `dispose`. `StreamBuilder<Duration?>` on `player.positionStream` for the seek slider. On completion (`player.playerStateStream` where `processingState == ProcessingState.completed`): dispatch `LessonCompletionTriggered()`.

---

## 9. Lesson BLoC — `lib/features/kids/learning/presentation/bloc/lesson_bloc.dart`

Events: `LessonFetchRequested(String lessonId)`, `LessonProgressUpdated({int? positionSeconds, int? page})`, `LessonProgressReportRequested()`, `LessonCompletionTriggered()`.

States: `LessonInitial`, `LessonLoading`, `LessonReady({required Lesson lesson, bool isCompleted = false})`, `LessonFailure(String message)`.

- `LessonFetchRequested` → emit `LessonLoading` → call `FetchLessonUseCase` → `Right` emits `LessonReady(lesson)`, `Left` emits `LessonFailure`.
- `LessonProgressUpdated` → updates internal `_currentPositionSeconds` / `_currentPage` fields in the BLoC (no state emission — these are ephemeral tracking values).
- `LessonProgressReportRequested` → call `ReportLessonProgressUseCase` with stored position/page. Failure is caught and logged with `debugPrint` but **not** surfaced to the user (fire-and-forget). No state change.
- `LessonCompletionTriggered` → if current state is `LessonReady`, emit `LessonReady(lesson: state.lesson, isCompleted: true)`. The viewer page observes `isCompleted` and shows a "Next Lesson" button.

---

## 10. Practice — `lib/features/kids/practice/`

### Data Layer

**`PracticeRemoteDataSource`**:
```dart
Future<List<Map<String, dynamic>>> fetchPracticeQuestions(String topicId);
Future<Map<String, dynamic>> submitPracticeAttempt(Map<String, dynamic> payload);
```

`PracticeAttemptModel.toJson` serialises the attempt for submission.

### Domain Layer

```dart
abstract class PracticeRepository {
  Future<Either<AppFailure, List<Question>>> fetchPracticeQuestions(String topicId);
  Future<Either<AppFailure, PracticeAttempt>> submitPracticeAttempt(PracticeAttempt attempt);
}
```

Use-cases: `FetchPracticeQuestionsUseCase(PracticeRepository)`, `SubmitPracticeAttemptUseCase(PracticeRepository)`.

### BLoC — `PracticeBloc`

Events: `PracticeStarted(String topicId)`, `AnswerSelected(int questionIndex, int optionIndex)`, `NextQuestionAdvanced`, `PracticeSubmitted`, `PracticeRetried(String topicId)`.

States:
```
PracticeInitial
PracticeLoading
PracticeInProgress({
  required List<Question> questions,
  required int currentIndex,
  required Map<int, int> selectedAnswers,   // questionIndex → optionIndex
  required Map<int, bool> answerResults,    // questionIndex → isCorrect
})
PracticeShowingResult({   // transient: 1.5 s before auto-advance
  required List<Question> questions,
  required int currentIndex,
  required Map<int, int> selectedAnswers,
  required Map<int, bool> answerResults,
  required bool lastAnswerCorrect,
})
PracticeCompleted(PracticeAttempt attempt)
PracticeFailure(String message)
```

- `PracticeStarted` → emit `PracticeLoading` → fetch questions → `Right` emits `PracticeInProgress(currentIndex: 0, empty maps)`.
- `AnswerSelected(qi, oi)` → compute `isCorrect = questions[qi].correctOptionIndex == oi` → update maps → emit `PracticeShowingResult` with `lastAnswerCorrect`. Schedule `Future.delayed(Duration(milliseconds: 1500), () => add(NextQuestionAdvanced()))`.
- `NextQuestionAdvanced` → if `currentIndex < questions.length - 1` → increment index, emit `PracticeInProgress`. Else → compute `PracticeAttempt`, call `SubmitPracticeAttemptUseCase`, emit `PracticeCompleted`.
- `PracticeRetried(topicId)` → emit `PracticeLoading`, re-dispatch `PracticeStarted(topicId)`.

### UI

**`practice_session_page.dart`** — `BlocConsumer`. Shows question card with question text and optional `CachedNetworkImage`. Four `AnswerOptionButton` widgets (52 dp height, full width). On `PracticeShowingResult`: overlay a Lottie animation (`correct.json` if correct, or a `flutter_animate` shake on the wrong button if incorrect). Cannot select another answer during `PracticeShowingResult` state.

**`practice_summary_page.dart`** — shown when state is `PracticeCompleted`. Displays score `${attempt.correctAnswers} / ${attempt.totalQuestions}`, a `flutter_animate`-driven score counter animation, encouragement copy (e.g. "Great job! 🎉"), and "Try Again" / "Back to Topics" buttons.

---

## 11. Quiz — `lib/features/kids/quiz/`

### Data Layer

**`QuizRemoteDataSource`**:
```dart
Future<Map<String, dynamic>> fetchQuiz(String quizId);
Future<Map<String, dynamic>> submitQuiz(String quizId, Map<String, dynamic> payload);
```

Models: `QuizModel.fromJson` (populates `List<Question>` by mapping `questions` array), `QuizAttemptModel.toJson`.

### Domain Layer

```dart
abstract class QuizRepository {
  Future<Either<AppFailure, Quiz>> fetchQuiz(String quizId);
  Future<Either<AppFailure, QuizAttempt>> submitQuiz(
      String quizId, QuizAttempt attempt);
}
```

Use-cases: `FetchQuizUseCase`, `SubmitQuizUseCase`.

### BLoC — `QuizBloc`

Events: `QuizLoadRequested(String quizId)`, `QuizAnswerSelected(int questionIndex, int optionIndex)`, `QuizNavigatedToQuestion(int index)`, `QuizSubmitRequested`, `QuizTimerTicked(int remainingSeconds)`.

States:
```
QuizInitial
QuizLoading
QuizInProgress({
  required Quiz quiz,
  required int currentIndex,
  required Map<int, int> selectedAnswers,
  required int? remainingSeconds,
})
QuizSubmitting
QuizCompleted({required QuizAttempt attempt, required List<Question> questions})
QuizFailure(String message)
```

Timer management: when `quiz.timeLimitSeconds != null`, the `QuizLoadRequested` handler creates `Stream.periodic(const Duration(seconds: 1), (i) => quiz.timeLimitSeconds! - i - 1).take(quiz.timeLimitSeconds!)`. Subscription stored as `StreamSubscription<int>? _timerSub`. Each tick: `add(QuizTimerTicked(tick))`. At tick = 0 (last emission): `add(QuizSubmitRequested)`. `_timerSub` is cancelled in `close()` and also in `QuizSubmitRequested` handler.

`QuizSubmitRequested` → cancel timer → emit `QuizSubmitting` → build `QuizAttemptModel` from state → call `SubmitQuizUseCase` → `Right` emits `QuizCompleted`, `Left` emits `QuizFailure`.

### UI

**`quiz_page.dart`** — `AppBar` shows question count `Q ${index+1}/${total}` and a `CountdownTimerWidget` (shows `MM:SS`, turns red when `remainingSeconds <= AppConstants.quizTimerWarningThreshold`). Body: question text, four answer buttons (selected answer highlighted in secondary colour). Bottom bar: "Previous" / "Next" buttons and a "Submit" button (shown only when all questions answered or time pressure).

**`quiz_results_page.dart`** — score circle drawn with `CustomPainter` (arc proportional to percentage), per-question review list showing correct/selected options colour-coded, "Start New Attempt" button.

---

## 12. Mock Exam — `lib/features/kids/exam/`

Mock exam reuses the `Quiz` entity with `quizType == QuizType.mockExam`. `MockExamBloc` mirrors `QuizBloc` exactly in structure but fetches from `ApiEndpoints.mockExamDetail` and submits to `ApiEndpoints.mockExamSubmit`. The results page adds a subject-area breakdown section if the API response includes `section_scores`.

The `lib/features/kids/exam/` directory does **not** exist in the pre-created tree and must be created during implementation (see Section 22).

`MockExamBloc` events/states are named `MockExam*` to avoid naming collisions if both are provided on the same widget tree. Implementation follows the identical pattern as `QuizBloc`.

**Accessibility from Practice tab**: `PracticeTabPage` is a `DefaultTabController` with two tabs — "Practice" and "Exams" — rendered as a `TabBarView`. The "Exams" tab shows a `ListView` of available mock exams fetched by `MockExamBloc`.

---

## 13. Progress — `lib/features/kids/progress/`

### Data Layer

**`ProgressRemoteDataSource`**:
```dart
Future<Map<String, dynamic>> fetchProgress();
Future<List<Map<String, dynamic>>> fetchAchievements();
```

### Domain Layer

```dart
abstract class ProgressRepository {
  Future<Either<AppFailure, ProgressRecord>> fetchProgress();
  Future<Either<AppFailure, List<Achievement>>> fetchAchievements();
}
```

Use-cases: `FetchProgressUseCase`, `FetchAchievementsUseCase`.

### BLoC — `ProgressBloc`

Events: `ProgressLoadRequested`.
States: `ProgressInitial`, `ProgressLoading`, `ProgressSuccess({required ProgressRecord record, required List<Achievement> achievements})`, `ProgressFailure(String message)`.

Handler: emit `ProgressLoading` → `Future.wait([fetchProgress(), fetchAchievements()])` via two parallel use-case calls. If both succeed → emit `ProgressSuccess`. If either fails → emit `ProgressFailure(failure.message)`.

### UI — `progress_page.dart`

`CustomScrollView` with slivers:

1. **Overall completion** — large percentage text with `flutter_animate` count-up effect (`.animate().custom(builder: (_, value, __) => Text("${(value * record.overallCompletion * 100).toInt()}%"))`).
2. **Subject completion list** — `SliverList` with `SubjectProgressTile` (subject name, `LinearProgressIndicator`, percentage text).
3. **Weekly activity chart** — `SliverToBoxAdapter` wrapping a `SizedBox(height: 180)` with a `CustomPaint(painter: WeeklyActivityPainter(record.weeklyActivity))`. `WeeklyActivityPainter` draws 7 rounded bars, labels the day abbreviation below, and marks the current day with the primary colour.
4. **Achievements** — `SliverGrid` with 3 columns. `AchievementBadge`: `CachedNetworkImage` badge, title text below. For achievements where `isUnlocked && unlockedAt != null && DateTime.now().difference(unlockedAt!) < Duration(hours: 24)`: overlay a `Lottie(asset: AssetConstants.celebrationAnimation)` played once.

---

## 14. Search — `lib/features/kids/search/`

### Data Layer

**`SearchRemoteDataSource`**: `Future<Map<String, dynamic>> search(String query)` — GETs `ApiEndpoints.search?q=query`.

### Domain Layer

```dart
abstract class SearchRepository {
  Future<Either<AppFailure, SearchResults>> search(String query);
}
```

`SearchResults` is a domain value object: `List<Subject> subjects, List<Topic> topics, List<Lesson> lessons`.

Use-case: `SearchUseCase(SearchRepository)`.

### BLoC — `SearchBloc`

Events: `SearchQueryChanged(String query)`, `SearchCleared`.
States: `SearchInitial`, `SearchLoading`, `SearchSuccess(SearchResults results)`, `SearchEmpty`, `SearchFailure(String message)`.

Debounce implementation — no rxdart, no new dependency. Use a `Timer` field in the BLoC:

```dart
Timer? _debounceTimer;

void _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
  _debounceTimer?.cancel();
  if (event.query.trim().isEmpty) {
    emit(const SearchInitial());
    return;
  }
  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
    add(_SearchExecuted(event.query.trim()));
  });
}
```

`_SearchExecuted` is a private internal event that triggers the actual API call. `_debounceTimer` is cancelled in `close()`. This pattern keeps BLoC testable — `_SearchExecuted` can be added directly in tests without worrying about the timer.

`SearchCleared` → cancel timer → emit `SearchInitial`.

### UI

`SearchBar` widget lives at the top of `ContentExplorerPage`. It is a `TextFormField` styled as a search input. On change: `context.read<SearchBloc>().add(SearchQueryChanged(value))`. When `SearchBloc` state is anything other than `SearchInitial`, the content below the search bar switches from the chapter/topic list to `SearchResultsView`.

`SearchResultsView` uses a `CustomScrollView` with `SliverPersistentHeader` section separators for "Subjects", "Topics", "Lessons". Empty state uses `EmptyView` with `AssetConstants.emptyAnimation`.

---

## 15. Notifications — `lib/features/kids/notifications/`

### Data Layer

**`NotificationsRemoteDataSource`**:
```dart
Future<List<Map<String, dynamic>>> fetchNotifications();
Future<void> markAsRead(String id);
```

### Domain Layer

```dart
abstract class NotificationsRepository {
  Future<Either<AppFailure, List<Notification>>> fetchNotifications();
  Future<Either<AppFailure, void>> markAsRead(String id);
}
```

Use-cases: `FetchNotificationsUseCase`, `MarkNotificationReadUseCase`.

### BLoC — `NotificationBloc`

Events: `NotificationsLoadRequested`, `NotificationReadMarkRequested(String id)`.
States: `NotificationInitial`, `NotificationLoading`, `NotificationSuccess(List<Notification> notifications)`, `NotificationFailure(String message)`.

`NotificationReadMarkRequested` → call `MarkNotificationReadUseCase` → on `Right`: copy the notifications list with the target item's `isRead = true` (using `Notification.copyWith`), emit updated `NotificationSuccess`. On `Left`: no state change (best-effort — a failed mark-as-read is silent).

Unread count is derived in the UI: `state.notifications.where((n) => !n.isRead).length`.

### UI

**`notifications_page.dart`** — `ListView.builder`. Each `NotificationTile`: leading `CircleAvatar` icon keyed on `NotificationType`, title in `TextStyle` bold if unread, body (max 2 lines), relative timestamp via `intl`'s `DateFormat`. Tapping: if `notification.deepLinkRoute != null`, call `context.push(notification.deepLinkRoute!, extra: notification.deepLinkParams)`.

**`NotificationBadge`** widget (in `lib/core/widgets/notification_badge.dart`): wraps any widget with a `Stack` + `Positioned` red `CircleAvatar` showing unread count as text. Used in the profile tab icon and in the `AppBar` `actions` list.

---

## 16. Profile — `lib/features/kids/profile/`

`ProfilePage` mounts `MultiBlocProvider` with `SubscriptionBloc` and `ParentLinkBloc` (both factory-registered, scoped to this page's route lifecycle).

### SubscriptionBloc

Events: `SubscriptionLoadRequested`.
States: `SubscriptionInitial`, `SubscriptionLoading`, `SubscriptionSuccess(SubscriptionEntitlement entitlement)`, `SubscriptionFailure(String message)`.

Data source GETs `ApiEndpoints.subscription`.

### ParentLinkBloc

Events: `ParentLinkStatusLoadRequested`, `ParentLinkCodeSubmitRequested(String code)`.
States: `ParentLinkInitial`, `ParentLinkLoading`, `ParentLinked(String parentDisplayName)`, `ParentLinkUnlinked`, `ParentLinkFailure(String message)`.

`ParentLinkStatusLoadRequested` → GET `ApiEndpoints.parentLink` → `Right(data)`: if data contains a parent, emit `ParentLinked`; else emit `ParentLinkUnlinked`. `Left` → emit `ParentLinkFailure`.

`ParentLinkCodeSubmitRequested(code)` — validation: `code` must match `^[A-Z0-9]{6}$` (enforced in the dialog widget before dispatching, not in the BLoC). If valid → POST `ApiEndpoints.parentLink` with `{"code": code}` → `Right` emits `ParentLinked`, `Left` emits `ParentLinkFailure`.

### UI — `profile_page.dart`

`CustomScrollView`:

1. **Header `SliverAppBar`** (`expandedHeight: 200`, `flexibleSpace: FlexibleSpaceBar`): avatar circle (`CachedNetworkImage` with `initials-fallback` painter), display name, grade badge (`Chip`).
2. **Edit display name** — `TextFormField` pre-filled with current name, save button appears when text changes.
3. **Edit photo** — `KidButton(label: "Edit Photo")` shows a `SnackBar("Photo upload coming soon")`. Rationale: `image_picker` is not in `pubspec.yaml`; adding it is out of scope per requirements. This button is a placeholder pending that dependency.
4. **Subscription card** — `KidCard` showing plan name, expiry date (`DateFormat.yMMMd().format(expiresAt)`), "Upgrade" button (shows a stub dialog for free-tier users).
5. **Parent link** — if `ParentLinked`: shows "Linked to: [parentName] ✓". If `ParentLinkUnlinked`: shows "Link Parent" `KidButton` that opens `ParentLinkDialog`.
6. **Notifications shortcut** — `ListTile` with bell icon that navigates to `RouteConstants.kidsNotifications`.
7. **Logout** — `KidButton(label: "Log Out", variant: KidButtonVariant.outlined, onPressed: () => context.read<AuthBloc>().add(AuthLoggedOut()))`.

**`ParentLinkDialog`** — `AlertDialog` with a 6-char uppercase alphanumeric `TextFormField`. Validation enforced locally: regex `^[A-Z0-9]{6}$`. Submit dispatches `ParentLinkCodeSubmitRequested`. BLoC listener shows success/error feedback.

---

## 17. BLoC Scoping & Provision Strategy

| BLoC | Scope | Provided in |
|---|---|---|
| `AuthBloc` | App-wide | `MultiBlocProvider` in `KutaKidsApp` |
| `GradeRoutingBloc` | App-wide | `MultiBlocProvider` in `KutaKidsApp` |
| `KidsDashboardBloc` | Dashboard tab | Route `builder` wrapping `DashboardPage` |
| `SubjectsBloc` | Learn tab | Route `builder` wrapping `ContentExplorerPage` |
| `ContentExplorerBloc` | Learn tab | Route `builder` wrapping `ContentExplorerPage` |
| `SearchBloc` | Learn tab | Route `builder` wrapping `ContentExplorerPage` |
| `LessonBloc` | Lesson route | Route `builder` wrapping `LessonViewerPage` |
| `PracticeBloc` | Practice session route | Route `builder` wrapping `PracticeSessionPage` |
| `QuizBloc` | Quiz route | Route `builder` wrapping `QuizPage` |
| `MockExamBloc` | Exam route | Route `builder` wrapping `MockExamPage` |
| `ProgressBloc` | Progress tab | Route `builder` wrapping `ProgressPage` |
| `NotificationBloc` | Notifications page | Route `builder` wrapping `NotificationsPage` |
| `SubscriptionBloc` | Profile tab | Route `builder` wrapping `ProfilePage` |
| `ParentLinkBloc` | Profile tab | Route `builder` wrapping `ProfilePage` |

The route builder pattern: `builder: (context, state) => BlocProvider(create: (_) => sl<XBloc>()..add(LoadEvent()), child: XPage())`. Using the router's `builder` rather than a page-internal `BlocProvider.value` means the BLoC is automatically disposed when the route leaves the navigator stack.

---

## 18. Error Handling Matrix

| Operation | Failure Condition | Recoverable? | What caller receives | Logged? |
|---|---|---|---|---|
| Any `Dio` request — network | No connectivity / timeout | Yes (user retry) | `NetworkFailure` → BLoC emits `*Failure` → `ErrorView` with retry | `debugPrint` in debug mode only |
| Token refresh — success | Expired access token | Transparent | Original response after retry | No |
| Token refresh — failure | Invalid/expired refresh token | Fatal (re-login) | `AuthFailure` → `AuthBloc.add(AuthLoggedOut())` → navigate to login | `debugPrint` |
| Any request — 403 | No entitlement | Yes (paywall) | `PermissionFailure` → paywall bottom sheet | No |
| Any request — 404 | Resource not found | Yes (empty state) | `NotFoundFailure` → `EmptyView` | No |
| Any request — 5xx | Server error | Yes (user retry) | `ServerFailure` → `ErrorView` | No |
| `SharedPreferences` read | Corrupt / missing value | Yes (treat as absent) | `CacheFailure` → `AuthUnauthenticated` | `debugPrint` |
| `VideoPlayerController` init | Invalid URL / codec | Yes (reload) | `ErrorView` inside player area | No |
| PDF download | Network failure | Yes (retry) | `ErrorView` overlaid on viewer | No |
| `AudioPlayer.setUrl` | URL unreachable | Yes (retry) | `ErrorView` overlaid on player | No |
| Quiz timer expiry | Normal auto-submit | N/A | `QuizSubmitRequested` event auto-fired | No |
| Lesson progress report | Any failure | No (fire-and-forget) | Silently swallowed; next open re-syncs | `debugPrint` |
| Mark notification read | Any failure | No (best-effort) | No state change, UI unchanged | `debugPrint` |

All `debugPrint` calls are guarded by `kDebugMode` so they compile away in release builds.

---

## 19. Input Validation Rules

| Input | Required | Type | Constraints | On failure |
|---|---|---|---|---|
| Login username | Yes | `String` | Non-empty, trimmed, max 100 chars | Inline field error: "Username is required" |
| Login password | Yes | `String` | Non-empty, min 6 chars | Inline field error: "Password too short" |
| Search query | No | `String` | Trimmed; if empty → `SearchInitial`, no API call; max 200 chars | No error shown; query silently clamped |
| Parent link code | Yes | `String` | Exactly 6 chars, `[A-Z0-9]` only | Dialog shows "Invalid code — must be 6 uppercase letters/numbers" |
| Profile display name | Yes | `String` | Non-empty, max 50 chars | Inline field error: "Name is required" |

Validation lives entirely in the presentation layer (form widgets). Repositories receive only already-validated values. BLoCs do not re-validate.

---

## 20. Analysis Options Additions

The current `analysis_options.yaml` uses `package:flutter_lints/flutter.yaml`. The following rules are added to enforce NFR-6:

```yaml
linter:
  rules:
    prefer_single_quotes: true
    always_declare_return_types: true
    avoid_dynamic_calls: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    use_super_parameters: true
    require_trailing_commas: true
```

`avoid_dynamic_calls` directly enforces the "no `dynamic` except at JSON deserialization boundaries" requirement.

---

## 21. Complete File Map

### App bootstrap
- `lib/main.dart` *(replace)*
- `lib/app/app.dart`
- `lib/app/app_router.dart`
- `lib/app/route_guard.dart`

### Core
- `lib/core/di/service_locator.dart`
- `lib/core/theme/kids_theme.dart`
- `lib/core/theme/kids_colors.dart`
- `lib/core/errors/failures.dart`
- `lib/core/network/dio_factory.dart`
- `lib/core/network/auth_interceptor.dart`
- `lib/core/network/token_refresh_interceptor.dart`
- `lib/core/network/error_interceptor.dart`
- `lib/core/network/api_client.dart`
- `lib/core/storage/local_storage.dart`
- `lib/core/storage/local_storage_impl.dart`
- `lib/core/constants/route_constants.dart`
- `lib/core/constants/asset_constants.dart`
- `lib/core/widgets/loading_indicator.dart`
- `lib/core/widgets/error_view.dart`
- `lib/core/widgets/empty_view.dart`
- `lib/core/widgets/kid_button.dart`
- `lib/core/widgets/kid_card.dart`
- `lib/core/widgets/app_scaffold.dart`
- `lib/core/widgets/notification_badge.dart`

### Authentication
- `lib/features/authentication/domain/entities/student.dart`
- `lib/features/authentication/domain/repositories/auth_repository.dart`
- `lib/features/authentication/domain/usecases/login_usecase.dart`
- `lib/features/authentication/domain/usecases/logout_usecase.dart`
- `lib/features/authentication/domain/usecases/get_stored_student_usecase.dart`
- `lib/features/authentication/data/models/student_model.dart`
- `lib/features/authentication/data/datasources/auth_remote_data_source.dart`
- `lib/features/authentication/data/repositories/auth_repository_impl.dart`
- `lib/features/authentication/presentation/bloc/auth_bloc.dart`
- `lib/features/authentication/presentation/bloc/auth_event.dart`
- `lib/features/authentication/presentation/bloc/auth_state.dart`
- `lib/features/authentication/presentation/pages/splash_page.dart`
- `lib/features/authentication/presentation/pages/login_page.dart`
- `lib/features/authentication/presentation/widgets/login_form.dart`

### Grade Routing
- `lib/features/grade_routing/domain/entities/grade.dart`
- `lib/features/grade_routing/domain/usecases/determine_grade_route_usecase.dart`
- `lib/features/grade_routing/presentation/bloc/grade_routing_bloc.dart`
- `lib/features/grade_routing/presentation/bloc/grade_routing_event.dart`
- `lib/features/grade_routing/presentation/bloc/grade_routing_state.dart`
- `lib/features/grade_routing/presentation/pages/kids_shell_page.dart`
- `lib/features/grade_routing/presentation/pages/middle_placeholder_page.dart`
- `lib/features/grade_routing/presentation/pages/high_school_placeholder_page.dart`

### Dashboard
- `lib/features/kids/dashboard/domain/entities/dashboard_data.dart`
- `lib/features/kids/dashboard/domain/repositories/dashboard_repository.dart`
- `lib/features/kids/dashboard/domain/usecases/fetch_dashboard_usecase.dart`
- `lib/features/kids/dashboard/data/models/dashboard_model.dart`
- `lib/features/kids/dashboard/data/datasources/dashboard_remote_data_source.dart`
- `lib/features/kids/dashboard/data/repositories/dashboard_repository_impl.dart`
- `lib/features/kids/dashboard/presentation/bloc/kids_dashboard_bloc.dart`
- `lib/features/kids/dashboard/presentation/bloc/kids_dashboard_event.dart`
- `lib/features/kids/dashboard/presentation/bloc/kids_dashboard_state.dart`
- `lib/features/kids/dashboard/presentation/pages/dashboard_page.dart`
- `lib/features/kids/dashboard/presentation/widgets/subject_card.dart`
- `lib/features/kids/dashboard/presentation/widgets/continue_learning_card.dart`
- `lib/features/kids/dashboard/presentation/widgets/daily_streak_banner.dart`
- `lib/features/kids/dashboard/presentation/widgets/recent_achievements_row.dart`

### Learning
- `lib/features/kids/learning/domain/entities/subject.dart`
- `lib/features/kids/learning/domain/entities/chapter.dart`
- `lib/features/kids/learning/domain/entities/topic.dart`
- `lib/features/kids/learning/domain/entities/lesson.dart`
- `lib/features/kids/learning/domain/entities/lesson_type.dart`
- `lib/features/kids/learning/domain/repositories/subjects_repository.dart`
- `lib/features/kids/learning/domain/repositories/learning_repository.dart`
- `lib/features/kids/learning/domain/usecases/fetch_subjects_usecase.dart`
- `lib/features/kids/learning/domain/usecases/fetch_chapters_usecase.dart`
- `lib/features/kids/learning/domain/usecases/fetch_topics_usecase.dart`
- `lib/features/kids/learning/domain/usecases/fetch_lessons_usecase.dart`
- `lib/features/kids/learning/domain/usecases/fetch_lesson_usecase.dart`
- `lib/features/kids/learning/domain/usecases/report_lesson_progress_usecase.dart`
- `lib/features/kids/learning/data/models/subject_model.dart`
- `lib/features/kids/learning/data/models/chapter_model.dart`
- `lib/features/kids/learning/data/models/topic_model.dart`
- `lib/features/kids/learning/data/models/lesson_model.dart`
- `lib/features/kids/learning/data/datasources/subjects_remote_data_source.dart`
- `lib/features/kids/learning/data/datasources/learning_remote_data_source.dart`
- `lib/features/kids/learning/data/repositories/subjects_repository_impl.dart`
- `lib/features/kids/learning/data/repositories/learning_repository_impl.dart`
- `lib/features/kids/learning/presentation/bloc/subjects_bloc.dart`
- `lib/features/kids/learning/presentation/bloc/subjects_event.dart`
- `lib/features/kids/learning/presentation/bloc/subjects_state.dart`
- `lib/features/kids/learning/presentation/bloc/content_explorer_bloc.dart`
- `lib/features/kids/learning/presentation/bloc/content_explorer_event.dart`
- `lib/features/kids/learning/presentation/bloc/content_explorer_state.dart`
- `lib/features/kids/learning/presentation/bloc/lesson_bloc.dart`
- `lib/features/kids/learning/presentation/bloc/lesson_event.dart`
- `lib/features/kids/learning/presentation/bloc/lesson_state.dart`
- `lib/features/kids/learning/presentation/pages/content_explorer_page.dart`
- `lib/features/kids/learning/presentation/pages/lesson_viewer_page.dart`
- `lib/features/kids/learning/presentation/widgets/video_player_widget.dart`
- `lib/features/kids/learning/presentation/widgets/pdf_viewer_widget.dart`
- `lib/features/kids/learning/presentation/widgets/audio_player_widget.dart`
- `lib/features/kids/learning/presentation/widgets/content_item_card.dart`

### Practice
- `lib/features/kids/practice/domain/entities/question.dart`
- `lib/features/kids/practice/domain/entities/practice_attempt.dart`
- `lib/features/kids/practice/domain/repositories/practice_repository.dart`
- `lib/features/kids/practice/domain/usecases/fetch_practice_questions_usecase.dart`
- `lib/features/kids/practice/domain/usecases/submit_practice_attempt_usecase.dart`
- `lib/features/kids/practice/data/models/question_model.dart`
- `lib/features/kids/practice/data/models/practice_attempt_model.dart`
- `lib/features/kids/practice/data/datasources/practice_remote_data_source.dart`
- `lib/features/kids/practice/data/repositories/practice_repository_impl.dart`
- `lib/features/kids/practice/presentation/bloc/practice_bloc.dart`
- `lib/features/kids/practice/presentation/bloc/practice_event.dart`
- `lib/features/kids/practice/presentation/bloc/practice_state.dart`
- `lib/features/kids/practice/presentation/pages/practice_tab_page.dart`
- `lib/features/kids/practice/presentation/pages/practice_session_page.dart`
- `lib/features/kids/practice/presentation/pages/practice_summary_page.dart`
- `lib/features/kids/practice/presentation/widgets/answer_option_button.dart`

### Quiz
- `lib/features/kids/quiz/domain/entities/quiz.dart`
- `lib/features/kids/quiz/domain/entities/quiz_attempt.dart`
- `lib/features/kids/quiz/domain/repositories/quiz_repository.dart`
- `lib/features/kids/quiz/domain/usecases/fetch_quiz_usecase.dart`
- `lib/features/kids/quiz/domain/usecases/submit_quiz_usecase.dart`
- `lib/features/kids/quiz/data/models/quiz_model.dart`
- `lib/features/kids/quiz/data/models/quiz_attempt_model.dart`
- `lib/features/kids/quiz/data/datasources/quiz_remote_data_source.dart`
- `lib/features/kids/quiz/data/repositories/quiz_repository_impl.dart`
- `lib/features/kids/quiz/presentation/bloc/quiz_bloc.dart`
- `lib/features/kids/quiz/presentation/bloc/quiz_event.dart`
- `lib/features/kids/quiz/presentation/bloc/quiz_state.dart`
- `lib/features/kids/quiz/presentation/pages/quiz_page.dart`
- `lib/features/kids/quiz/presentation/pages/quiz_results_page.dart`
- `lib/features/kids/quiz/presentation/widgets/countdown_timer_widget.dart`

### Mock Exam *(directory must be created)*
- `lib/features/kids/exam/domain/entities/` *(reuses Quiz entity)*
- `lib/features/kids/exam/domain/repositories/mock_exam_repository.dart`
- `lib/features/kids/exam/domain/usecases/fetch_mock_exam_usecase.dart`
- `lib/features/kids/exam/domain/usecases/submit_mock_exam_usecase.dart`
- `lib/features/kids/exam/data/datasources/mock_exam_remote_data_source.dart`
- `lib/features/kids/exam/data/repositories/mock_exam_repository_impl.dart`
- `lib/features/kids/exam/presentation/bloc/mock_exam_bloc.dart`
- `lib/features/kids/exam/presentation/bloc/mock_exam_event.dart`
- `lib/features/kids/exam/presentation/bloc/mock_exam_state.dart`
- `lib/features/kids/exam/presentation/pages/mock_exam_page.dart`
- `lib/features/kids/exam/presentation/pages/mock_exam_results_page.dart`

### Progress
- `lib/features/kids/progress/domain/entities/progress_record.dart`
- `lib/features/kids/progress/domain/entities/achievement.dart`
- `lib/features/kids/progress/domain/repositories/progress_repository.dart`
- `lib/features/kids/progress/domain/usecases/fetch_progress_usecase.dart`
- `lib/features/kids/progress/domain/usecases/fetch_achievements_usecase.dart`
- `lib/features/kids/progress/data/models/progress_record_model.dart`
- `lib/features/kids/progress/data/models/achievement_model.dart`
- `lib/features/kids/progress/data/datasources/progress_remote_data_source.dart`
- `lib/features/kids/progress/data/repositories/progress_repository_impl.dart`
- `lib/features/kids/progress/presentation/bloc/progress_bloc.dart`
- `lib/features/kids/progress/presentation/bloc/progress_event.dart`
- `lib/features/kids/progress/presentation/bloc/progress_state.dart`
- `lib/features/kids/progress/presentation/pages/progress_page.dart`
- `lib/features/kids/progress/presentation/widgets/weekly_activity_painter.dart`
- `lib/features/kids/progress/presentation/widgets/achievement_badge.dart`

### Search
- `lib/features/kids/search/domain/entities/search_results.dart`
- `lib/features/kids/search/domain/repositories/search_repository.dart`
- `lib/features/kids/search/domain/usecases/search_usecase.dart`
- `lib/features/kids/search/data/datasources/search_remote_data_source.dart`
- `lib/features/kids/search/data/repositories/search_repository_impl.dart`
- `lib/features/kids/search/presentation/bloc/search_bloc.dart`
- `lib/features/kids/search/presentation/bloc/search_event.dart`
- `lib/features/kids/search/presentation/bloc/search_state.dart`
- `lib/features/kids/search/presentation/widgets/search_results_view.dart`

### Notifications
- `lib/features/kids/notifications/domain/entities/notification.dart`
- `lib/features/kids/notifications/domain/repositories/notifications_repository.dart`
- `lib/features/kids/notifications/domain/usecases/fetch_notifications_usecase.dart`
- `lib/features/kids/notifications/domain/usecases/mark_notification_read_usecase.dart`
- `lib/features/kids/notifications/data/models/notification_model.dart`
- `lib/features/kids/notifications/data/datasources/notifications_remote_data_source.dart`
- `lib/features/kids/notifications/data/repositories/notifications_repository_impl.dart`
- `lib/features/kids/notifications/presentation/bloc/notification_bloc.dart`
- `lib/features/kids/notifications/presentation/bloc/notification_event.dart`
- `lib/features/kids/notifications/presentation/bloc/notification_state.dart`
- `lib/features/kids/notifications/presentation/pages/notifications_page.dart`
- `lib/features/kids/notifications/presentation/widgets/notification_tile.dart`

### Profile
- `lib/features/kids/profile/domain/entities/subscription_entitlement.dart`
- `lib/features/kids/profile/domain/repositories/subscription_repository.dart`
- `lib/features/kids/profile/domain/repositories/parent_link_repository.dart`
- `lib/features/kids/profile/domain/usecases/fetch_subscription_usecase.dart`
- `lib/features/kids/profile/domain/usecases/fetch_parent_link_usecase.dart`
- `lib/features/kids/profile/domain/usecases/submit_parent_link_code_usecase.dart`
- `lib/features/kids/profile/data/models/subscription_entitlement_model.dart`
- `lib/features/kids/profile/data/datasources/subscription_remote_data_source.dart`
- `lib/features/kids/profile/data/datasources/parent_link_remote_data_source.dart`
- `lib/features/kids/profile/data/repositories/subscription_repository_impl.dart`
- `lib/features/kids/profile/data/repositories/parent_link_repository_impl.dart`
- `lib/features/kids/profile/presentation/bloc/subscription_bloc.dart`
- `lib/features/kids/profile/presentation/bloc/subscription_event.dart`
- `lib/features/kids/profile/presentation/bloc/subscription_state.dart`
- `lib/features/kids/profile/presentation/bloc/parent_link_bloc.dart`
- `lib/features/kids/profile/presentation/bloc/parent_link_event.dart`
- `lib/features/kids/profile/presentation/bloc/parent_link_state.dart`
- `lib/features/kids/profile/presentation/pages/profile_page.dart`
- `lib/features/kids/profile/presentation/widgets/parent_link_dialog.dart`

### Tests
- `test/features/authentication/bloc/auth_bloc_test.dart`
- `test/features/grade_routing/bloc/grade_routing_bloc_test.dart`
- `test/features/kids/dashboard/bloc/kids_dashboard_bloc_test.dart`
- `test/features/kids/learning/bloc/subjects_bloc_test.dart`
- `test/features/kids/learning/bloc/content_explorer_bloc_test.dart`
- `test/features/kids/learning/bloc/lesson_bloc_test.dart`
- `test/features/kids/practice/bloc/practice_bloc_test.dart`
- `test/features/kids/quiz/bloc/quiz_bloc_test.dart`
- `test/features/kids/exam/bloc/mock_exam_bloc_test.dart`
- `test/features/kids/progress/bloc/progress_bloc_test.dart`
- `test/features/kids/search/bloc/search_bloc_test.dart`
- `test/features/kids/notifications/bloc/notification_bloc_test.dart`
- `test/features/kids/profile/bloc/subscription_bloc_test.dart`
- `test/features/kids/profile/bloc/parent_link_bloc_test.dart`

---

## 22. Testability Notes

BLoCs have zero Flutter dependency — they operate on pure Dart objects. Each test file uses `blocTest<B, S>()` from `bloc_test` and `mocktail` for stubbing use-cases and repositories. Coverage targets per BLoC:

- Initial state assertion
- Success path (mock use-case returns `Right(value)`)
- Network failure path (mock returns `Left(NetworkFailure(...))`)
- Auth failure path where applicable (mock returns `Left(AuthFailure(...))`)
- `QuizBloc` / `MockExamBloc`: timer tick sequence and auto-submit on zero
- `PracticeBloc`: `AnswerSelected` → `NextQuestionAdvanced` auto-advance sequence
- `SearchBloc`: debounce timer fires correctly (test advances `fakeAsync` clock)
- `AuthBloc`: `AuthStarted` with stored student, without stored student, and with refresh failure

The `LocalStorage` abstraction, `ApiClient` wrapper, and abstract repository interfaces make all external boundaries mockable with `mocktail` without any Flutter test overhead.

---

## 23. Missing Directory

`lib/features/kids/exam/` does not exist in the pre-created directory tree. The implementation step must create it with `data/`, `domain/`, and `presentation/` subdirectories before writing any files to it.

---

## Review Responses

No `design-review.json` or `03-design-review.md` file exists in `.agents/pipeline/2026-10-12_10-39-28/` at authoring time. This is a first-pass design. No review findings to address.
