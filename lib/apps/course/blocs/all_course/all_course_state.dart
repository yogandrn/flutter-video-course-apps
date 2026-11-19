// apps/course/blocs/all_course/all_course_state.dart
part of 'all_course_bloc.dart';

class AllCourseState extends Equatable {
  const AllCourseState({
    this.status = ViewStatus.initial,
    this.courses = const [],
    this.query = '',
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.error = '',
  });

  final ViewStatus status;
  final List<CourseModel> courses;
  final String query;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final String error;

  AllCourseState copyWith({
    ViewStatus? status,
    List<CourseModel>? courses,
    String? query,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    String? error,
  }) => AllCourseState(
    status: status ?? this.status,
    courses: courses ?? this.courses,
    query: query ?? this.query,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [
    status,
    courses,
    query,
    page,
    hasMore,
    isLoadingMore,
    loadMoreFailed,
    error,
  ];
}
