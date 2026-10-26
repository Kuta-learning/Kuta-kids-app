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
  const LearningLoaded(this.course);
}

class LearningError extends LearningState {
  final String message;
  const LearningError(this.message);
}
