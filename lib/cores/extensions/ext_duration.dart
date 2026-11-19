// lib/cores/extensions/ext_duration.dart (baru)
extension ExtDuration on Duration {
  /// 75s -> "01:15", 3725s -> "1:02:05"
  String get clock {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(inMinutes.remainder(60));
    final s = two(inSeconds.remainder(60));
    return inHours > 0 ? '$inHours:$m:$s' : '$m:$s';
  }
}
