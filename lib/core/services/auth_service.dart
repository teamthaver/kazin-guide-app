import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/device_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  late final GetStorage _box;
  final ApiService _apiService = Get.find<ApiService>();

  final isLoggedIn = false.obs;

  // Storage Keys
  static const String _authKey = 'is_authenticated';
  static const String _guideIdKey = 'guide_id';
  static const String _userPhoneKey = 'user_phone';
  static const String _sessionTokenKey = 'session_token';
  static const String _guideDataKey = 'guide_data';

  // Base URL for uploads/profile assets
  static const String assetBaseUrl =
      "https://kazincrmnew.thavertech.com/assets/guide/";

  Future<AuthService> init() async {
    _box = GetStorage();
    isLoggedIn.value = _box.read<bool>(_authKey) ?? false;
    return this;
  }

  // --- Session Storage ---
  void saveLoginSession({
    required int guideId,
    required String phone,
    required String sessionToken,
    Map<String, dynamic>? guideData,
  }) {
    _box.write(_authKey, true);
    _box.write(_guideIdKey, guideId);
    _box.write(_userPhoneKey, phone);
    _box.write(_sessionTokenKey, sessionToken);
    if (guideData != null) {
      _box.write(_guideDataKey, guideData);
    }
    isLoggedIn.value = true;
  }

  void clearSession() {
    _box.remove(_authKey);
    _box.remove(_guideIdKey);
    _box.remove(_userPhoneKey);
    _box.remove(_sessionTokenKey);
    _box.remove(_guideDataKey);
    isLoggedIn.value = false;
  }

  int get guideId => _box.read<int>(_guideIdKey) ?? 0;
  String get savedPhone => _box.read<String>(_userPhoneKey) ?? "";
  String get sessionToken => _box.read<String>(_sessionTokenKey) ?? "";
  Map<String, dynamic> get guideData =>
      Map<String, dynamic>.from(_box.read(_guideDataKey) ?? {});

  String get fullName {
    final data = guideData;
    final first = (data['name'] ?? '').toString().trim();
    final last = (data['last_name'] ?? '').toString().trim();
    if (first.isEmpty && last.isEmpty) return "Guide";
    return "$first $last".trim();
  }

  String get firstName {
    final data = guideData;
    final first = (data['name'] ?? '').toString().trim();
    return first.isNotEmpty ? first : "Guide";
  }

  String get formattedPhone {
    final data = guideData;
    final isd = (data['isd_codes'] ?? '+7').toString().trim();
    final phone = (data['contact_number'] ?? savedPhone).toString().trim();
    return "$isd $phone";
  }

  String get location {
    final data = guideData;
    final city = (data['city'] ?? '').toString().trim();
    final country = (data['country'] ?? '').toString().trim();
    if (city.isNotEmpty && country.isNotEmpty) return "$city, $country";
    return city.isNotEmpty
        ? city
        : (country.isNotEmpty ? country : "Tbilisi, Georgia");
  }

  String get languages {
    final data = guideData;
    final langs = (data['languages'] ?? '').toString().trim();
    if (langs.isEmpty) return "English";
    return langs
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(" · ");
  }

  String? get photoUrl {
    final data = guideData;
    final photo = (data['photo'] ?? '').toString().trim();
    if (photo.isEmpty) return null;
    return "$assetBaseUrl$photo";
  }

  Future<bool> validateCurrentSession() async {
    if (sessionToken.isEmpty || guideId == 0) {
      return false;
    }

    final deviceString = await DeviceService.getOrCreateDeviceId();

    try {
      final response = await _apiService.validateSession(
        guideId: guideId,
        contactNumber: savedPhone,
        sessionToken: sessionToken,
        deviceString: deviceString,
      );

      if (response.statusCode == 200 && response.body['success'] == true) {
        if (response.body['data'] != null) {
          _box.write(_guideDataKey, response.body['data']);
        }
        return true;
      }
    } catch (_) {}

    clearSession();
    return false;
  }

  // POST /auth/logout: End session, destroy session_token (device binding stays)
  Future<void> logout() async {
    try {
      if (sessionToken.isNotEmpty && guideId != 0) {
        await _apiService.logout(
          guideId: guideId,
          contactNumber: savedPhone,
          sessionToken: sessionToken,
        );
      }
    } catch (_) {}

    clearSession();
  }
}
