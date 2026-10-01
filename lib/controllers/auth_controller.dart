import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  final AuthService _authService = Get.find<AuthService>();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());

  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final currentGuideId = 0.obs;

  // Step 1: Login API
  Future<void> submitLogin() async {
    final contact = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (contact.isEmpty) {
      _showLocalValidationError("Mobile Number cannot be empty.");
      return;
    }
    if (password.isEmpty) {
      _showLocalValidationError("Password cannot be empty.");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.login(
        contactNumber: contact,
        password: password,
      );

      log("Submit login Response: ${response.body}");

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        currentGuideId.value = response.body['guide_id'] ?? 0;
        isOtpSent.value = true;

        Get.snackbar(
          "Verified",
          response.body['message'] ?? "Credentials Verified",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.secondaryTeal,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );

        Future.delayed(const Duration(milliseconds: 200), () {
          otpFocusNodes[0].requestFocus();
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Step 2: Verify OTP API
  Future<void> submitVerifyOtp() async {
    final otp = otpControllers.map((c) => c.text.trim()).join();
    if (otp.length < 6) {
      _showLocalValidationError("Please enter complete 6-digit OTP");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.verifyOtp(
        guideId: currentGuideId.value,
        contactNumber: phoneController.text.trim(),
        otp: otp,
      );

      log("Submit Verify OTP Response: ${response.body}");

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        _authService.saveLoginSession(
          guideId: currentGuideId.value,
          phone: phoneController.text.trim(),
          guideData: response.body['data'] is Map
              ? response.body['data']
              : null,
        );
        Get.offAllNamed(Routes.NAVIGATION_SHELL);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    if (otpControllers.every((c) => c.text.isNotEmpty)) {
      submitVerifyOtp();
    }
  }

  void _showLocalValidationError(String message) {
    Get.snackbar(
      "Validation Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: KazinColors.amberWarningBg,
      colorText: KazinColors.amberWarningText,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
