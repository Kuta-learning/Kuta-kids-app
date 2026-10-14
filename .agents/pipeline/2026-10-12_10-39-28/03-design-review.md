# Design Review: Kuta Kids Learning Module

**Reviewed file:** `02-design.md`
**Requirements file:** `01-requirements.md` — **FILE DOES NOT EXIST** in the pipeline directory. The review therefore treats the existing codebase as the authoritative baseline and checks the design's claims about it directly.
**Codebase root:** `c:\Users\dell\Documents\GitHub\Kuta-kids-app`
**Date:** 2026-10-12

---

## Numbered Findings

### Finding 1 — HIGH: `01-requirements.md` is missing; design has no verified requirements basis

**Where:** Pipeline directory `2026-10-12_10-39-28/`. Only `02-design.md` exists.

**Problem:** The design document claims to implement a set of requirements, but no requirements file exists to verify scope, completeness, or correctness of the design's choices. Any claim in the design that begins "per the requirements…" or "NFR-6" is unverifiable.

**Concrete fix:** The requirements document must be written and committed as `01-requirements.md` before the design is considered reviewable. Implementation must not start without it.

---

### Finding 2 — HIGH: `pubspec.yaml` is missing 11 of 16 claimed dependencies

**Where:** Design Overview / Technology stack; verified against actual `pubspec.yaml`.

The design states the following packages are "already declared" in `pubspec.yaml`:

| Package | Claimed version | Actual status |
|---|---|---|
| `equatable` | `^2.0.5` | **MISSING** |
| `dartz` | `^0.10.1` | **MISSING** |
| `cached_network_image` | `^3.4.1` | **MISSING** |
| `video_player` | `^2.9.2` | **MISSING** |
| `chewie` | `^1.8.5` | **MISSING** |
| `flutter_pdfview` | `^1.3.2` | **MISSING** |
| `just_audio` | `^0.9.40` | **MISSING** |
| `lottie` | `^3.1.2` | **MISSING** |
| `flutter_animate` | `^4.5.0` | **MISSING** |
| `intl` | `^0.19.0` | **MISSING** |
| `get_it` | `^8.0.2` | **MISSING** |
| `bloc_test` | `^9.1.7` | **MISSING** |
| `mocktail` | `^1.0.4` | **MISSING** |
| `flutter_bloc` | `^8.1.6` | Present but actual version is `^9.0.0` |
| `go_router` | `^14.2.7` | Present but actual version is `^14.6.3` |
| `shared_preferences` | `^2.3.2` | Present but actual version is `^2.3.3` |

The design's entire architecture (BLoC, Clean Architecture with `Either`, Lottie animations, video/PDF/audio, GetIt DI) relies on packages that are not in the project. The implementer cannot compile anything without adding all 11 missing packages first.

