// apps/course/blocs/detail_course/course_detail_state.dart
part of 'course_detail_bloc.dart';

class CourseDetailState extends Equatable {
  const CourseDetailState({
    this.status = ViewStatus.initial,
    this.course,
    this.error = '',
  });

  final ViewStatus status;
  final CourseModel? course;
  final String error;

  CourseDetailState copyWith({
    ViewStatus? status,
    CourseModel? course,
    String? error,
  }) => CourseDetailState(
    status: status ?? this.status,
    course: course ?? this.course,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [status, course, error];
}
