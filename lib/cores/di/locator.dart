// lib/cores/di/locator.dart
import 'package:get_it/get_it.dart';
import '../../apps/course/blocs/all_course/all_course_bloc.dart';
import '../../apps/course/blocs/detail_course/course_detail_bloc.dart';
import '../../apps/course/data/repository/course_repository.dart';
import '../../apps/home/blocs/home_bloc.dart';
import '../../apps/video_player/blocs/player_bloc.dart';
import '../../apps/video_player/data/repository/video_cache_repository.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

void setupServices() {
  getIt
    ..registerLazySingleton<ApiClient>(() => ApiClient())
    ..registerLazySingleton<CourseRepository>(() => CourseRepository(getIt()))
    ..registerLazySingleton<VideoCacheRepository>(() => VideoCacheRepository())
    // blocs: factory, one fresh instance per page
    ..registerFactory<HomeBloc>(() => HomeBloc(getIt()))
    ..registerFactory<AllCourseBloc>(() => AllCourseBloc(getIt()))
    ..registerFactory<CourseDetailBloc>(() => CourseDetailBloc(getIt()))
    ..registerFactory<VideoPlayerBloc>(() => VideoPlayerBloc(getIt()));
}
