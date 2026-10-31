import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/fcm_service.dart';

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
  static const String assetBaseUrl = "https://crm.kazindmc.com/assets/guide/";

  Future<AuthService> init() async {
    _box = GetStorage();
    isLoggedIn.value = _box.read<bool>(_authKey) ?? false;

    // App launch par API sync call nahi karni (sirf FCM topic subscribe hoga)
    if (isLoggedIn.value && guideId > 0) {
      if (Get.isRegistered<FcmService>()) {
        Get.find<FcmService>().subscribeToGuideTopic(guideId);
      }
    }

    return this;
  }

  // --- Session Storage ---
  void saveLoginSession({
    required int guideId,
    required String phone,
    required String sessionToken,
    Map<String, dynamic>? guideData,
  }) {
    // 1. Pehle storage me credentials save karein
    _box.write(_authKey, true);
    _box.write(_guideIdKey, guideId);
    _box.write(_userPhoneKey, phone);
    _box.write(_sessionTokenKey, sessionToken);
    if (guideData != null) {
      _box.write(_guideDataKey, guideData);
    }
    isLoggedIn.value = true;

    // 2. Login successful hone ke baad hi FCM topic subscribe aur backend token sync karein
    if (Get.isRegistered<FcmService>()) {
      Get.find<FcmService>().subscribeToGuideTopic(guideId);
      Get.find<FcmService>().syncTokenWithBackend();
    }
  }

  void clearSession() {
    final int currentGuideId = guideId;
    if (Get.isRegistered<FcmService>() && currentGuideId > 0) {
      Get.find<FcmService>().unsubscribeFromGuideTopic(currentGuideId);
    }

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
    return true;
  }

  // POST /auth/logout
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
