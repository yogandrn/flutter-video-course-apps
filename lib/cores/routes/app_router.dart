// lib/cores/routes/app_router.dart (ganti penuh)
import 'package:go_router/go_router.dart';

import '../../apps/course/data/models/course_model.dart';
import '../../apps/course/presentations/all_course/all_course_page.dart';
import '../../apps/course/presentations/detail_course/detail_course_page.dart';
import '../../apps/home/presentations/home_page.dart';
import '../../apps/video_player/data/models/video_player_args.dart';
import '../../apps/video_player/presentations/video_player_page.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const courses = '/courses';
  static const courseDetail = '/courses/:id';
  static const player = '/player';

  /// [hero] = Hero scope, so detail matches the tapped card's tag.
  static String detail(int id, {String hero = ''}) => '/courses/$id?hero=$hero';
}

// Use context.push (not go) so back pops to the previous page.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
    GoRoute(path: AppRoutes.courses, builder: (_, __) => const AllCoursePage()),
    GoRoute(
      path: AppRoutes.courseDetail,
      builder: (_, state) => CourseDetailPage(
        courseId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        heroScope: state.uri.queryParameters['hero'] ?? '',
        preview: state.extra as CourseModel?,
      ),
    ),
    GoRoute(
      path: AppRoutes.player,
      // extra is lost on app restore / deep link, so go home instead of crashing.
      redirect: (_, state) => state.extra is PlayerArgs ? null : AppRoutes.home,
      builder: (_, state) => VideoPlayerPage(args: state.extra! as PlayerArgs),
    ),
  ],
);
