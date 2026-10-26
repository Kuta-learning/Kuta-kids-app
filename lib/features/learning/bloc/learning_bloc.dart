import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/learning_repository.dart';
import 'learning_event.dart';
import 'learning_state.dart';

class LearningBloc extends Bloc<LearningEvent, LearningState> {
  final LearningRepository _repository;

  LearningBloc(this._repository) : super(const LearningInitial()) {
    on<CourseDetailRequested>(_onCourseDetailRequested);
  }

  Future<void> _onCourseDetailRequested(
    CourseDetailRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(const LearningLoading());
    try {
      final course = await _repository.getCourseDetail(event.courseId);
      emit(LearningLoaded(course));
    } catch (e) {
      emit(LearningError(e.toString()));
    }
  }
}
