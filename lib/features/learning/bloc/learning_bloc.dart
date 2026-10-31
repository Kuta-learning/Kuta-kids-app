import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/learning_repository.dart';
import 'learning_event.dart';
import 'learning_state.dart';

class LearningBloc extends Bloc<LearningEvent, LearningState> {
  final LearningRepository _repository;

  /// Last opened course id, remembered so a completion can refresh its detail.
  String? _courseId;

  LearningBloc(this._repository) : super(const LearningInitial()) {
    on<CourseDetailRequested>(_onCourseDetailRequested);
    on<CourseLessonCompleted>(_onLessonCompleted);
  }

  Future<void> _onCourseDetailRequested(
    CourseDetailRequested event,
    Emitter<LearningState> emit,
  ) async {
    _courseId = event.courseId;
    emit(const LearningLoading());
    try {
      final course = await _repository.getCourseDetail(event.courseId);
      final progress = await _repository.getCourseProgress(event.courseId);
      emit(LearningLoaded(course, progress));
    } catch (e) {
      emit(LearningError(e.toString()));
    }
  }

  Future<void> _onLessonCompleted(
    CourseLessonCompleted event,
    Emitter<LearningState> emit,
  ) async {
    await _repository.completeLesson(event.lessonId);
    // Re-fetch the course detail + progress so the UI reflects completion.
    if (_courseId != null) {
      add(CourseDetailRequested(_courseId!));
    }
  }
}
