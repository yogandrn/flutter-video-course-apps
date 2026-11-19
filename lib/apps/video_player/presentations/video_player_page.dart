// apps/player/presentations/player_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../cores/constant/app_view_status.dart';
import '../../../cores/di/locator.dart';
import '../../../cores/themes/fontstyles.dart';
import '../../../cores/widgets/app_button.dart';
import '../blocs/player_bloc.dart';
import '../data/models/video_player_args.dart';
import 'widgets/video_player_controls.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.args});
  final PlayerArgs args;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final _pages = PageController(initialPage: widget.args.initialIndex);
  late int _index = widget.args.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final padding = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pages,
              itemCount: args.lessons.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => _LessonPage(
                key: ValueKey(i),
                args: args,
                index: i,
                isActive: i == _index,
              ),
            ),
            Positioned(
              top: padding.top + 4,
              left: 8,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            if (args.lessons.length > 1)
              Positioned(
                top: padding.top + 12,
                right: 16,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_index + 1} / ${args.lessons.length}',
                      style: AppFontStyles.label.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One lesson = one full-screen page = one bloc = one controller.
class _LessonPage extends StatefulWidget {
  const _LessonPage({
    super.key,
    required this.args,
    required this.index,
    required this.isActive,
  });
  final PlayerArgs args;
  final int index;
  final bool isActive;

  @override
  State<_LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<_LessonPage> {
  PlayerLesson get _lesson => widget.args.lessons[widget.index];

  // neighbour pages built mid-swipe start paused, they play once they become active
  late final _bloc = getIt<VideoPlayerBloc>()
    ..add(LessonPlayerStarted(_lesson.url, autoplay: widget.isActive));

  @override
  void didUpdateWidget(_LessonPage old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) {
      _bloc.add(LessonPlayerActiveChanged(widget.isActive));
    }
  }

  @override
  void dispose() {
    _bloc.close(); // disposes the video controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocProvider.value(
      value: _bloc,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Stage(url: _lesson.url),
          const _Shade(),
          // IgnorePointer: caption must not eat taps meant for play/pause or the seek bar.
          Positioned(
            left: 16,
            right: 16,
            bottom: bottom + 40,
            child: IgnorePointer(
              child: _Caption(
                courseTitle: widget.args.courseTitle,
                lessonTitle: _lesson.title,
                sectionTitle: widget.args.sectionTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.url});
  final String url;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
    builder: (context, state) => switch (state.status) {
      ViewStatus.initial || ViewStatus.loading => const _LoadingPlaceholder(),
      ViewStatus.failure => _ErrorStage(
        message: state.error,
        onRetry: () =>
            context.read<VideoPlayerBloc>().add(LessonPlayerStarted(url)),
      ),
      ViewStatus.success => Stack(
        fit: StackFit.expand,
        children: [
          _VideoSurface(controller: state.controller!),
          if (state.isBuffering)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          VideoPlayerControls(state: state),
        ],
      ),
    },
  );
}

/// Vertical clip fills the screen (cropped like TikTok); landscape stays letterboxed.
class _VideoSurface extends StatelessWidget {
  const _VideoSurface({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;
    return ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: FittedBox(
          fit: size.height > size.width ? BoxFit.cover : BoxFit.contain,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1F3A3A), Colors.black],
      ),
    ),
    child: Center(child: CircularProgressIndicator(color: Colors.white)),
  );
}

class _ErrorStage extends StatelessWidget {
  const _ErrorStage({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.white70,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFontStyles.body.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Dark gradients so white text and the back button stay readable on any frame.
class _Shade extends StatelessWidget {
  const _Shade();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Column(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: MediaQuery.sizeOf(context).height * 0.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Caption extends StatelessWidget {
  const _Caption({
    required this.courseTitle,
    required this.lessonTitle,
    required this.sectionTitle,
  });
  final String courseTitle;
  final String lessonTitle;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        courseTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFontStyles.label.copyWith(color: Colors.white70),
      ),
      const SizedBox(height: 4),
      Text(
        lessonTitle,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: AppFontStyles.h3.copyWith(color: Colors.white),
      ),
      const SizedBox(height: 4),
      Text(
        sectionTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFontStyles.bodySmall.copyWith(color: Colors.white70),
      ),
    ],
  );
}
