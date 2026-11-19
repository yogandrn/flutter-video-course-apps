// lib/cores/extensions/ext_int.dart
extension ExtInt on int {
  /// 392 -> "392", 1500 -> "1.5K", 2000000 -> "2M"
  String get compact {
    if (this >= 1000000)
      return '${(this / 1000000).toStringAsFixed(1)}M'.replaceAll('.0', '');
    if (this >= 1000)
      return '${(this / 1000).toStringAsFixed(1)}K'.replaceAll('.0', '');
    return '$this';
  }
}
