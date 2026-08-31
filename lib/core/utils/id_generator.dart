import 'dart:math';

/// Generates reasonably unique local identifiers.
///
/// CareCircle is local-first and single-device (srd.md — no backend, no
/// sync), so a timestamp+random scheme is enough; full UUID collision
/// resistance is unnecessary for records that never leave the device.
/// If cloud sync is introduced later (architecture.md §15), replace this
/// with a proper UUID generator.
abstract final class IdGenerator {
  static final Random _random = Random();

  static String generate() {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final int suffix = _random.nextInt(1 << 32);
    return '$timestamp-$suffix';
  }
}