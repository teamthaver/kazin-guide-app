import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/device_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  final tempGuideId = RxnInt();

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

  void onOtpDigitChanged(int index, String val) {
    if (val.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  String get enteredOtp => otpControllers.map((c) => c.text.trim()).join();

  Future<void> submitLogin() async {
    final contact = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (contact.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Missing Details",
        "Please enter contact number and password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final deviceId = await DeviceService.getOrCreateDeviceId();
      log('📱 Device ID generated/retrieved: $deviceId');

      final response = await _apiService.login(
        contactNumber: contact,
        password: password,
        deviceString: deviceId,
      );

      log('🔍 Login Status Code: ${response.statusCode}');
      log('🔍 Login Body: ${jsonEncode(response.body)}');

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['success'] == true) {
        tempGuideId.value = response.body['guide_id'];
        isOtpSent.value = true;
        log('✅ Login successful! tempGuideId: ${tempGuideId.value}');

        Future.delayed(const Duration(milliseconds: 150), () {
          if (otpFocusNodes.isNotEmpty) {
            otpFocusNodes[0].requestFocus();
          }
        });
      } else {
        String errorMessage =
            "Server error (${response.statusCode}). Please try again later.";

        // Safe check: Body Map hai ya nahi
        if (response.body is Map && response.body['message'] != null) {
          errorMessage = response.body['message'].toString();
        } else if (response.statusCode == 502 || response.statusCode == 503) {
          errorMessage =
              "Server is currently unavailable (502 Bad Gateway). Please contact support.";
        }

        Get.snackbar(
          "Login Failed",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      log('🔥 Error in submitLogin: $e', stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Unable to connect to authentication server",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitVerifyOtp() async {
    final otp = enteredOtp;
    if (otp.length < 6) {
      Get.snackbar(
        "Incomplete Code",
        "Please enter the complete 6-digit verification code",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.verifyOtp(
        guideId: tempGuideId.value ?? 0,
        contactNumber: phoneController.text.trim(),
        otp: otp,
      );

      log('🔍 Verify OTP Status Code: ${response.statusCode}');
      log('🔍 Verify OTP Body: ${jsonEncode(response.body)}');

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['success'] == true) {
        final token = response.body['sessionToken'] ?? '';
        final guideData = response.body['data'] ?? response.body['guide'];

        log('🔑 Session Token Received: $token');
        log('👤 Guide Profile Data: ${jsonEncode(guideData)}');

        _authService.saveLoginSession(
          guideId: tempGuideId.value!,
          phone: phoneController.text.trim(),
          sessionToken: token,
          guideData: guideData != null
              ? Map<String, dynamic>.from(guideData)
              : null,
        );

        if (Get.isRegistered<KazinController>()) {
          Get.find<KazinController>().currentBottomNavIndex.value = 0;
        }

        Get.offAllNamed(Routes.NAVIGATION_SHELL);
      } else {
        final message = response.body?['message'] ?? "Invalid or expired OTP.";
        log('❌ OTP Verification failed message: $message');
        Get.snackbar(
          "Verification Failed",
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      log('🔥 Error in submitVerifyOtp: $e', stackTrace: stackTrace);
      Get.snackbar(
        "Error",
        "Failed to verify code. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
