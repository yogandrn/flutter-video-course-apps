import 'dart:convert';
import 'dart:io';

import 'package:course/apps/course/data/repository/course_repository.dart';
import 'package:course/cores/constant/app_constants.dart';
import 'package:course/cores/extensions/ext_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/course_fixtures.dart';

void main() {
  late CourseRepository repo;

  setUp(() {
    final raw = File('test/fixtures/courses_sample.json').readAsStringSync();
    final api = MockApiClient();
    // jsonDecode here also proves the sample is valid JSON (no trailing commas)
    when(
      () => api.get(AppConstants.coursesEndpoint),
    ).thenAnswer((_) async => jsonDecode(raw));
    repo = CourseRepository(api);
  });

  test('top-level array parses through the repository', () async {
    final res = await repo.getCourses();
    expect(res.meta.total, 2);
    expect(res.data.map((c) => c.id), [129, 130]);
  });

  test('course 129 maps nested sections, lessons, and is_accessable', () async {
    final c = await repo.getCourseDetail(129);
    expect(c.title, 'Flutter dari Nol hingga Siap Rilis');
    expect(c.isAccessable, isTrue);
    expect(c.rating, 4.277);
    expect(c.sections, hasLength(3));
    expect(c.lessonCount, 4);
    expect(c.sections[1].lessons.map((l) => l.id), [457, 458]);
    expect(c.sections.first.lessons.first.assetUrl, endsWith('video-2.mp4'));
  });

  test('course 130 has 4 sections and 9 lessons', () async {
    final c = await repo.getCourseDetail(130);
    expect(c.sections, hasLength(4));
    expect(c.lessonCount, 9);
  });

  test('tags column splits into a list', () async {
    final c = await repo.getCourseDetail(129);
    expect(c.tags.toTags, [
      'mobile',
      'flutter',
      'android',
      'ios',
      'dart',
      'cross-platform',
    ]);
  });

  test('recent: 129 (2026) before 130 (2025)', () async {
    expect((await repo.getRecent()).map((c) => c.id), [129, 130]);
  });

  test('top rated: 130 (4.357) before 129 (4.277)', () async {
    expect((await repo.getTopRated()).map((c) => c.id), [130, 129]);
  });

  test('search "bloc" finds only course 130', () async {
    final res = await repo.getCourses(query: 'bloc');
    expect(res.data.map((c) => c.id), [130]);
  });
}
