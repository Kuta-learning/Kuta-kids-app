abstract class ProgressEvent {
  const ProgressEvent();
}

/// Request the list of course progress entries.
class ProgressRequested extends ProgressEvent {
  const ProgressRequested();
}
