// lib/core/services/device_service.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static const String _keyDeviceString = "key_device_string";

  static Future<String> getOrCreateDeviceId() async {
    final pref = await SharedPreferences.getInstance();
    String? deviceId = pref.getString(_keyDeviceString);

    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // androidInfo.id is Settings.Secure.ANDROID_ID (64-bit hex string)
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }

    // Edge-case fallback agar emulator ya permission issue me null aaye
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await pref.setString(_keyDeviceString, deviceId);
    return deviceId;
  }
}