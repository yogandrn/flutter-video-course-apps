// apps/course/data/models/course_model.dart
import 'package:equatable/equatable.dart';
import 'course_section_model.dart';

class CourseModel extends Equatable {
  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.slug,
    required this.tags,
    required this.thumbnail,
    required this.author,
    required this.studentCount,
    required this.rating,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.sections = const [],
    required this.isAccessable,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    slug: json['slug'] as String,
    tags: json['tags'] as String,
    thumbnail: json['thumbnail'] as String,
    author: json['author'] as String,
    studentCount: json['student_count'] as int,
    rating: (json['rating'] as num).toDouble(),
    ratingCount: json['rating_count'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: DateTime.tryParse(json['deleted_at'] as String? ?? ''),
    sections: (json['course_sections'] as List? ?? const [])
        .map((e) => CourseSectionModel.fromJson(e as Map<String, dynamic>))
        .where((s) => s.deletedAt == null)
        .toList(),
    isAccessable: json['is_accessable'],
  );

  final int id;
  final String title;
  final String description;
  final String slug;
  final String tags; // comma separated, see ExtString.toTags
  final String thumbnail;
  final String author;
  final int studentCount;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<CourseSectionModel> sections;
  final bool isAccessable;

  int get lessonCount => sections.fold(0, (sum, s) => sum + s.lessons.length);

  // shortcut: equality by id + updatedAt, upgrade if rows can change without touching updated_at.
  @override
  List<Object?> get props => [id, updatedAt];
}
