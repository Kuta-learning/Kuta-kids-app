import '../data/models.dart';

abstract class PracticeState {
  const PracticeState();
}

class PracticeInitial extends PracticeState {
  const PracticeInitial();
}

class PracticeLoading extends PracticeState {
  const PracticeLoading();
}

class PracticeLoaded extends PracticeState {
  final List<PracticeTopic> topics;
  const PracticeLoaded(this.topics);
}

class PracticeError extends PracticeState {
  final String message;
  const PracticeError(this.message);
}

/// Emitted when a topic has been started and a quiz session is ready.
class PracticeSessionReady extends PracticeState {
  final String attemptId;
  final List<PracticeQuestion> questions;
  const PracticeSessionReady({
    required this.attemptId,
    required this.questions,
  });
}
