// lib/cores/extensions/ext_string.dart
import '../constant/app_constants.dart';

extension ExtString on String {
  String get capitalized =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  List<String> get toTags =>
      split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  bool get isSearchable => trim().length >= AppConstants.minSearchChars;
}
