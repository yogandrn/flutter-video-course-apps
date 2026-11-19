// apps/course/data/repository/course_repository.dart
import 'dart:developer';

import '../../../../cores/constant/app_constants.dart';
import '../../../../cores/network/api_client.dart';
import '../models/course_model.dart';
import '../models/courses_response.dart';

/// Mock backend = one static courses.json. Paging, search, sort and detail
/// lookup all happen here, so swapping to a real API only touches this file.
class CourseRepository {
  CourseRepository(this._api);
  final ApiClient _api;

  List<CourseModel>? _cache;

  void invalidate() => _cache = null;

  Future<List<CourseModel>> _all() async {
    final cached = _cache;
    if (cached != null) return cached;
    await Future.delayed(Duration(milliseconds: 600));
    final json = await _api.get("/courses.json") as List;
    return _cache = json
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .where((c) => c.deletedAt == null)
        .toList();
  }

  Future<CoursesResponse> getCourses({
    int page = 1,
    int limit = AppConstants.pageLimit,
    String query = '',
  }) async {
    try {
      final q = query.trim().toLowerCase();
      final all = await _all();
      final matched = q.isEmpty
          ? all
          : all
                .where(
                  (c) => '${c.title} ${c.author} ${c.tags}'
                      .toLowerCase()
                      .contains(q),
                )
                .toList();
      final offset = (page - 1) * limit;
      return CoursesResponse(
        message: 'Successfully fetch courses data',
        data: matched.skip(offset).take(limit).toList(),
        meta: PaginationMeta(
          page: page,
          limit: limit,
          offset: offset,
          total: matched.length,
        ),
      );
    } catch (e) {
      log("[CourseRepository] Error on getCourses: $e");
      rethrow;
    }
  }

  Future<List<CourseModel>> getRecent({
    int limit = AppConstants.homeListLimit,
  }) async {
    try {
      final sorted = [...await _all()]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted.take(limit).toList();
    } catch (e) {
      log("[CourseRepository] Error on getRecents: $e");
      rethrow;
    }
  }

  Future<List<CourseModel>> getTopRated({
    int limit = AppConstants.homeListLimit,
  }) async {
    try {
      final sorted = [...await _all()]
        ..sort((a, b) {
          final byRating = b.rating.compareTo(a.rating);
          return byRating != 0
              ? byRating
              : b.ratingCount.compareTo(a.ratingCount);
        });
      return sorted.take(limit).toList();
    } catch (e) {
      log("[CourseRepository] Error on getTopRated: $e");
      rethrow;
    }
  }

  Future<CourseModel> getCourseDetail(int id) async {
    try {
      final all = await _all();
      return all.firstWhere(
        (c) => c.id == id,
        orElse: () => throw ApiException('Course not found.', statusCode: 404),
      );
    } catch (e) {
      log("[CourseRepository] Error on getCourseDetail: $e");
      rethrow;
    }
  }
}
