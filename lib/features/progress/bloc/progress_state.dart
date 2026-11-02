import '../data/progress_repository.dart';

abstract class ProgressState {
  const ProgressState();
}

class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

class ProgressLoaded extends ProgressState {
  final List<CourseProgressEntry> entries;
  const ProgressLoaded(this.entries);
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
}
