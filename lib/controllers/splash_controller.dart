import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Validates: Session active, token matches guide, device_string matches
    final isValid = await _authService.validateCurrentSession();

    if (isValid) {
      Get.offAllNamed(Routes.NAVIGATION_SHELL);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
