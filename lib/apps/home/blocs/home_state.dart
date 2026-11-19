// apps/home/blocs/home_state.dart
part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = ViewStatus.initial,
    this.recent = const [],
    this.topRated = const [],
    this.error = '',
  });

  final ViewStatus status;
  final List<CourseModel> recent;
  final List<CourseModel> topRated;
  final String error;

  HomeState copyWith({
    ViewStatus? status,
    List<CourseModel>? recent,
    List<CourseModel>? topRated,
    String? error,
  }) => HomeState(
    status: status ?? this.status,
    recent: recent ?? this.recent,
    topRated: topRated ?? this.topRated,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [status, recent, topRated, error];
}
