import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/utils/duration_format.dart';

void main() {
  test('drops the hours field under an hour', () {
    expect(formatDuration(Duration.zero), '00:00');
    expect(formatDuration(const Duration(seconds: 5)), '00:05');
    expect(formatDuration(const Duration(minutes: 9, seconds: 30)), '09:30');
    expect(formatDuration(const Duration(minutes: 59, seconds: 59)), '59:59');
  });

  test('shows unpadded hours with zero-padded minutes and seconds', () {
    expect(formatDuration(const Duration(hours: 1)), '1:00:00');
    expect(
      formatDuration(const Duration(hours: 12, minutes: 3, seconds: 4)),
      '12:03:04',
    );
  });

  test('truncates sub-second remainders rather than rounding up', () {
    expect(formatDuration(const Duration(milliseconds: 59999)), '00:59');
  });
}
