// apps/course/data/models/course_section_model.dart
import 'package:equatable/equatable.dart';
import 'course_lesson_model.dart';

class CourseSectionModel extends Equatable {
  const CourseSectionModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.lessons = const [],
  });

  factory CourseSectionModel.fromJson(Map<String, dynamic> json) =>
      CourseSectionModel(
        id: json['id'] as int,
        courseId: json['course_id'] as int,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        deletedAt: DateTime.tryParse(json['deleted_at'] as String? ?? ''),
        // soft-deleted lessons never reach the app
        lessons: (json['course_lessons'] as List? ?? const [])
            .map((e) => CourseLessonModel.fromJson(e as Map<String, dynamic>))
            .where((l) => l.deletedAt == null)
            .toList(),
      );

  final int id;
  final int courseId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<CourseLessonModel> lessons;

  @override
  List<Object?> get props => [id, updatedAt];
}
