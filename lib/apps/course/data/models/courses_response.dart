// apps/course/data/models/courses_response.dart
import 'package:equatable/equatable.dart';
import 'course_model.dart';

class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    page: json['page'] as int,
    limit: json['limit'] as int,
    offset: json['offset'] as int,
    total: json['total'] as int,
  );

  final int page;
  final int limit;
  final int offset;
  final int total;

  bool get hasMore => offset + limit < total;

  @override
  List<Object?> get props => [page, limit, offset, total];
}

class CoursesResponse extends Equatable {
  const CoursesResponse({
    required this.message,
    required this.data,
    required this.meta,
  });

  factory CoursesResponse.fromJson(Map<String, dynamic> json) =>
      CoursesResponse(
        message: json['message'] as String,
        data: (json['data'] as List)
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );

  final String message;
  final List<CourseModel> data;
  final PaginationMeta meta;

  @override
  List<Object?> get props => [message, data, meta];
}
