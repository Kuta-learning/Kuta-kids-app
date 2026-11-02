import '../models/chapter_model.dart';

abstract class LearningState {
  const LearningState();
}

class LearningInitial extends LearningState {
  const LearningInitial();
}

class LearningLoading extends LearningState {
  const LearningLoading();
}

class LearningLoaded extends LearningState {
  final CourseDetailModel course;
  final CourseProgress? progress;
  const LearningLoaded(this.course, [this.progress]);
}

class LearningError extends LearningState {
  final String message;
  const LearningError(this.message);
}
