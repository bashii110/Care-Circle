import 'dart:math';

/// Generates identifiers for new local records.
///
/// CareCircle is offline-first with no server assigning IDs, so this only
/// needs to be unique *on this device* — it doesn't need to be a
/// cryptographically strong UUID, so no extra dependency is pulled in for
/// it. Combining a timestamp with a random suffix is sufficient to avoid
/// collisions between records created within the same app session.
abstract final class IdGenerator {
  static final Random _random = Random.secure();

  static String generate() {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final int suffix = _random.nextInt(1 << 32);
    return '${timestamp.toRadixString(36)}-${suffix.toRadixString(36)}';
  }
}
