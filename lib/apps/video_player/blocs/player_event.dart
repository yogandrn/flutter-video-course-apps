// lib\apps\video_player\blocs\player_event.dart
part of 'player_bloc.dart';

sealed class VideoPlayerEvent {
  const VideoPlayerEvent();
}

final class LessonPlayerStarted extends VideoPlayerEvent {
  const LessonPlayerStarted(this.url, {this.autoplay = true});
  final String url;
  final bool autoplay;
}

final class LessonPlayerToggled extends VideoPlayerEvent {
  const LessonPlayerToggled();
}

final class LessonPlayerSeeked extends VideoPlayerEvent {
  const LessonPlayerSeeked(this.position);
  final Duration position;
}

/// Internal: fired by the controller listener.
final class LessonPlayerTicked extends VideoPlayerEvent {
  const LessonPlayerTicked(this.value);
  final VideoPlayerValue value;
}

/// The page became (or stopped being) the one on screen.
final class LessonPlayerActiveChanged extends VideoPlayerEvent {
  const LessonPlayerActiveChanged(this.active);
  final bool active;
}
