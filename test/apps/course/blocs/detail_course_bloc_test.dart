import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:course/apps/course/blocs/detail_course/course_detail_bloc.dart';
import 'package:course/cores/constant/app_view_status.dart';
import 'package:course/cores/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/course_fixtures.dart';

void main() {
  late MockCourseRepository repo;
  final course = makeCourse(1);

  setUp(() => repo = MockCourseRepository());

  blocTest<CourseDetailBloc, CourseDetailState>(
    'fetch: loading then success',
    setUp: () =>
        when(() => repo.getCourseDetail(1)).thenAnswer((_) async => course),
    build: () => CourseDetailBloc(repo),
    act: (b) => b.add(const CourseDetailFetched(1)),
    expect: () => [
      const CourseDetailState(status: ViewStatus.loading),
      CourseDetailState(status: ViewStatus.success, course: course),
    ],
  );

  blocTest<CourseDetailBloc, CourseDetailState>(
    'fetch: not found becomes failure with the message',
    setUp: () => when(() => repo.getCourseDetail(99)).thenAnswer(
      (_) async => throw ApiException('Course not found.', statusCode: 404),
    ),
    build: () => CourseDetailBloc(repo),
    act: (b) => b.add(const CourseDetailFetched(99)),
    expect: () => [
      const CourseDetailState(status: ViewStatus.loading),
      const CourseDetailState(
        status: ViewStatus.failure,
        error: 'Course not found.',
      ),
    ],
  );

  final ok = Completer<void>();
  blocTest<CourseDetailBloc, CourseDetailState>(
    'refresh: keeps old course while loading, then swaps in the new one',
    setUp: () => when(
      () => repo.getCourseDetail(1),
    ).thenAnswer((_) async => makeCourse(1, title: 'Updated')),
    build: () => CourseDetailBloc(repo),
    seed: () => CourseDetailState(status: ViewStatus.success, course: course),
    act: (b) => b.add(CourseDetailRefreshed(1, ok)),
    expect: () => [
      CourseDetailState(status: ViewStatus.loading, course: course),
      isA<CourseDetailState>().having(
        (s) => s.status,
        'status',
        ViewStatus.success,
      ),
    ],
    verify: (b) {
      verify(() => repo.invalidate()).called(1);
      expect(
        b.state.course!.title,
        'Updated',
      ); // equality ignores title, so check it directly
      expect(ok.isCompleted, isTrue);
    },
  );

  final fail = Completer<void>();
  blocTest<CourseDetailBloc, CourseDetailState>(
    'refresh: completes even when reload fails',
    setUp: () => when(
      () => repo.getCourseDetail(1),
    ).thenAnswer((_) async => throw ApiException('Server error (500).')),
    build: () => CourseDetailBloc(repo),
    seed: () => CourseDetailState(status: ViewStatus.success, course: course),
    act: (b) => b.add(CourseDetailRefreshed(1, fail)),
    expect: () => [
      CourseDetailState(status: ViewStatus.loading, course: course),
      CourseDetailState(
        status: ViewStatus.failure,
        course: course,
        error: 'Server error (500).',
      ),
    ],
    verify: (_) => expect(fail.isCompleted, isTrue),
  );

  final skipped = Completer<void>();
  blocTest<CourseDetailBloc, CourseDetailState>(
    'refresh: skipped while the first load is running',
    build: () => CourseDetailBloc(repo),
    seed: () => const CourseDetailState(status: ViewStatus.loading),
    act: (b) => b.add(CourseDetailRefreshed(1, skipped)),
    expect: () => <CourseDetailState>[],
    verify: (_) {
      verifyNever(() => repo.invalidate());
      expect(skipped.isCompleted, isTrue);
    },
  );
}
