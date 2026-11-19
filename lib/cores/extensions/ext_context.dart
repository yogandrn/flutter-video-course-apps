// lib/cores/extensions/ext_context.dart
import 'package:flutter/material.dart';
import '../constant/app_constants.dart';

extension ExtContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// 2 columns on normal phones, 3 when width > 480.
  int get gridCount => screenWidth > AppConstants.gridBreakpoint ? 3 : 2;
}
