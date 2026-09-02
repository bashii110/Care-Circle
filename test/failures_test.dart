import 'package:care_circle/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('failures expose caregiver-readable messages, not technical detail', () {
    const StorageFailure storage = StorageFailure();
    const NotificationFailure notification = NotificationFailure();
    const ShareFailure share = ShareFailure();
    const AuthenticationFailure auth = AuthenticationFailure();
    const ValidationFailure validation = ValidationFailure('Enter a valid age.');

    for (final Failure failure in <Failure>[storage, notification, share, auth, validation]) {
      expect(failure.message, isNotEmpty);
      expect(failure.message.toLowerCase(), isNot(contains('exception')));
      expect(failure.message.toLowerCase(), isNot(contains('stack')));
      expect(failure.toString(), failure.message);
    }
  });
}
