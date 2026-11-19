// test/fixtures/course_fixtures.dart
import 'package:course/apps/course/data/models/course_model.dart';
import 'package:course/apps/course/data/models/courses_response.dart';
import 'package:course/apps/course/data/repository/course_repository.dart';
import 'package:course/cores/network/api_client.dart';
import 'package:mocktail/mocktail.dart';

class MockCourseRepository extends Mock implements CourseRepository {}

class MockApiClient extends Mock implements ApiClient {}

Map<String, dynamic> lessonJson(int id, int sectionId, {String? deletedAt}) => {
  'id': id,
  'section_id': sectionId,
  'title': 'Lesson $id',
  'asset_url': 'https://x.test/$id.mp4',
  'created_at': '2026-05-01 10:00:00',
  'updated_at': '2026-05-01 10:00:00',
  'deleted_at': deletedAt,
};

Map<String, dynamic> sectionJson(
  int id,
  int courseId, {
  List<Map<String, dynamic>> lessons = const [],
  String? deletedAt,
}) => {
  'id': id,
  'course_id': courseId,
  'title': 'Section $id',
  'created_at': '2026-05-01 10:00:00',
  'updated_at': '2026-05-01 10:00:00',
  'deleted_at': deletedAt,
  'course_lessons': lessons,
};

Map<String, dynamic> courseJson(
  int id, {
  String? title,
  double rating = 4.0,
  int ratingCount = 1,
  String author = 'Jane',
  String tags = 'mobile,flutter',
  String createdAt = '2026-05-01 10:00:00',
  bool isAccessable = true,
  String? deletedAt,
  List<Map<String, dynamic>> sections = const [],
}) => {
  'id': id,
  'title': title ?? 'Course $id',
  'description': 'desc',
  'slug': 'course-$id',
  'tags': tags,
  'thumbnail': 'https://x.test/$id.jpg',
  'author': author,
  'student_count': 100,
  'rating': rating,
  'rating_count': ratingCount,
  'is_accessable': isAccessable,
  'created_at': createdAt,
  'updated_at': createdAt,
  'deleted_at': deletedAt,
  'course_sections': sections,
};

CourseModel makeCourse(
  int id, {
  String? title,
  double rating = 4.0,
  int ratingCount = 1,
  String createdAt = '2026-05-01 10:00:00',
}) => CourseModel.fromJson(
  courseJson(
    id,
    title: title,
    rating: rating,
    ratingCount: ratingCount,
    createdAt: createdAt,
  ),
);

CoursesResponse pageOf(
  List<CourseModel> data, {
  int page = 1,
  int limit = 20,
  required int total,
}) => CoursesResponse(
  message: 'ok',
  data: data,
  meta: PaginationMeta(
    page: page,
    limit: limit,
    offset: (page - 1) * limit,
    total: total,
  ),
);
