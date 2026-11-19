// apps/course/blocs/detail_course/course_detail_bloc.dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cores/constant/app_view_status.dart';
import '../../../../cores/network/api_client.dart';
import '../../data/models/course_model.dart';
import '../../data/repository/course_repository.dart';

part 'course_detail_event.dart';
part 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  CourseDetailBloc(this._repo) : super(const CourseDetailState()) {
    on<CourseDetailFetched>(_onFetched);
    on<CourseDetailRefreshed>(_onRefreshed);
  }

  final CourseRepository _repo;

  Future<void> _onFetched(
    CourseDetailFetched event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final course = await _repo.getCourseDetail(event.id);
      emit(state.copyWith(status: ViewStatus.success, course: course));
    } catch (e) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          error: ApiException.messageOf(e),
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    CourseDetailRefreshed event,
    Emitter<CourseDetailState> emit,
  ) async {
    if (state.status == ViewStatus.loading) {
      event.done.complete(); // initial load still running
      return;
    }
    _repo.invalidate();
    try {
      await _onFetched(CourseDetailFetched(event.id), emit);
    } finally {
      event.done.complete();
    }
  }
}
