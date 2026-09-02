import 'package:care_circle/core/services/emergency_call_service.dart';

/// Records calls instead of touching a real phone dialer.
class FakeEmergencyCallService implements EmergencyCallService {
  final List<String> callsPlaced = <String>[];
  bool shouldSucceed = true;

  @override
  Future<bool> callNumber(String phoneNumber) async {
    callsPlaced.add(phoneNumber);
    return shouldSucceed;
  }
}
