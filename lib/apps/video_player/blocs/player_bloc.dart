// lib\apps\video_player\blocs\player_bloc.dart
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../cores/constant/app_view_status.dart';
import '../data/repository/video_cache_repository.dart';

part 'player_event.dart';
part 'player_state.dart';

/// Owns the controller. Closing the bloc (page popped) disposes it.
class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc(this._cache) : super(const VideoPlayerState()) {
    on<LessonPlayerStarted>(_onStarted, transformer: droppable());
    on<LessonPlayerToggled>(_onToggled);
    on<LessonPlayerSeeked>(_onSeeked);
    on<LessonPlayerTicked>(_onTicked);
    on<LessonPlayerActiveChanged>(_onActiveChanged);
  }

  final VideoCacheRepository _cache;
  VideoPlayerController? _controller;
  bool _active = true;

  Future<void> _onStarted(
    LessonPlayerStarted event,
    Emitter<VideoPlayerState> emit,
  ) async {
    emit(const VideoPlayerState(status: ViewStatus.loading));
    await _release();
    VideoPlayerController? c;
    try {
      _active = event.autoplay;
      c = await _cache.controllerFor(event.url);
      await c.initialize();
      if (emit.isDone) {
        // page closed while initializing, nobody owns this controller
        await c.dispose();
        return;
      }
      _controller = c..addListener(_onControllerValue);
      if (_active) await c.play();
      emit(VideoPlayerState(status: ViewStatus.success, controller: c));
    } catch (_) {
      await c?.dispose();
      _controller = null;
      await _cache.evict(event.url);
      if (!emit.isDone) {
        emit(
          const VideoPlayerState(
            status: ViewStatus.failure,
            error:
                'Unable to play this video. Check your connection and try again.',
          ),
        );
      }
    }
  }

  Future<void> _onToggled(
    LessonPlayerToggled event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final c = _controller;
    if (c == null) return;
    if (c.value.isPlaying) {
      await c.pause();
      return;
    }
    if (state.isEnded) await c.seekTo(Duration.zero);
    await c.play();
  }

  Future<void> _onSeeked(
    LessonPlayerSeeked event,
    Emitter<VideoPlayerState> emit,
  ) async {
    emit(
      state.copyWith(position: event.position),
    ); // optimistic, avoids slider snap-back
    await _controller?.seekTo(event.position);
  }

  void _onTicked(LessonPlayerTicked event, Emitter<VideoPlayerState> emit) {
    final v = event.value;
    if (v.hasError) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          error: 'Playback error. Please try again.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isPlaying: v.isPlaying,
        isBuffering: v.isBuffering,
        position: v.position,
        duration: v.duration,
      ),
    );
  }

  Future<void> _onActiveChanged(
    LessonPlayerActiveChanged event,
    Emitter<VideoPlayerState> emit,
  ) async {
    _active =
        event.active; // remembered even if the controller is still initializing
    final c = _controller;
    if (c == null) return;
    event.active ? await c.play() : await c.pause();
  }

  void _onControllerValue() {
    final c = _controller;
    if (c != null && !isClosed) add(LessonPlayerTicked(c.value));
  }

  Future<void> _release() async {
    final c = _controller;
    _controller = null;
    c?.removeListener(_onControllerValue);
    await c?.dispose();
  }

  @override
  Future<void> close() async {
    await _release();
    return super.close();
  }
}
