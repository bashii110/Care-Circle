import 'package:url_launcher/url_launcher.dart';

import 'emergency_call_service.dart';

/// [EmergencyCallService] backed by `url_launcher`'s `tel:` scheme.
class UrlLauncherEmergencyCallService implements EmergencyCallService {
  @override
  Future<bool> callNumber(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}
