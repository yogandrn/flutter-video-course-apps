import 'package:course/apps/course/data/models/course_model.dart';
import 'package:course/apps/course/data/models/courses_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/course_fixtures.dart';

void main() {
  group('CourseModel.fromJson', () {
    test('parses basic fields', () {
      final c = CourseModel.fromJson(
        courseJson(129, title: 'Flutter', rating: 4.277),
      );
      expect(c.id, 129);
      expect(c.title, 'Flutter');
      expect(c.rating, 4.277);
      expect(c.createdAt, DateTime(2026, 5, 1, 10));
      expect(c.deletedAt, isNull);
    });

    test('rating accepts an int from JSON', () {
      final json = courseJson(1)..['rating'] = 4;
      expect(CourseModel.fromJson(json).rating, 4.0);
    });

    test('is_accessable true is parsed', () {
      expect(
        CourseModel.fromJson(courseJson(1, isAccessable: true)).isAccessable,
        isTrue,
      );
    });

    test('is_accessable missing defaults to locked (false)', () {
      final json = courseJson(1)..remove('is_accessable');
      expect(CourseModel.fromJson(json).isAccessable, isFalse);
    });

    test('deleted_at is parsed when present', () {
      final c = CourseModel.fromJson(
        courseJson(1, deletedAt: '2026-05-10 10:00:00'),
      );
      expect(c.deletedAt, DateTime(2026, 5, 10, 10));
    });

    test('missing course_sections gives empty list', () {
      final json = courseJson(1)..remove('course_sections');
      expect(CourseModel.fromJson(json).sections, isEmpty);
    });

    test('drops soft-deleted sections and lessons', () {
      final c = CourseModel.fromJson(
        courseJson(
          1,
          sections: [
            sectionJson(
              10,
              1,
              lessons: [
                lessonJson(100, 10),
                lessonJson(101, 10, deletedAt: '2026-05-02 10:00:00'),
              ],
            ),
            sectionJson(
              11,
              1,
              lessons: [lessonJson(103, 11)],
              deletedAt: '2026-05-02 10:00:00',
            ),
            sectionJson(12, 1, lessons: [lessonJson(102, 12)]),
          ],
        ),
      );
      expect(c.sections.map((s) => s.id), [10, 12]);
      expect(c.sections.first.lessons.map((l) => l.id), [100]);
    });

    test('lessonCount sums lessons across sections', () {
      final c = CourseModel.fromJson(
        courseJson(
          1,
          sections: [
            sectionJson(
              10,
              1,
              lessons: [lessonJson(100, 10), lessonJson(101, 10)],
            ),
            sectionJson(12, 1, lessons: [lessonJson(102, 12)]),
          ],
        ),
      );
      expect(c.lessonCount, 3);
    });

    test('equality uses id + updatedAt only', () {
      expect(makeCourse(1), makeCourse(1, title: 'Other title'));
      expect(makeCourse(1), isNot(makeCourse(2)));
      expect(
        makeCourse(1),
        isNot(makeCourse(1, createdAt: '2026-06-01 10:00:00')),
      );
    });
  });

  group('PaginationMeta.hasMore', () {
    test('true when more items remain', () {
      const m = PaginationMeta(page: 4, limit: 20, offset: 60, total: 97);
      expect(m.hasMore, isTrue);
    });

    test('false on the last page', () {
      const m = PaginationMeta(page: 5, limit: 20, offset: 80, total: 97);
      expect(m.hasMore, isFalse);
    });
  });

  test('CoursesResponse.fromJson parses envelope', () {
    final r = CoursesResponse.fromJson({
      'message': 'ok',
      'data': [courseJson(1), courseJson(2)],
      'meta': {'page': 1, 'limit': 20, 'offset': 0, 'total': 2},
    });
    expect(r.data.map((c) => c.id), [1, 2]);
    expect(r.meta.total, 2);
  });
}
