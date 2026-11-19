import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:course/apps/course/blocs/all_course/all_course_bloc.dart';
import 'package:course/cores/constant/app_view_status.dart';
import 'package:course/cores/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/course_fixtures.dart';

void main() {
  late MockCourseRepository repo;
  final c1 = makeCourse(1);
  final c2 = makeCourse(2);

  setUp(() => repo = MockCourseRepository());

  group('fetch', () {
    blocTest<AllCourseBloc, AllCourseState>(
      'loading then success, no more pages',
      setUp: () => when(
        () => repo.getCourses(query: ''),
      ).thenAnswer((_) async => pageOf([c1, c2], total: 2)),
      build: () => AllCourseBloc(repo),
      act: (b) => b.add(const AllCourseFetched()),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading),
        AllCourseState(status: ViewStatus.success, courses: [c1, c2]),
      ],
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'hasMore is true when total exceeds the page',
      setUp: () => when(
        () => repo.getCourses(query: ''),
      ).thenAnswer((_) async => pageOf([c1, c2], total: 45)),
      build: () => AllCourseBloc(repo),
      act: (b) => b.add(const AllCourseFetched()),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading),
        AllCourseState(
          status: ViewStatus.success,
          courses: [c1, c2],
          hasMore: true,
        ),
      ],
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'failure carries the error message',
      setUp: () => when(
        () => repo.getCourses(query: ''),
      ).thenAnswer((_) async => throw ApiException('No internet connection.')),
      build: () => AllCourseBloc(repo),
      act: (b) => b.add(const AllCourseFetched()),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading),
        const AllCourseState(
          status: ViewStatus.failure,
          error: 'No internet connection.',
        ),
      ],
    );
  });

  group('search', () {
    blocTest<AllCourseBloc, AllCourseState>(
      'under 3 characters is ignored',
      build: () => AllCourseBloc(repo),
      act: (b) => b.add(const AllCourseSearchChanged('ab')),
      wait: const Duration(milliseconds: 400),
      expect: () => <AllCourseState>[],
      verify: (_) =>
          verifyNever(() => repo.getCourses(query: any(named: 'query'))),
    );

    blocTest<AllCourseBloc, AllCourseState>(
      '3+ characters searches after the debounce',
      setUp: () => when(
        () => repo.getCourses(query: 'flu'),
      ).thenAnswer((_) async => pageOf([c1], total: 1)),
      build: () => AllCourseBloc(repo),
      act: (b) => b.add(const AllCourseSearchChanged('flu')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading, query: 'flu'),
        AllCourseState(status: ViewStatus.success, query: 'flu', courses: [c1]),
      ],
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'fast typing restarts the debounce: only the last query hits the repo',
      setUp: () => when(
        () => repo.getCourses(query: 'flut'),
      ).thenAnswer((_) async => pageOf([c1], total: 1)),
      build: () => AllCourseBloc(repo),
      act: (b) async {
        b.add(const AllCourseSearchChanged('flu'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        b.add(const AllCourseSearchChanged('flut'));
      },
      wait: const Duration(milliseconds: 600),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading, query: 'flut'),
        AllCourseState(
          status: ViewStatus.success,
          query: 'flut',
          courses: [c1],
        ),
      ],
      verify: (_) => verifyNever(() => repo.getCourses(query: 'flu')),
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'clearing the search reloads the full list',
      setUp: () => when(
        () => repo.getCourses(query: ''),
      ).thenAnswer((_) async => pageOf([c1, c2], total: 2)),
      build: () => AllCourseBloc(repo),
      seed: () => AllCourseState(
        status: ViewStatus.success,
        query: 'flu',
        courses: [c1],
      ),
      act: (b) => b.add(const AllCourseSearchChanged('')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading),
        AllCourseState(status: ViewStatus.success, courses: [c1, c2]),
      ],
    );
  });

  group('next page', () {
    blocTest<AllCourseBloc, AllCourseState>(
      'appends the next page and bumps page',
      setUp: () => when(
        () => repo.getCourses(page: 2, query: ''),
      ).thenAnswer((_) async => pageOf([c2], page: 2, total: 21)),
      build: () => AllCourseBloc(repo),
      seed: () => AllCourseState(
        status: ViewStatus.success,
        courses: [c1],
        hasMore: true,
      ),
      act: (b) => b.add(const AllCourseNextPageRequested()),
      wait: const Duration(
        milliseconds: 700,
      ), // > 600ms fake latency in the bloc
      expect: () => [
        AllCourseState(
          status: ViewStatus.success,
          courses: [c1],
          hasMore: true,
          isLoadingMore: true,
        ),
        AllCourseState(status: ViewStatus.success, courses: [c1, c2], page: 2),
      ],
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'failure sets loadMoreFailed and keeps current items',
      setUp: () => when(
        () => repo.getCourses(page: 2, query: ''),
      ).thenAnswer((_) async => throw ApiException('boom')),
      build: () => AllCourseBloc(repo),
      seed: () => AllCourseState(
        status: ViewStatus.success,
        courses: [c1],
        hasMore: true,
      ),
      act: (b) => b.add(const AllCourseNextPageRequested()),
      expect: () => [
        AllCourseState(
          status: ViewStatus.success,
          courses: [c1],
          hasMore: true,
          isLoadingMore: true,
        ),
        AllCourseState(
          status: ViewStatus.success,
          courses: [c1],
          hasMore: true,
          loadMoreFailed: true,
        ),
      ],
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'ignored when there are no more pages',
      build: () => AllCourseBloc(repo),
      seed: () => AllCourseState(status: ViewStatus.success, courses: [c1]),
      act: (b) => b.add(const AllCourseNextPageRequested()),
      expect: () => <AllCourseState>[],
      verify: (_) => verifyNever(
        () => repo.getCourses(
          page: any(named: 'page'),
          query: any(named: 'query'),
        ),
      ),
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'ignored while the initial load has not succeeded',
      build: () => AllCourseBloc(repo),
      seed: () =>
          const AllCourseState(status: ViewStatus.loading, hasMore: true),
      act: (b) => b.add(const AllCourseNextPageRequested()),
      expect: () => <AllCourseState>[],
    );

    blocTest<AllCourseBloc, AllCourseState>(
      'double trigger fetches the page only once',
      setUp: () => when(
        () => repo.getCourses(page: 2, query: ''),
      ).thenAnswer((_) async => pageOf([c2], page: 2, total: 21)),
      build: () => AllCourseBloc(repo),
      seed: () => AllCourseState(
        status: ViewStatus.success,
        courses: [c1],
        hasMore: true,
      ),
      act: (b) {
        b.add(const AllCourseNextPageRequested());
        b.add(const AllCourseNextPageRequested());
      },
      wait: const Duration(milliseconds: 700),
      verify: (_) =>
          verify(() => repo.getCourses(page: 2, query: '')).called(1),
    );
  });

  group('refresh', () {
    final ok = Completer<void>();
    blocTest<AllCourseBloc, AllCourseState>(
      'invalidates, reloads from page 1 and completes',
      setUp: () => when(
        () => repo.getCourses(query: ''),
      ).thenAnswer((_) async => pageOf([c1, c2], total: 2)),
      build: () => AllCourseBloc(repo),
      seed: () => AllCourseState(status: ViewStatus.success, courses: [c1]),
      act: (b) => b.add(AllCourseRefreshed(ok)),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading),
        AllCourseState(status: ViewStatus.success, courses: [c1, c2]),
      ],
      verify: (_) {
        verify(() => repo.invalidate()).called(1);
        expect(ok.isCompleted, isTrue);
      },
    );

    final fail = Completer<void>();
    blocTest<AllCourseBloc, AllCourseState>(
      'completes even when reload fails',
      setUp: () => when(
        () => repo.getCourses(query: ''),
      ).thenAnswer((_) async => throw ApiException('Server error (500).')),
      build: () => AllCourseBloc(repo),
      seed: () => AllCourseState(status: ViewStatus.success, courses: [c1]),
      act: (b) => b.add(AllCourseRefreshed(fail)),
      expect: () => [
        const AllCourseState(status: ViewStatus.loading),
        const AllCourseState(
          status: ViewStatus.failure,
          error: 'Server error (500).',
        ),
      ],
      verify: (_) => expect(fail.isCompleted, isTrue),
    );

    final skipped = Completer<void>();
    blocTest<AllCourseBloc, AllCourseState>(
      'skipped while a load is already running',
      build: () => AllCourseBloc(repo),
      seed: () => const AllCourseState(status: ViewStatus.loading),
      act: (b) => b.add(AllCourseRefreshed(skipped)),
      expect: () => <AllCourseState>[],
      verify: (_) {
        verifyNever(() => repo.invalidate());
        expect(skipped.isCompleted, isTrue);
      },
    );
  });
}
