// lib\apps\video_player\blocs\player_state.dart
part of 'player_bloc.dart';

class VideoPlayerState extends Equatable {
  const VideoPlayerState({
    this.status = ViewStatus.initial,
    this.controller,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error = '',
  });

  final ViewStatus status; // success = ready to play
  final VideoPlayerController? controller;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final String error;

  bool get isEnded => duration > Duration.zero && position >= duration;

  VideoPlayerState copyWith({
    ViewStatus? status,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    String? error,
  }) => VideoPlayerState(
    status: status ?? this.status,
    controller: controller,
    isPlaying: isPlaying ?? this.isPlaying,
    isBuffering: isBuffering ?? this.isBuffering,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [
    status,
    controller,
    isPlaying,
    isBuffering,
    position,
    duration,
    error,
  ];
}
