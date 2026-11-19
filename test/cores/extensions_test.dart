// test/cores/extensions_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:course/cores/extensions/ext_int.dart';
import 'package:course/cores/extensions/ext_string.dart';

void main() {
  test('compact', () {
    expect(999.compact, '999');
    expect(1000.compact, '1K');
    expect(1500.compact, '1.5K');
    expect(2000000.compact, '2M');
  });

  test('isSearchable needs 3 chars after trim', () {
    expect('ab '.isSearchable, false);
    expect('abc'.isSearchable, true);
  });

  test('toTags', () {
    expect('content, fyp,,josjis'.toTags, ['content', 'fyp', 'josjis']);
  });
}
