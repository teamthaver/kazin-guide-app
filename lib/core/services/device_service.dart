import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const String _keyDeviceString = "key_device_string";

  static Future<String> getOrCreateDeviceId() async {
    final pref = await SharedPreferences.getInstance();
    String? deviceId = pref.getString(_keyDeviceString);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4().replaceAll("-", " ");
      await pref.setString(_keyDeviceString, deviceId);
    }
    return deviceId;
  }
}
