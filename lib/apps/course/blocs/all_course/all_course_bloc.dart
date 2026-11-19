// apps/course/blocs/all_course/all_course_bloc.dart
import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cores/constant/app_constants.dart';
import '../../../../cores/constant/app_view_status.dart';
import '../../../../cores/extensions/ext_string.dart';
import '../../../../cores/network/api_client.dart';
import '../../data/models/course_model.dart';
import '../../data/repository/course_repository.dart';

part 'all_course_event.dart';
part 'all_course_state.dart';

class AllCourseBloc extends Bloc<AllCourseEvent, AllCourseState> {
  AllCourseBloc(this._repo) : super(const AllCourseState()) {
    on<AllCourseFetched>(
      (_, emit) => _load(state.query, emit),
      transformer: restartable(),
    );
    on<AllCourseSearchChanged>(_onSearchChanged, transformer: restartable());
    on<AllCourseNextPageRequested>(_onNextPage, transformer: droppable());
    on<AllCourseRefreshed>(_onRefreshed);
  }

  final CourseRepository _repo;

  Future<void> _load(String query, Emitter<AllCourseState> emit) async {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        query: query,
        courses: const [],
        isLoadingMore: false,
        loadMoreFailed: false,
      ),
    );
    try {
      final res = await _repo.getCourses(query: query);
      emit(
        state.copyWith(
          status: ViewStatus.success,
          courses: res.data,
          page: 1,
          hasMore: res.meta.hasMore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          error: ApiException.messageOf(e),
        ),
      );
    }
  }

  Future<void> _onSearchChanged(
    AllCourseSearchChanged event,
    Emitter<AllCourseState> emit,
  ) async {
    final q = event.query.trim();
    if (q.isNotEmpty && !q.isSearchable)
      return; // under 3 chars: keep current results
    // restartable cancels this handler when a newer keystroke arrives, so this is the debounce.
    await Future<void>.delayed(AppConstants.searchDebounce);
    if (emit.isDone || q == state.query) return;
    await _load(q, emit);
  }

  Future<void> _onNextPage(
    AllCourseNextPageRequested event,
    Emitter<AllCourseState> emit,
  ) async {
    if (state.status != ViewStatus.success || !state.hasMore) return;
    final q = state.query;
    final next = state.page + 1;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final res = await _repo.getCourses(page: next, query: q);
      // shortcut: fake latency, the local cache answers instantly. Delete with a real API.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (emit.isDone || q != state.query) return;
      emit(
        state.copyWith(
          courses: [...state.courses, ...res.data],
          page: next,
          hasMore: res.meta.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (emit.isDone || q != state.query) return;
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }

  Future<void> _onRefreshed(
    AllCourseRefreshed event,
    Emitter<AllCourseState> emit,
  ) async {
    if (state.status == ViewStatus.loading) {
      event.done.complete(); // a full reload is already running
      return;
    }
    _repo.invalidate();
    try {
      await _load(
        state.query,
        emit,
      ); // same path as search: loading -> success/failure
    } finally {
      event.done.complete();
    }
  }
}
