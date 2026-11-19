// apps/course/presentations/widgets/course_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../cores/constant/app_keys.dart';
import '../../../../cores/routes/app_router.dart';
import '../../../../cores/themes/colors.dart';
import '../../../../cores/themes/fontstyles.dart';
import '../../data/models/course_model.dart';
import 'course_meta_data.dart';
import 'course_thumbnail.dart';

extension CourseNav on BuildContext {
  /// Passes the course as `extra` so the detail header (Hero target) exists in frame 1.
  void openCourse(CourseModel course, String heroScope) =>
      push(AppRoutes.detail(course.id, hero: heroScope), extra: course);
}

/// Portrait card: used by the horizontal "Recent" list and the grid.
class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.heroScope});
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CourseThumbnail(
                    url: course.thumbnail,
                    heroTag: AppKeys.courseHero(course.id, heroScope),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: RatingPill(rating: course.rating),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            AuthorLabel(author: course.author),
          ],
        ),
      ),
    ),
  );
}
