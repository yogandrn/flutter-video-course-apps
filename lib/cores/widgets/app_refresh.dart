// lib/cores/widgets/app_refresh.dart
import 'dart:async';

/// Bridges RefreshIndicator.onRefresh to a bloc event. The bloc completes [done] when finished.
Future<void> runRefresh(void Function(Completer<void> done) fire) {
  final done = Completer<void>();
  fire(done);
  return done.future;
}
