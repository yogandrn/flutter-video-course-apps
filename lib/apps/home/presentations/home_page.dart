// apps/course/presentations/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../cores/routes/app_router.dart';
import '../../../../cores/themes/fontstyles.dart';
import '../../../../cores/widgets/app_error_view.dart';
import '../../../../cores/widgets/app_shimmer.dart';
import '../../../cores/constant/app_view_status.dart';
import '../../../cores/di/locator.dart';
import '../../../cores/widgets/app_refresh.dart';
import '../../course/presentations/widgets/course_card.dart';
import '../../course/presentations/widgets/course_placeholders.dart';
import '../../course/presentations/widgets/course_tile.dart';
import '../blocs/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<HomeBloc>()..add(const HomeFetched()),
    child: Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) => switch (state.status) {
            ViewStatus.initial || ViewStatus.loading => const _HomeShimmer(),
            ViewStatus.failure => AppErrorView(
              message: state.error,
              onRetry: () => context.read<HomeBloc>().add(const HomeFetched()),
            ),
            ViewStatus.success => RefreshIndicator(
              onRefresh: () async =>
                  getIt<HomeBloc>()..add(const HomeFetched()),
              child: _HomeContent(state: state),
            ),
          },
        ),
      ),
    ),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () =>
        runRefresh((d) => context.read<HomeBloc>().add(HomeRefreshed(d))),
    child: CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Learn something new', style: AppFontStyles.h2),
          ),
        ),
        SliverToBoxAdapter(child: _SectionHeader(title: 'Recent Courses')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.recent.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(
                width: 180,
                child: CourseCard(course: state.recent[i], heroScope: 'recent'),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _SectionHeader(title: 'Top Rated Courses')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemCount: state.topRated.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                CourseTile(course: state.topRated[i], heroScope: 'top'),
          ),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
    child: Row(
      children: [
        Expanded(child: Text(title, style: AppFontStyles.h3)),
        TextButton(
          onPressed: () => context.push(AppRoutes.courses),
          child: const Text('See All'),
        ),
      ],
    ),
  );
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) => Shimmer(
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 200, height: 24),
          const SizedBox(height: 24),
          const ShimmerBox(width: 160, height: 18),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) =>
                  const SizedBox(width: 180, child: CourseCardPlaceholder()),
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 160, height: 18),
          const SizedBox(height: 12),
          for (var i = 0; i < 4; i++) ...const [
            CourseTilePlaceholder(),
            SizedBox(height: 12),
          ],
        ],
      ),
    ),
  );
}
