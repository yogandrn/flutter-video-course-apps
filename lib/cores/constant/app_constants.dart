// lib/cores/constant/app_constants.dart
abstract final class AppConstants {
  static const baseUrl =
      'https://github.com/yogandrn/vigilant-octo-succotash/raw/refs/heads/main';

  static const pageLimit = 20;
  static const searchDebounce = Duration(milliseconds: 250);
  static const minSearchChars = 3;
  static const gridBreakpoint = 480.0;
  static const homeListLimit = 10;
}
