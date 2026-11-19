// apps/player/presentations/widgets/lesson_player_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cores/extensions/ext_duration.dart';
import '../../../../cores/themes/fontstyles.dart';
import '../../blocs/player_bloc.dart';

/// TikTok-style: tap anywhere = play/pause, thin seek bar at the bottom.
class VideoPlayerControls extends StatefulWidget {
  const VideoPlayerControls({super.key, required this.state});
  final VideoPlayerState state;

  @override
  State<VideoPlayerControls> createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  double? _drag; // ms, while the thumb is held

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final max = s.duration.inMilliseconds > 0
        ? s.duration.inMilliseconds.toDouble()
        : 1.0;
    final value = (_drag ?? s.position.inMilliseconds.toDouble())
        .clamp(0.0, max)
        .toDouble();
    final dragging = _drag != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              context.read<VideoPlayerBloc>().add(const LessonPlayerToggled()),
        ),
        if (!s.isPlaying && !s.isBuffering && !dragging)
          IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  s.isEnded ? Icons.replay_rounded : Icons.play_arrow_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (dragging)
          IgnorePointer(
            child: Center(
              child: Text(
                '${Duration(milliseconds: value.round()).clock} / ${s.duration.clock}',
                style: AppFontStyles.h2.copyWith(color: Colors.white),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 32,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: dragging ? 4 : 2,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: dragging ? 6 : 3,
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: value,
                  max: max,
                  onChanged: (v) => setState(() => _drag = v),
                  onChangeEnd: (v) {
                    context.read<VideoPlayerBloc>().add(
                      LessonPlayerSeeked(Duration(milliseconds: v.round())),
                    );
                    setState(() => _drag = null);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
