import 'package:course/apps/course/data/repository/course_repository.dart';
import 'package:course/cores/constant/app_constants.dart';
import 'package:course/cores/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/course_fixtures.dart';

void main() {
  late MockApiClient api;
  late CourseRepository repo;

  // file order: 1, 2, (3 deleted), 4
  final data = [
    courseJson(
      1,
      title: 'Flutter Basics',
      rating: 4.1,
      createdAt: '2026-05-01 10:00:00',
    ),
    courseJson(
      2,
      title: 'Dart Advanced',
      rating: 4.9,
      ratingCount: 1,
      createdAt: '2026-05-03 10:00:00',
    ),
    courseJson(
      3,
      title: 'Hidden',
      rating: 5.0,
      deletedAt: '2026-05-10 10:00:00',
    ),
    courseJson(
      4,
      title: 'State Management',
      rating: 4.9,
      ratingCount: 10,
      author: 'Budi',
      createdAt: '2026-05-02 10:00:00',
    ),
  ];

  setUp(() {
    api = MockApiClient();
    repo = CourseRepository(api);
    when(
      () => api.get(AppConstants.coursesEndpoint),
    ).thenAnswer((_) async => data);
  });

  group('getCourses', () {
    test('drops soft-deleted courses', () async {
      final res = await repo.getCourses();
      expect(res.meta.total, 3);
      expect(res.data.map((c) => c.id), [1, 2, 4]);
    });

    test('search matches title, case-insensitive', () async {
      final res = await repo.getCourses(query: 'DART');
      expect(res.data.map((c) => c.id), [2]);
    });

    test('search matches author', () async {
      final res = await repo.getCourses(query: 'budi');
      expect(res.data.map((c) => c.id), [4]);
    });

    test('search with no match gives empty page', () async {
      final res = await repo.getCourses(query: 'zzz');
      expect(res.data, isEmpty);
      expect(res.meta.total, 0);
      expect(res.meta.hasMore, isFalse);
    });

    test('paging slices and reports hasMore', () async {
      final p1 = await repo.getCourses(page: 1, limit: 2);
      final p2 = await repo.getCourses(page: 2, limit: 2);
      expect(p1.data.map((c) => c.id), [1, 2]);
      expect(p1.meta.hasMore, isTrue);
      expect(p2.data.map((c) => c.id), [4]);
      expect(p2.meta.offset, 2);
      expect(p2.meta.hasMore, isFalse);
    });
  });

  group('home lists', () {
    test('getRecent sorts by createdAt desc', () async {
      expect((await repo.getRecent()).map((c) => c.id), [2, 4, 1]);
    });

    test('getRecent respects limit', () async {
      expect((await repo.getRecent(limit: 2)).map((c) => c.id), [2, 4]);
    });

    test(
      'getTopRated sorts by rating desc, ties by ratingCount desc',
      () async {
        expect((await repo.getTopRated()).map((c) => c.id), [4, 2, 1]);
      },
    );
  });

  group('getCourseDetail', () {
    test('finds by id', () async {
      expect((await repo.getCourseDetail(2)).title, 'Dart Advanced');
    });

    test('unknown id throws ApiException 404', () {
      expect(
        repo.getCourseDetail(99),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('soft-deleted id is not found', () {
      expect(repo.getCourseDetail(3), throwsA(isA<ApiException>()));
    });
  });

  group('cache', () {
    test('fetches courses.json once across calls', () async {
      await repo.getCourses();
      await repo.getRecent();
      await repo.getCourseDetail(1);
      verify(() => api.get(AppConstants.coursesEndpoint)).called(1);
    });

    test('invalidate forces a new fetch', () async {
      await repo.getCourses();
      repo.invalidate();
      await repo.getCourses();
      verify(() => api.get(AppConstants.coursesEndpoint)).called(2);
    });

    test('api error propagates and is not cached', () async {
      when(
        () => api.get(AppConstants.coursesEndpoint),
      ).thenAnswer((_) async => throw ApiException('No internet connection.'));
      await expectLater(repo.getCourses(), throwsA(isA<ApiException>()));

      when(
        () => api.get(AppConstants.coursesEndpoint),
      ).thenAnswer((_) async => data);
      expect((await repo.getCourses()).meta.total, 3); // recovers on retry
    });
  });
}
