import 'package:care_circle/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('is deterministic for the same inputs', () {
    final int a = medicationNotificationId(medicationId: 'med-1', hour: 8, minute: 0);
    final int b = medicationNotificationId(medicationId: 'med-1', hour: 8, minute: 0);
    expect(a, b);
  });

  test('differs for different medications at the same time', () {
    final int a = medicationNotificationId(medicationId: 'med-1', hour: 8, minute: 0);
    final int b = medicationNotificationId(medicationId: 'med-2', hour: 8, minute: 0);
    expect(a, isNot(b));
  });

  test('differs for the same medication at different times', () {
    final int a = medicationNotificationId(medicationId: 'med-1', hour: 8, minute: 0);
    final int b = medicationNotificationId(medicationId: 'med-1', hour: 20, minute: 0);
    expect(a, isNot(b));
  });

  test('is always a non-negative, 32-bit-safe integer', () {
    for (final String id in <String>['a', 'senior-1-med-abc', '', List.filled(200, 'x').join()]) {
      for (int hour = 0; hour < 24; hour += 6) {
        final int result = medicationNotificationId(medicationId: id, hour: hour, minute: 30);
        expect(result, greaterThanOrEqualTo(0));
        expect(result, lessThan(1 << 31));
      }
    }
  });
}
