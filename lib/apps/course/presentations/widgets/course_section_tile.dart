// apps\course\presentations\widgets\course_section_tile.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../cores/routes/app_router.dart';
import '../../../../../cores/themes/colors.dart';
import '../../../../../cores/themes/fontstyles.dart';
import '../../../../cores/widgets/app_alert.dart';
import '../../../video_player/data/models/video_player_args.dart';
import '../../data/models/course_model.dart';
import '../../data/models/course_section_model.dart';

class SectionTile extends StatelessWidget {
  const SectionTile({
    super.key,
    required this.index,
    required this.section,
    required this.course,
    this.locked = false,
  });
  final int index;
  final CourseSectionModel section;
  final CourseModel course;
  final bool locked;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: locked ? _lockedTile(context) : _openTile(context),
  );

  /// Locked: no expansion, lessons are not rendered at all.
  Widget _lockedTile(BuildContext context) => ListTile(
    leading: const CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.border,
      child: Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondary),
    ),
    title: Text(
      section.title,
      style: AppFontStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
    subtitle: Text(
      '${section.lessons.length} lessons · Locked',
      style: AppFontStyles.bodySmall,
    ),
    trailing: const Icon(
      Icons.lock_outline_rounded,
      color: AppColors.textSecondary,
    ),
    onTap: () => AppAlert.show(
      context,
      'This course is locked.',
      type: AlertType.warning,
    ),
  );

  Widget _openTile(BuildContext context) => ExpansionTile(
    shape: const Border(), // drop the default divider lines
    collapsedShape: const Border(),
    leading: CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        '$index',
        style: AppFontStyles.label.copyWith(color: AppColors.primaryDark),
      ),
    ),
    title: Text(
      section.title,
      style: AppFontStyles.body.copyWith(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      '${section.lessons.length} lessons',
      style: AppFontStyles.bodySmall,
    ),
    children: [
      for (final (i, lesson) in section.lessons.indexed)
        ListTile(
          dense: true,
          leading: const Icon(
            Icons.play_circle_fill_rounded,
            color: AppColors.accent,
          ),
          title: Text(lesson.title, style: AppFontStyles.body),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
          onTap: () => context.push(
            AppRoutes.player,
            extra: PlayerArgs(
              lessons: [
                for (final l in section.lessons)
                  PlayerLesson(url: l.assetUrl, title: l.title),
              ],
              initialIndex: i,
              sectionTitle: section.title,
              courseTitle: course.title,
            ),
          ),
        ),
    ],
  );
}
