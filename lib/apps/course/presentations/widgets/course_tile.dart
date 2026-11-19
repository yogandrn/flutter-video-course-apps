// apps/course/presentations/widgets/course_tile.dart
import 'package:flutter/material.dart';
import '../../../../../cores/constant/app_keys.dart';
import '../../../../../cores/themes/colors.dart';
import '../../../../../cores/themes/fontstyles.dart';
import '../../data/models/course_model.dart';
import 'course_card.dart';
import 'course_meta_data.dart';
import 'course_thumbnail.dart';

/// Row card: used by the vertical "Top Rated" list.
class CourseTile extends StatelessWidget {
  const CourseTile({super.key, required this.course, required this.heroScope});
  final CourseModel course;
  final String heroScope;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      onTap: () => context.openCourse(course, heroScope),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CourseThumbnail(
                    url: course.thumbnail,
                    heroTag: AppKeys.courseHero(course.id, heroScope),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: RatingPill(rating: course.rating),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthorLabel(author: course.author),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
