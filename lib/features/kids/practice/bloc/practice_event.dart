abstract class PracticeEvent {
  const PracticeEvent();
}

/// Request the list of practice topics from the API.
class PracticeTopicsRequested extends PracticeEvent {
  const PracticeTopicsRequested();
}

/// Start a quiz session for the given topic id.
class PracticeTopicStarted extends PracticeEvent {
  final String topicId;
  const PracticeTopicStarted(this.topicId);
}
