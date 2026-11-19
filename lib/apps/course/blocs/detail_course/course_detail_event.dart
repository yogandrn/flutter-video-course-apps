// apps/course/blocs/detail_course/course_detail_event.dart
part of 'course_detail_bloc.dart';

sealed class CourseDetailEvent {
  const CourseDetailEvent();
}

final class CourseDetailFetched extends CourseDetailEvent {
  const CourseDetailFetched(this.id);
  final int id;
}

final class CourseDetailRefreshed extends CourseDetailEvent {
  const CourseDetailRefreshed(this.id, this.done);
  final int id;
  final Completer<void> done;
}
