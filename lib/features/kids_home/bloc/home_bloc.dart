import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc(this._repository) : super(const HomeInitial()) {
    on<HomeRequested>(_onHomeRequested);
  }

  Future<void> _onHomeRequested(
    HomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final courses = await _repository.getCourses();
      emit(HomeLoaded(courses));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
