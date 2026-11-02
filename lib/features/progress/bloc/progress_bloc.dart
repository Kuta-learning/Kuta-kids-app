import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/progress_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository _repository;

  ProgressBloc(this._repository) : super(const ProgressInitial()) {
    on<ProgressRequested>(_onProgressRequested);
  }

  Future<void> _onProgressRequested(
    ProgressRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(const ProgressLoading());
    try {
      final entries = await _repository.getCourseProgressList();
      emit(ProgressLoaded(entries));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}
