// apps/home/blocs/home_bloc.dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cores/network/api_client.dart';
import '../../../cores/constant/app_view_status.dart';
import '../../course/data/models/course_model.dart';
import '../../course/data/repository/course_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repo) : super(const HomeState()) {
    on<HomeFetched>(_onFetched);
    on<HomeRefreshed>(_onRefreshed);
  }

  final CourseRepository _repo;

  Future<void> _onFetched(HomeFetched event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final r = await Future.wait([_repo.getRecent(), _repo.getTopRated()]);
      emit(
        state.copyWith(
          status: ViewStatus.success,
          recent: r[0],
          topRated: r[1],
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

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    _repo.invalidate();
    try {
      await _onFetched(
        const HomeFetched(),
        emit,
      ); // loading (shimmer) -> success/failure
    } finally {
      event.done.complete();
    }
  }
}