**Concrete fix:** Add the following to `pubspec.yaml` before implementation and update the design's version table to match:
```yaml
dependencies:
  equatable: ^2.0.5
  dartz: ^0.10.1
  cached_network_image: ^3.4.1
  video_player: ^2.9.2
  chewie: ^1.8.5
  flutter_pdfview: ^1.3.2
  just_audio: ^0.9.40
  lottie: ^3.1.2
  flutter_animate: ^4.5.0
  intl: ^0.19.0
  get_it: ^8.0.2
dev_dependencies:
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

### Finding 3 — HIGH: Design claims "only `lib/main.dart` and two files in `lib/core` contain any code; all feature directories exist but are empty"

**Where:** Design Overview, first paragraph.

**Problem:** This is completely wrong. The actual codebase contains a substantial existing implementation:

- `lib/main.dart` is **not** the default counter app. It already initialises `SharedPrefsStorage`, `MockAuthService`, and `AuthBloc`, and calls `runApp(BlocProvider(...))`.
- `lib/app.dart` already exists with `KutaApp` using `AppTheme.lightTheme` and `AppRouter.router`.
- `lib/core/` contains 17 non-empty files: a complete `AppColors`, `AppTheme`, `AppRouter`, `RouteNames`, `LocalStorage` interface, `SharedPrefsStorage` implementation, `StorageKeys`, `AssetConstants`, `AppConstants`, `ApiEndpoints`, `GradeLevel` enum, `AppButton`, `AppLoadingIndicator`, `AppTextField`, `formatters.dart`, `validators.dart`, `app_localization.dart`.
- `lib/features/authentication/` has a complete BLoC (`AuthBloc`, events, states), a `UserModel`, `AuthService`, `MockAuthService`, login screen, register screen, and widgets.
- `lib/features/grades/` has models, screens, and widgets for grades 6, 8, and 12.
- `lib/features/kg/` has KG screens, models, and services.
- `lib/features/profile/` has a profile screen, model, and service.
- `lib/features/common/` has a splash screen, progress model, and service.

The design will collide with every one of these existing files. If the implementer follows the design literally, they will overwrite or discard a working codebase without realising it.

**Concrete fix:** The design must either (a) explicitly acknowledge and describe how each existing file is migrated or extended, or (b) specify that a clean scaffold is to be created in a new directory. The design cannot simply pretend the existing code does not exist.

---

### Finding 4 — HIGH: The existing `AuthBloc` contract is incompatible with the design's `AuthBloc`

**Where:** Section 4 (Authentication), Presentation Layer.

**Problem:** The existing `AuthBloc` (verified in source):
- Takes `AuthService` in its constructor (not `LoginUseCase, LogoutUseCase, GetStoredStudentUseCase`)
- Uses `AuthState` as a `sealed class` (not `Equatable`)
- `AuthAuthenticated` holds `UserModel user` (not `Student student`)
- Events are `AuthCheckRequested`, `RegisterRequested`, `LoginRequested`, `LogoutRequested` (not `AuthStarted`, `AuthLoginRequested`, `AuthLoggedOut`)
- Error state is `AuthFailure(String message)` (not `AuthError(String message)`)

The design introduces entirely different events, states, and constructor without explaining that the existing implementation must be replaced. The `GradeRoutingBloc` references `DetermineGradeRoute(state.student)` but the authenticated state will contain a `UserModel` not a `Student`.

**Concrete fix:** The design must explicitly state "the existing `AuthBloc`, events, and states are replaced in full" and provide a migration note. The new `Student` entity must map `UserModel.gradeLevel: GradeLevel` (an enum with values `kg, grade6, grade8, grade12`) to the new `int grade` field — this mapping is not defined anywhere.

---

### Finding 5 — HIGH: `AppConstants` does not contain `kidsMaxGrade`, `middleMaxGrade`, `tokenKey`, `refreshTokenKey`, `userProfileKey`, or `quizTimerWarningThreshold`

**Where:** Section 2.6 (Constants), Section 5 (Grade Routing), Section 11 (Quiz), Section 2.4 (Storage).

**Problem:** The design references `AppConstants.kidsMaxGrade`, `AppConstants.middleMaxGrade`, `AppConstants.tokenKey`, `AppConstants.refreshTokenKey`, `AppConstants.userProfileKey`, and `AppConstants.quizTimerWarningThreshold`. The actual `AppConstants` contains only `appName` and `appVersion`. All six constants are missing.

The design also ignores the existing `StorageKeys` class (`auth_token`, `auth_refresh_token`, `auth_user`) which already serves the storage-key purpose. The design's `LocalStorage` interface uses `saveToken/getToken/saveRefreshToken/getRefreshToken/clearTokens` while the existing `LocalStorage` abstract class uses `setString/getString/remove/clear` — these are incompatible signatures.

**Concrete fix:** Either extend `AppConstants` with the missing constants (with their numeric values specified), or reference `StorageKeys` for the token keys and define a separate constants file for grade thresholds. The numeric values for `kidsMaxGrade` and `middleMaxGrade` must be specified. The `LocalStorage` interface conflict must be resolved: either the existing interface is extended, or the design must explicitly state it is replaced.

---

### Finding 6 — HIGH: `ApiEndpoints` is missing endpoints the design relies on

**Where:** Section 2.3 (Network), Sections 7–16.

**Problem:** The actual `ApiEndpoints` contains only: `login`, `logout`, `refreshToken`, `subjects`, `kgActivities`, `progress`. The design references these endpoints that do not exist:

`dashboard`, `chapters` (or equivalent), `topics`, `lessons`, `lessonDetail`, `reportProgress`, `practiceQuestions`, `submitPracticeAttempt`, `quiz` / `quizDetail`, `submitQuiz`, `mockExamDetail`, `mockExamSubmit`, `progress` (full record), `achievements`, `search`, `notifications`, `markNotificationRead`, `subscription`, `parentLink`.

**Concrete fix:** Add all missing endpoints to `ApiEndpoints` with their URL strings specified in the design. The design must list every endpoint it introduces, not leave them implicit.

---

### Finding 7 — HIGH: The existing `AssetConstants` class conflicts with the design's version and asset directories don't exist

**Where:** Section 2.6 (Constants), `asset_constants.dart`.

**Problem:** The existing `AssetConstants` defines `iconsPath`, `imagesPath`, `kgIllustrationsPath`. The design defines a replacement with `correctAnimation`, `wrongAnimation`, `loadingAnimation`, `emptyAnimation`, `celebrationAnimation`, `logoImage`. These are incompatible class bodies and the design makes no mention of merging them.

Furthermore, the `pubspec.yaml` only declares `assets/icons/` as an asset directory. The design's Lottie animations (`assets/animations/*.json`) and images (`assets/images/logo.png`) are not registered in `pubspec.yaml` and would cause runtime asset-not-found errors.

**Concrete fix:** The design must specify adding `assets/animations/`, `assets/images/`, and any other asset directories to the `flutter.assets` section in `pubspec.yaml`. It must also specify how `AssetConstants` is extended or replaced.

---

### Finding 8 — HIGH: Existing `AppRouter` is at `lib/core/router/app_router.dart`; design puts it at `lib/app/app_router.dart`

**Where:** Section 6 (Navigation), Section 21 (File Map).

**Problem:** The existing router is at `lib/core/router/app_router.dart` and is already imported by `lib/app.dart`. The design creates `lib/app/app_router.dart` as a new file. The design makes no mention of deleting or migrating the existing router, which already has 9 routes (splash, login, register, kgHome, gradeDashboard, subjectDetail, quiz, profile). These routes conflict with or duplicate the design's route tree.

**Concrete fix:** The design must explicitly list all existing router files that are deleted and replaced, and confirm that the existing routes for the grades/KG features are intentionally removed or retained.

---

### Finding 9 — HIGH: The existing `GradeLevel` enum uses named grades (`kg`, `grade6`, `grade8`, `grade12`); the design's `Student.grade` is an `int`

**Where:** Section 3 (Domain Entities — Student), Section 5 (Grade Routing).

**Problem:** The existing auth/user system uses `GradeLevel` enum. The design's `Student` entity has `int grade`. The `DetermineGradeRouteUseCase` branches on integer ranges (`grade <= AppConstants.kidsMaxGrade`). There is no defined mapping from the existing `GradeLevel` enum values to integers, and no migration path from `UserModel` (which the existing backend/mock uses) to the new `Student` entity. If both systems coexist, the `AuthBloc` state will carry a `UserModel` but `GradeRoutingBloc` expects a `Student`.

**Concrete fix:** The design must either (a) replace `GradeLevel` enum with integer grades everywhere and document the migration, or (b) keep the enum in `Student` and change `DetermineGradeRouteUseCase` to accept `GradeLevel` instead of `int`. Whichever path is chosen, the mapping must be specified explicitly.

---

### Finding 10 — MEDIUM: `lib/features/kids/exam/` is noted as missing but the design does not provide its entity definitions

**Where:** Section 12 (Mock Exam), Section 21 (File Map), Section 23.

**Problem:** The design states the `exam/` directory "does not exist and must be created", and that "entities are reused from Quiz". But the file map lists `lib/features/kids/exam/domain/entities/` as a directory with no files inside it. If the domain entities are truly reused from `lib/features/kids/quiz/domain/entities/`, the exam domain layer should import from there — not declare an empty entities directory. The design is ambiguous: either the directory should not appear in the file map, or the design should specify which files are imported vs. copied.

**Concrete fix:** Remove the empty `lib/features/kids/exam/domain/entities/` entry from the file map and add an explicit import note: "MockExam domain uses `Quiz` and `QuizAttempt` from `lib/features/kids/quiz/domain/entities/`."

---

### Finding 11 — MEDIUM: `flutter_bloc ^8.1.6` in the design conflicts with `^9.0.0` already in the project

**Where:** Technology stack table; verified against `pubspec.yaml`.

**Problem:** The installed package is `flutter_bloc: ^9.0.0`, which introduced breaking changes (e.g. `BlocObserver` signature). The design specifies `^8.1.6`. If the implementer pins to `8.1.6` as stated, they downgrade the existing package and break any code already written against 9.x. If they leave 9.0.0, the stated version is wrong.

**Concrete fix:** Update the design's technology stack table to `flutter_bloc: ^9.0.0`. Verify that all BLoC API usage in the design (e.g. `Emitter<S>`, sealed classes) is compatible with 9.x (it is, but the design should not state a different version).

---

### Finding 12 — MEDIUM: The design's `LocalStorage` interface conflicts with the existing one

**Where:** Section 2.4 (Storage), `lib/core/storage/local_storage.dart`.

**Problem:** The design defines:
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

The existing `LocalStorage` defines:
```dart
abstract class LocalStorage {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
```

The method `saveString` in the design vs. `setString` in the existing code is a naming conflict. `SharedPrefsStorage` implements the existing interface; it will not compile against the new one without changes. The `saveToken`, `saveRefreshToken`, `getToken`, `getRefreshToken`, `clearTokens` methods are new.

**Concrete fix:** Either (a) extend the existing `LocalStorage` with the token-specific methods and rename `saveString` → `setString` consistently, or (b) explicitly state the interface is replaced and that `SharedPrefsStorage` is updated to match. The design must pick one and document it.

---

### Finding 13 — MEDIUM: `login_page.dart` uses `username` field, but existing `UserModel` and `AuthService` use `email`

**Where:** Section 4 (Authentication), Login Page; Section 4 Data Layer (`AuthRemoteDataSource.login(String username, String password)`).

**Problem:** The existing `AuthService.login` signature is `login({required String email, required String password})`. The existing `UserModel` has `email`, not `username`. The existing `LoginRequested` event has `email` and `password`. The design introduces a `username`-based login (`LoginParams(String username, String password)`, form field labelled "username"). These are incompatible. Either the backend uses email or username — the design does not explain the change and the existing code uses email.

**Concrete fix:** Decide which field the login uses (email or username) and make it consistent across `AuthRemoteDataSource`, `LoginParams`, `Student`, `UserModel`, and the login form. State the rationale.

---

### Finding 14 — MEDIUM: `ContentExplorerPage` single-page drill-down with URL updates is architecturally ambiguous

**Where:** Section 8 (Learning), UI subsection.

**Problem:** The design says "a single `ContentExplorerPage` handles all three levels, re-dispatching the appropriate event when the user taps down. The URL updates via `context.push` with the new path." But the route tree (Section 6) lists separate routes for `/kids/learn/subject/:subjectId`, `/kids/learn/chapter/:chapterId`, `/kids/learn/topic/:topicId`. If `context.push` navigates to a new route, each new route will attempt to create a new `ContentExplorerPage` instance (and possibly a new `ContentExplorerBloc`). The statement "the `BlocProvider` higher up keeps the `ContentExplorerBloc` alive across these pushes within the same tab branch" is only true if the parent route provides the BLoC — but the route `builder` for each child route is not defined. If each route has its own `builder`, the BLoC will be re-created at each level.

**Concrete fix:** Either (a) explicitly define what the `builder` is for each sub-route (does it reuse the parent BLoC via `BlocProvider.value`?), or (b) replace the three sub-routes with a single route and use navigator `push` within the page widget instead of `context.push`. Choose one pattern and specify it precisely.

---

### Finding 15 — MEDIUM: `DashboardData` is defined as a "domain value object in the dashboard domain" but `Subject`, `Lesson`, `Achievement` entities live in different feature directories

**Where:** Section 3 (Domain Entities — DashboardData), Section 7 (Dashboard).

**Problem:** `DashboardData` contains `List<Subject> subjects`, `Lesson? continueLesson`, `List<Achievement> recentAchievements`. `Subject` is in `lib/features/kids/learning/`, `Achievement` is in `lib/features/kids/progress/`, but `DashboardData` is in `lib/features/kids/dashboard/`. This creates cross-feature domain imports, which violates Clean Architecture layering conventions and makes test isolation harder. The design does not address these cross-feature imports or explain how they are managed.

**Concrete fix:** Either (a) move shared entities (`Subject`, `Achievement`) to a `lib/features/kids/shared/domain/entities/` directory and import from there, or (b) explicitly acknowledge and permit the cross-feature domain imports and document the dependency direction.

---

### Finding 16 — MEDIUM: `ProgressBloc` uses `Future.wait` over two use-cases but the error case is underspecified

**Where:** Section 13 (Progress), BLoC.

**Problem:** The design says "if either fails → emit `ProgressFailure(failure.message)`". `Future.wait` throws on the first failed `Future` and the other may or may not complete. The design does not specify:
- Which failure's message is used when both fail simultaneously.
- Whether the second use-case is cancelled when the first throws.
- What happens if `fetchProgress()` succeeds but `fetchAchievements()` fails — should the progress data be shown without achievements or should the whole page fail?

**Concrete fix:** Replace `Future.wait` with sequential awaits and specify the error policy: "if `fetchProgress` fails, emit `ProgressFailure` immediately; if `fetchProgress` succeeds but `fetchAchievements` fails, emit `ProgressSuccess` with an empty achievements list."

---

### Finding 17 — MEDIUM: `QuizBloc` timer uses `Stream.periodic` stored as a `StreamSubscription` but `close()` cancellation is not thread-safe

**Where:** Section 11 (Quiz), BLoC.

**Problem:** The timer is created inside the `QuizLoadRequested` handler with `Stream.periodic(...).take(...)`. If the user navigates away mid-quiz, `close()` is called which cancels `_timerSub`. However, if a tick event fires between the BLoC being closed and the subscription being cancelled, `add(QuizTimerTicked(...))` will throw `StateError: Cannot add events after the BLoC has been closed`. The design does not address this race.

**Concrete fix:** Wrap `add(...)` inside the timer listener with a guard: `if (!isClosed) add(QuizTimerTicked(tick))`.

---

### Finding 18 — MEDIUM: `PracticeBloc` uses `Future.delayed` to auto-advance but does not cancel the timer on `close()` or `PracticeRetried`

**Where:** Section 10 (Practice), BLoC.

**Problem:** `Future.delayed(Duration(milliseconds: 1500), () => add(NextQuestionAdvanced()))` is not cancellable. If `close()` is called before the 1.5 s elapses, or if `PracticeRetried` resets state before the delay fires, `add(NextQuestionAdvanced())` is called on a closed or reset BLoC, which either throws or incorrectly advances the new attempt.

**Concrete fix:** Replace `Future.delayed` with a `Timer` field (like the `SearchBloc` debounce pattern already in the design). Store it as `Timer? _showResultTimer`, cancel it in `close()` and at the start of `PracticeRetried`.

---

### Finding 19 — MEDIUM: The design's `app.dart` defines `KutaKidsApp` but the existing file defines `KutaApp`

**Where:** Section 1 (Entry Point), `lib/app/app.dart`; verified against `lib/app.dart`.

**Problem:** The existing application root is `KutaApp` in `lib/app.dart`. The design creates `KutaKidsApp` in `lib/app/app.dart`. The existing `main.dart` calls `runApp(const KutaApp())`. The design's new `main.dart` calls `runApp(const KutaKidsApp())`. The design does not say whether `lib/app.dart` is deleted or kept.

**Concrete fix:** State explicitly that `lib/app.dart` is deleted and replaced by `lib/app/app.dart`. List `lib/app.dart` as a file to be removed in Section 21.

---

### Finding 20 — MEDIUM: `SearchBloc` internal `_SearchExecuted` event is not visible to tests despite the design's claim

**Where:** Section 14 (Search), BLoC debounce.

**Problem:** The design says "`_SearchExecuted` can be added directly in tests without worrying about the timer." But `_SearchExecuted` is a private class (leading underscore). Dart privacy is library-scoped; tests in `test/` are in a different library and cannot instantiate `_SearchExecuted` directly. The debounce timer therefore cannot be bypassed in tests by adding the private event.

**Concrete fix:** Either (a) make `SearchExecuted` a package-private internal event (no underscore prefix, documented as internal) and note in the test file that it is an implementation detail, or (b) use `fake_async` / `fakeAsync` from `fake_async` package in tests to advance the clock without bypassing the timer at all. The design should specify which approach is used.

---

### Finding 21 — MEDIUM: `route_guard.dart` redirect rule 3 calls `DetermineGradeRouteUseCase(student.grade)` but `student` is `Student` while the router only has access to `AuthBloc`

**Where:** Section 6 (Navigation), `route_guard.dart`.

**Problem:** The redirect callback is a pure function that receives `GoRouterState`. It reads `authState` (from the `AuthBloc` refreshListenable). When `authState is AuthAuthenticated`, the design accesses `state.student.grade` and passes it to `DetermineGradeRouteUseCase`. But `DetermineGradeRouteUseCase` is not a singleton that the redirect closure can access without being injected. The design does not specify how the redirect closure obtains the use-case instance — it is not in scope for a static `redirect` function.

**Concrete fix:** Inject `DetermineGradeRouteUseCase` into `AppRouter`'s constructor alongside `AuthBloc`, or resolve it from `sl` (GetIt) inside the redirect callback and explicitly document that pattern.

---

### Finding 22 — NIT: `LoadingIndicator` fallback logic — "if `assets/animations/loading.json` exists" — cannot be checked at runtime in Flutter

**Where:** Section 2.5 (Shared Widgets), `loading_indicator.dart`.

**Problem:** The design says the widget "uses a Lottie animation if `assets/animations/loading.json` exists, otherwise falls back to `CircularProgressIndicator`". Flutter asset existence cannot be checked at runtime without an async `rootBundle.load` call wrapped in a try-catch. A synchronous conditional is not possible. The design does not specify how this branching is implemented.

**Concrete fix:** Replace with a compile-time decision: either always use Lottie (and require the asset to be present) or always use `CircularProgressIndicator`. If a fallback is genuinely needed, document the `rootBundle.load` pattern with a `FutureBuilder`.

---

### Finding 23 — NIT: `PopScope` vs `WillPopScope` version qualifier is ambiguous

**Where:** Section 8 (Learning), `lesson_viewer_page.dart`.

**Problem:** The design says "On `WillPopScope` (or `PopScope` in Flutter 3.16+)". Flutter 3.16 has been released; `WillPopScope` is deprecated. The implementer should use `PopScope` only.

**Concrete fix:** Remove the `WillPopScope` mention entirely. Specify `PopScope(canPop: false, onPopInvokedWithResult: ...)`.

---

### Finding 24 — NIT: PDF viewer downloads to `Directory.systemTemp` without cleanup

**Where:** Section 8 (Learning), `pdf_viewer_widget.dart`.

**Problem:** The design downloads PDFs to `Directory.systemTemp` but never mentions deleting the temp file after the viewer is closed. On repeated viewings of the same lesson, a new file is created each time.

**Concrete fix:** In `dispose()`, delete the temp file if it was created locally: `await _tempFile?.delete()`.

---

### Finding 25 — NIT: `NotificationType` enum name `notification` conflicts with Dart's `Notification` class

**Where:** Section 3 (Domain Entities — Notification).

**Problem:** The entity is named `Notification`, which shadows `dart:core`'s `Notification` class (used internally by Flutter's notification system). This will require import prefixing in any file that imports both.

**Concrete fix:** Rename the entity to `AppNotification` and update all references.

---

## Verified Assumptions

The following design claims were verified against the actual source code:

1. **`ApiEndpoints.baseUrl = 'https://api.kuta.app/v1'`** — ✅ Verified in `lib/core/constants/api_endpoints.dart`.
2. **`ApiEndpoints.login = '/auth/login'`** — ✅ Verified.
3. **`ApiEndpoints.refreshToken = '/auth/refresh'`** — ✅ Verified.
4. **`ApiEndpoints.subjects = '/curriculum/subjects'`** — ✅ Verified.
5. **`lib/core/constants/api_endpoints.dart` exists** — ✅ Verified.
6. **`lib/core/constants/app_constants.dart` exists** — ✅ Verified.
7. **`go_router` and `dio` and `shared_preferences` are in `pubspec.yaml`** — ✅ Verified (though at different versions than stated).
8. **`flutter_bloc` is in `pubspec.yaml`** — ✅ Verified (at version `^9.0.0`).
9. **`analysis_options.yaml` extends `package:flutter_lints/flutter.yaml`** — ✅ Confirmed (implied by `flutter_lints: ^6.0.0` in dev deps).
10. **`lib/main.dart` exists** — ✅ Verified (though its content is not the default counter app).

---

## Unverified / Wrong Assumptions

1. **WRONG — "only `lib/main.dart` (the default counter app), `lib/core/errors/exceptions.dart`, `lib/core/constants/api_endpoints.dart`, and `lib/core/constants/app_constants.dart` contain any code; all feature directories exist but are empty"** — The actual project has 17+ files in `lib/core/` and full features in `lib/features/` (authentication, grades, KG, profile, common). This is the most dangerous wrong assumption in the design.

2. **WRONG — `lib/core/errors/exceptions.dart` exists** — No such file exists in the actual codebase. The design treats it as pre-existing but it is absent.

3. **WRONG — All required packages are already in `pubspec.yaml`** — 11 of 16 required packages are missing. `equatable`, `dartz`, `get_it`, `lottie`, `flutter_animate`, `cached_network_image`, `video_player`, `chewie`, `flutter_pdfview`, `just_audio`, and `intl` are all absent.

4. **WRONG — `flutter_bloc ^8.1.6`** — Actual version is `^9.0.0`.

5. **WRONG — `go_router ^14.2.7`** — Actual version is `^14.6.3`.

6. **WRONG — `shared_preferences ^2.3.2`** — Actual version is `^2.3.3`.

7. **WRONG — `AppConstants` contains token keys, grade thresholds, quiz timer threshold** — `AppConstants` contains only `appName` and `appVersion`.

8. **WRONG — `LocalStorage` interface has `saveToken/getToken/saveRefreshToken/getRefreshToken/clearTokens/saveString` methods** — The existing interface has `setString/getString/remove/clear`.

9. **WRONG — The existing `AssetConstants` matches the design's definition** — Actual `AssetConstants` only defines path prefixes (`iconsPath`, `imagesPath`, `kgIllustrationsPath`), not the animation/image constants the design specifies.

10. **WRONG — The existing router is empty / a scaffold** — The existing `AppRouter` in `lib/core/router/app_router.dart` has 9 defined routes, a different file path, and a different class structure than what the design proposes.

11. **UNVERIFIED — `lib/core/errors/exceptions.dart` has six exception types** — The file does not exist; cannot be verified.

12. **UNVERIFIED — Any claim prefixed with "per NFR-6" or "per requirements"** — `01-requirements.md` does not exist.

---

## Verdict Summary

| Severity | Count |
|---|---|
| HIGH | 9 |
| MEDIUM | 12 |
| NIT | 4 |

**VERDICT: CHANGES_REQUESTED**

The design cannot proceed to implementation. The critical blockers are: the requirements document is missing (Finding 1), the design fundamentally misrepresents the existing codebase (Finding 3), 11 required packages are absent from `pubspec.yaml` (Finding 2), and the existing `AuthBloc`/`UserModel`/`GradeLevel`/`ApiEndpoints`/`LocalStorage`/`AppConstants`/`AssetConstants`/`AppRouter` all conflict with the design's definitions (Findings 4–8, 12–13, 19). None of these are implementation-detail questions — they are foundation-level conflicts that will make every file the implementer writes incorrect before the first line is compiled.
