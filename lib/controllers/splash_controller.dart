import 'dart:async';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/services/auth_service/auth_service.dart';
import '../core/routes/app_pages.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _startRoutingTimer();
  }

  void _startRoutingTimer() {
    Timer(const Duration(seconds: 2), () {
      if (_authService.isLoggedIn.value) {
        Get.offAllNamed(Routes.NAVIGATION_SHELL);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }
}