// apps/course/presentations/detail_course/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../cores/constant/app_keys.dart';
import '../../../../cores/constant/app_view_status.dart';
import '../../../../cores/di/locator.dart';
import '../../../../cores/extensions/ext_double.dart';
import '../../../../cores/extensions/ext_int.dart';
import '../../../../cores/extensions/ext_string.dart';
import '../../../../cores/themes/colors.dart';
import '../../../../cores/themes/fontstyles.dart';
import '../../../../cores/widgets/app_error_view.dart';
import '../../../../cores/widgets/app_expandable_text.dart';
import '../../../../cores/widgets/app_refresh.dart';
import '../../../../cores/widgets/app_shimmer.dart';
import '../../blocs/detail_course/course_detail_bloc.dart';
import '../../data/models/course_model.dart';
import '../widgets/course_meta_data.dart';
import '../widgets/course_section_tile.dart';
import '../widgets/course_thumbnail.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.heroScope,
    this.preview,
  });
  final int courseId;
  final String heroScope;
  final CourseModel? preview; // only feeds the header so the Hero can fly

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<CourseDetailBloc>()..add(CourseDetailFetched(courseId)),
    child: Scaffold(
      body: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          final headerCourse = state.course ?? preview;
          return RefreshIndicator(
            edgeOffset: MediaQuery.paddingOf(context).top + 8,
            onRefresh: () => runRefresh(
              (d) => context.read<CourseDetailBloc>().add(
                CourseDetailRefreshed(courseId, d),
              ),
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _Header(
                  thumbnail: headerCourse?.thumbnail,
                  heroTag: AppKeys.courseHero(courseId, heroScope),
                ),
                switch (state.status) {
                  ViewStatus.initial ||
                  ViewStatus.loading => const _DetailShimmer(),
                  ViewStatus.failure => SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorView(
                      message: state.error,
                      onRetry: () => context.read<CourseDetailBloc>().add(
                        CourseDetailFetched(courseId),
                      ),
                    ),
                  ),
                  ViewStatus.success => _DetailContent(course: state.course!),
                },
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.thumbnail, required this.heroTag});
  final String? thumbnail;
  final String heroTag;

  @override
  Widget build(BuildContext context) => SliverAppBar(
    pinned: true,
    expandedHeight: 260,
    backgroundColor: AppColors.primaryDark,
    automaticallyImplyLeading: false,
    leading: Padding(
      padding: const EdgeInsets.all(6),
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: Colors.black38,
          foregroundColor: Colors.white,
        ),
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: thumbnail == null
          ? const ColoredBox(color: AppColors.primaryLight)
          : CourseThumbnail(url: thumbnail!, heroTag: heroTag, radius: 0),
    ),
  );
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.course});
  final CourseModel course;

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in course.tags.toTags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t.capitalized,
                        style: AppFontStyles.label.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(course.title, style: AppFontStyles.h2),
              const SizedBox(height: 10),
              AuthorLabel(author: course.author),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _Stat(
                    Icons.star_rounded,
                    '${course.rating.ratingText} (${course.ratingCount})',
                  ),
                  _Stat(
                    Icons.people_alt_rounded,
                    '${course.studentCount.compact} students',
                  ),
                  _Stat(
                    Icons.play_lesson_rounded,
                    '${course.lessonCount} lessons',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('About this course', style: AppFontStyles.h3),
              const SizedBox(height: 8),
              AppExpandableText(course.description),
              const SizedBox(height: 24),
              const Text('Course content', style: AppFontStyles.h3),
              const SizedBox(height: 12),
              if (!course.isAccessable) ...const [
                _LockedBanner(),
                SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        sliver: SliverList.separated(
          itemCount: course.sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => SectionTile(
            index: i + 1,
            section: course.sections[i],
            course: course,
            locked: !course.isAccessable,
          ),
        ),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 4),
      Text(text, style: AppFontStyles.bodySmall),
    ],
  );
}

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
    child: Shimmer(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShimmerBox(height: 26),
            SizedBox(height: 12),
            ShimmerBox(width: 120, height: 14),
            SizedBox(height: 24),
            ShimmerBox(height: 14),
            SizedBox(height: 8),
            ShimmerBox(height: 14),
            SizedBox(height: 8),
            ShimmerBox(width: 200, height: 14),
            SizedBox(height: 24),
            ShimmerBox(height: 56),
            SizedBox(height: 10),
            ShimmerBox(height: 56),
            SizedBox(height: 10),
            ShimmerBox(height: 56),
          ],
        ),
      ),
    ),
  );
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
    ),
    child: const Row(
      children: [
        Icon(Icons.lock_rounded, color: AppColors.warning),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'This course is locked. You can preview the outline, but the lessons are not available yet.',
            style: AppFontStyles.bodySmall,
          ),
        ),
      ],
    ),
  );
}
