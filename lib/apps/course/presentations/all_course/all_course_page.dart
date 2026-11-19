// apps/course/presentations/all_course/all_course_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cores/constant/app_view_status.dart';
import '../../../../cores/di/locator.dart';
import '../../../../cores/extensions/ext_context.dart';
import '../../../../cores/themes/colors.dart';
import '../../../../cores/themes/fontstyles.dart';
import '../../../../cores/widgets/app_error_view.dart';
import '../../../../cores/widgets/app_refresh.dart';
import '../../../../cores/widgets/app_shimmer.dart';
import '../../../../cores/widgets/app_text_field.dart';
import '../../blocs/all_course/all_course_bloc.dart';
import '../widgets/course_card.dart';
import '../widgets/course_placeholders.dart';

SliverGridDelegate _gridDelegate(BuildContext context) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.gridCount, // 2, or 3 when width > 480
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.72,
    );

class AllCoursePage extends StatelessWidget {
  const AllCoursePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AllCourseBloc>()..add(const AllCourseFetched()),
    child: const _AllCourseView(),
  );
}

class _AllCourseView extends StatefulWidget {
  const _AllCourseView();

  @override
  State<_AllCourseView> createState() => _AllCourseViewState();
}

class _AllCourseViewState extends State<_AllCourseView> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter > 120) return;
    final bloc = context.read<AllCourseBloc>();
    // after a failed page, only the footer's Retry button re-triggers
    if (!bloc.state.loadMoreFailed) {
      bloc.add(const AllCourseNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('All Courses')),
    body: RefreshIndicator(
      onRefresh: () => runRefresh(
        (d) => context.read<AllCourseBloc>().add(AllCourseRefreshed(d)),
      ),
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppTextField(
                controller: _search,
                hint: 'Search courses (min. 3 characters)',
                prefixIcon: Icons.search_rounded,
                textInputAction: TextInputAction.search,
                onChanged: (v) => context.read<AllCourseBloc>().add(
                  AllCourseSearchChanged(v),
                ),
              ),
            ),
          ),
          BlocBuilder<AllCourseBloc, AllCourseState>(
            builder: (context, state) => switch (state.status) {
              ViewStatus.initial || ViewStatus.loading => const _GridShimmer(),
              ViewStatus.failure => SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  message: state.error,
                  onRetry: () => context.read<AllCourseBloc>().add(
                    const AllCourseFetched(),
                  ),
                ),
              ),
              ViewStatus.success when state.courses.isEmpty =>
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No courses found',
                      style: AppFontStyles.bodySmall,
                    ),
                  ),
                ),
              ViewStatus.success => _CourseGrid(state: state),
            },
          ),
        ],
      ),
    ),
  );
}

class _CourseGrid extends StatelessWidget {
  const _CourseGrid({required this.state});
  final AllCourseState state;

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid.builder(
          gridDelegate: _gridDelegate(context),
          itemCount: state.courses.length,
          itemBuilder: (_, i) =>
              CourseCard(course: state.courses[i], heroScope: 'all'),
        ),
      ),
      SliverToBoxAdapter(child: _Footer(state: state)),
    ],
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state});
  final AllCourseState state;

  @override
  Widget build(BuildContext context) {
    final Widget child = state.isLoadingMore
        ? const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              Text('Loading more courses...', style: AppFontStyles.bodySmall),
            ],
          )
        : state.loadMoreFailed
        ? TextButton(
            onPressed: () => context.read<AllCourseBloc>().add(
              const AllCourseNextPageRequested(),
            ),
            child: const Text('Failed to load more. Tap to retry'),
          )
        : const SizedBox(
            height: 28,
          ); // keeps layout stable, no jump when spinner appears
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: child),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    sliver: SliverToBoxAdapter(
      child: Shimmer(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: _gridDelegate(context),
          itemCount: 6,
          itemBuilder: (_, __) => const CourseCardPlaceholder(),
        ),
      ),
    ),
  );
}
