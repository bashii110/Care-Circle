/// Platform-agnostic interface for placing an emergency/caregiver phone
/// call (architecture.md §11 — "Platform Integration").
///
/// `UrlLauncherEmergencyCallService` is the real implementation, backed by
/// `url_launcher`'s `tel:` scheme. Per srd.md FR-09, this must open the
/// native phone dialer pre-filled with the number — never place the call
/// silently/automatically; the caregiver still has to tap to actually
/// dial, which is exactly how a `tel:` URI behaves on iOS and Android.
abstract interface class EmergencyCallService {
  /// Opens the device's phone dialer with [phoneNumber] pre-filled.
  /// Returns whether the dialer was successfully opened.
  Future<bool> callNumber(String phoneNumber);
}
