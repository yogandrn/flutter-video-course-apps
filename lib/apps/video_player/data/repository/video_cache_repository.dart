// lib\apps\video_player\data\repository\video_cache_repository.dart
import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class VideoCacheRepository {
  VideoCacheRepository({CacheManager? cache})
    : _cache =
          cache ??
          CacheManager(
            Config(
              'lesson_videos',
              stalePeriod: const Duration(days: 7),
              maxNrOfCacheObjects: 20,
            ),
          );

  final CacheManager _cache;

  /// Cached: play the local file. Not cached: stream now, fill the cache in
  /// the background so the next watch is instant.
  Future<VideoPlayerController> controllerFor(String url) async {
    final cached = await _cache.getFileFromCache(url);
    if (cached != null) return VideoPlayerController.file(cached.file);
    // shortcut: a second download runs beside the stream (double bandwidth once).
    // Upgrade to a local caching proxy if that matters.
    unawaited(
      _cache.downloadFile(url).then<void>((_) {}, onError: (Object _) {}),
    );
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }

  /// Drop a bad cache entry so the next try streams again.
  Future<void> evict(String url) => _cache.removeFile(url);
}
