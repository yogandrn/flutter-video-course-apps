// lib/cores/constant/app_keys.dart
abstract final class AppKeys {
  // scope needed: same course can show in "Recent" and "Top Rated" at once,
  // and duplicate Hero tags on one screen throw.
  static String courseHero(int id, [String scope = '']) =>
      'course-hero-$scope-$id';
}
