import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:course/apps/home/blocs/home_bloc.dart';
import 'package:course/cores/constant/app_view_status.dart';
import 'package:course/cores/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/course_fixtures.dart';

void main() {
  late MockCourseRepository repo;
  final recent = [makeCourse(2)];
  final top = [makeCourse(1)];

  setUp(() => repo = MockCourseRepository());

  void stubOk() {
    when(() => repo.getRecent()).thenAnswer((_) async => recent);
    when(() => repo.getTopRated()).thenAnswer((_) async => top);
  }

  blocTest<HomeBloc, HomeState>(
    'fetch: loading then success',
    setUp: stubOk,
    build: () => HomeBloc(repo),
    act: (b) => b.add(const HomeFetched()),
    expect: () => [
      const HomeState(status: ViewStatus.loading),
      HomeState(status: ViewStatus.success, recent: recent, topRated: top),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'fetch: ApiException message goes to state',
    setUp: () {
      when(
        () => repo.getRecent(),
      ).thenAnswer((_) async => throw ApiException('No internet connection.'));
      when(() => repo.getTopRated()).thenAnswer((_) async => top);
    },
    build: () => HomeBloc(repo),
    act: (b) => b.add(const HomeFetched()),
    expect: () => [
      const HomeState(status: ViewStatus.loading),
      const HomeState(
        status: ViewStatus.failure,
        error: 'No internet connection.',
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'fetch: unknown error gets a generic message',
    setUp: () {
      when(
        () => repo.getRecent(),
      ).thenAnswer((_) async => throw Exception('boom'));
      when(() => repo.getTopRated()).thenAnswer((_) async => top);
    },
    build: () => HomeBloc(repo),
    act: (b) => b.add(const HomeFetched()),
    expect: () => [
      const HomeState(status: ViewStatus.loading),
      const HomeState(
        status: ViewStatus.failure,
        error: 'Something went wrong.',
      ),
    ],
  );

  final refreshOk = Completer<void>();
  blocTest<HomeBloc, HomeState>(
    'refresh: invalidates cache, shows loading again, completes',
    setUp: stubOk,
    build: () => HomeBloc(repo),
    act: (b) => b.add(HomeRefreshed(refreshOk)),
    expect: () => [
      const HomeState(status: ViewStatus.loading),
      HomeState(status: ViewStatus.success, recent: recent, topRated: top),
    ],
    verify: (_) {
      verify(() => repo.invalidate()).called(1);
      expect(refreshOk.isCompleted, isTrue);
    },
  );

  final refreshFail = Completer<void>();
  blocTest<HomeBloc, HomeState>(
    'refresh: completes even when reload fails',
    setUp: () {
      when(
        () => repo.getRecent(),
      ).thenAnswer((_) async => throw ApiException('Server error (500).'));
      when(() => repo.getTopRated()).thenAnswer((_) async => top);
    },
    build: () => HomeBloc(repo),
    act: (b) => b.add(HomeRefreshed(refreshFail)),
    expect: () => [
      const HomeState(status: ViewStatus.loading),
      const HomeState(status: ViewStatus.failure, error: 'Server error (500).'),
    ],
    verify: (_) => expect(refreshFail.isCompleted, isTrue),
  );
}
