import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  late final GetStorage _box;
  final isLoggedIn = false.obs;

  static const String _authKey = 'is_authenticated';
  static const String _userPhoneKey = 'user_phone';

  Future<AuthService> init() async {
    _box = GetStorage();
    isLoggedIn.value = _box.read<bool>(_authKey) ?? false;
    return this;
  }

  void saveLoginSession(String phone) {
    _box.write(_authKey, true);
    _box.write(_userPhoneKey, phone);
    isLoggedIn.value = true;
  }

  void clearSession() {
    _box.remove(_authKey);
    _box.remove(_userPhoneKey);
    isLoggedIn.value = false;
  }

  String get savedPhone => _box.read<String>(_userPhoneKey) ?? "";
}