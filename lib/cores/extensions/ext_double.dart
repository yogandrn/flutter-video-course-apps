// lib/cores/extensions/ext_double.dart
extension ExtDouble on double {
  /// 4.756 -> "4.8"
  String get ratingText => toStringAsFixed(1);
}
