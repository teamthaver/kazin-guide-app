import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/services/auth_service/auth_service.dart';
import '../core/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final phoneController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());

  final isOtpSent = false.obs;
  final isLoading = false.obs;

  void sendOtp() {
    final phone = phoneController.text.trim();
    if (phone.length < 10) {
      Get.snackbar(
        "Validation",
        "Please enter a valid mobile number",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isOtpSent.value = true;
    otpFocusNodes[0].requestFocus();
  }

  void verifyOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      Get.snackbar(
        "Verification Failed",
        "Please enter complete 6-digit code",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      isLoading.value = false;
      _authService.saveLoginSession(phoneController.text.trim());
      Get.offAllNamed(Routes.NAVIGATION_SHELL);
    });
  }

  void onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    if (otpControllers.every((c) => c.text.isNotEmpty)) {
      verifyOtp();
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}