// lib\apps\video_player\data\models\video_player_args.dart
class PlayerLesson {
  const PlayerLesson({required this.url, required this.title});
  final String url;
  final String title;
}

class PlayerArgs {
  const PlayerArgs({
    required this.lessons,
    required this.initialIndex,
    required this.sectionTitle,
    required this.courseTitle,
  });

  final List<PlayerLesson> lessons; // all lessons of the tapped section
  final int initialIndex;
  final String sectionTitle;
  final String courseTitle;
}
