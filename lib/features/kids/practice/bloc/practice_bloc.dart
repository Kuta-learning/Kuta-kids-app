import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/practice_repository.dart';
import 'practice_event.dart';
import 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final PracticeRepository _repository;

  PracticeBloc(this._repository) : super(const PracticeInitial()) {
    on<PracticeTopicsRequested>(_onTopicsRequested);
    on<PracticeTopicStarted>(_onTopicStarted);
  }

  Future<void> _onTopicsRequested(
    PracticeTopicsRequested event,
    Emitter<PracticeState> emit,
  ) async {
    emit(const PracticeLoading());
    try {
      final topics = await _repository.getTopics();
      emit(PracticeLoaded(topics));
    } catch (e) {
      emit(PracticeError(e.toString()));
    }
  }

  Future<void> _onTopicStarted(
    PracticeTopicStarted event,
    Emitter<PracticeState> emit,
  ) async {
    emit(const PracticeLoading());
    try {
      final session = await _repository.startTopic(event.topicId);
      emit(PracticeSessionReady(
        attemptId: session.attemptId,
        questions: session.questions,
      ));
    } catch (e) {
      emit(PracticeError(e.toString()));
    }
  }
}
