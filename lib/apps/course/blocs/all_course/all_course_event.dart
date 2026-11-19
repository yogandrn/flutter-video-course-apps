// apps/course/blocs/all_course/all_course_event.dart
part of 'all_course_bloc.dart';

sealed class AllCourseEvent {
  const AllCourseEvent();
}

final class AllCourseFetched extends AllCourseEvent {
  const AllCourseFetched();
}

final class AllCourseNextPageRequested extends AllCourseEvent {
  const AllCourseNextPageRequested();
}

final class AllCourseSearchChanged extends AllCourseEvent {
  const AllCourseSearchChanged(this.query);
  final String query;
}

final class AllCourseRefreshed extends AllCourseEvent {
  const AllCourseRefreshed(this.done);
  final Completer<void> done;
}
