/// Application-level failure types.
///
/// Per architecture.md §12, Riverpod controllers should expose
/// user-friendly `loading` / `data` / `empty` / `error` states rather than
/// leaking raw exceptions or stack traces to the UI. These sealed classes
/// give later phases a consistent vocabulary for the `error` state, and a
/// single place to attach a caregiver-readable [message].
///
/// These types are established now, in Phase 0, because they are a
/// cross-cutting contract between the domain layer and the UI — later
/// phases (repositories, notification scheduling, sharing, security) all
/// depend on this shape existing rather than inventing their own.
library;

/// Base type for all recoverable application failures.
sealed class Failure {
  const Failure(this.message);

  /// A short, human-readable message suitable for display to a caregiver.
  /// Must never contain technical details (design.md §14 / master prompt §16).
  final String message;

  @override
  String toString() => message;
}

/// Local persistence could not complete (Hive read/write, box access, etc.).
final class StorageFailure extends Failure {
  const StorageFailure([
    super.message = "We couldn't load your care records. Please try again.",
  ]);
}

/// User-entered data failed validation.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// A local notification could not be scheduled, updated, or cancelled.
final class NotificationFailure extends Failure {
  const NotificationFailure([
    super.message = "We couldn't set up that reminder. Please try again.",
  ]);
}

/// The native share sheet could not be opened or completed.
final class ShareFailure extends Failure {
  const ShareFailure([
    super.message = "We couldn't share the report. Please try again.",
  ]);
}

/// Biometric/local authentication failed or is unavailable.
final class AuthenticationFailure extends Failure {
  const AuthenticationFailure([
    super.message = "We couldn't verify it's you. Please try again.",
  ]);
}
