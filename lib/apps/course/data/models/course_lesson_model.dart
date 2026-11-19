// apps/course/data/models/course_lesson_model.dart
import 'package:equatable/equatable.dart';

class CourseLessonModel extends Equatable {
  const CourseLessonModel({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.assetUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) =>
      CourseLessonModel(
        id: json['id'] as int,
        sectionId: json['section_id'] as int,
        title: json['title'] as String,
        assetUrl: json['asset_url'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        deletedAt: DateTime.tryParse(json['deleted_at'] as String? ?? ''),
      );

  final int id;
  final int sectionId;
  final String title;
  final String assetUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [id, updatedAt];
}
