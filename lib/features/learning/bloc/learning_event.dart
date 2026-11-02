abstract class LearningEvent {
  const LearningEvent();
}

class CourseDetailRequested extends LearningEvent {
  final String courseId;
  const CourseDetailRequested(this.courseId);
}

class CourseLessonCompleted extends LearningEvent {
  final String lessonId;
  const CourseLessonCompleted(this.lessonId);
}
