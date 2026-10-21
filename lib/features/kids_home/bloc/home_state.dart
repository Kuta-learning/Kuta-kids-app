import '../models/course_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<CourseModel> courses;

  const HomeLoaded(this.courses);
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
