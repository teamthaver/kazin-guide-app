import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ApiService extends GetConnect {
  static const String baseUrlEndpoint = "https://kazin.thavertech.com";

  @override
  void onInit() {
    httpClient.baseUrl = baseUrlEndpoint;
    httpClient.timeout = const Duration(seconds: 20);

    // 1. Request Interceptor (Logging / Common Headers)
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    // 2. Centralised Response & Error Interceptor
    httpClient.addResponseModifier((request, response) {
      _handleCentralizedError(response);
      return response;
    });

    super.onInit();
  }

  // --- Centralised Error Dispatcher ---
  void _handleCentralizedError(Response response) {
    // Agar request successfully 200 OK hai aur server response body me success: true hai, toh skip karein
    if (response.isOk) {
      if (response.body is Map && response.body['success'] == false) {
        final String message =
            response.body['message'] ?? "Something went wrong.";
        _showErrorSnackbar("Operation Failed", message);
      }
      return;
    }

    // Network disconnection / Socket timeout
    if (response.status.connectionError) {
      _showErrorSnackbar(
        "No Internet",
        "Unable to connect to Kazin servers. Showing offline cached data.",
      );
      return;
    }

    // HTTP Status Codes Mapping (Documentation section 5 ke hisaab se)
    switch (response.statusCode) {
      case 400:
        final message = _extractErrorMessage(
          response,
          "Invalid request. Missing parameters.",
        );
        _showErrorSnackbar("Validation Error", message);
        break;

      case 403:
        final message = _extractErrorMessage(
          response,
          "Guide assignment mismatch or session expired.",
        );
        _showErrorSnackbar("Access Denied", message);
        // Force logout if session invalid on server
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().clearSession();
          Get.offAllNamed(Routes.LOGIN);
        }
        break;

      case 404:
        final message = _extractErrorMessage(
          response,
          "Requested record or guide not found.",
        );
        _showErrorSnackbar("Not Found", message);
        break;

      case 500:
      default:
        final message = _extractErrorMessage(
          response,
          "Server error. Please try again later.",
        );
        _showErrorSnackbar("Server Error", message);
        break;
    }
  }

  String _extractErrorMessage(Response response, String fallback) {
    try {
      if (response.body is Map && response.body['message'] != null) {
        return response.body['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }

  void _showErrorSnackbar(String title, String message) {
    // Duplicate snackbars avoid karne ke liye
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: KazinColors.redDanger,
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
        size: 24,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      isDismissible: true,
    );
  }

  // --- Auth APIs ---
  Future<Response> login({
    required String contactNumber,
    required String password,
  }) {
    return post('/api/auth/login', {
      "contact_number": contactNumber,
      "password": password,
    });
  }

  Future<Response> verifyOtp({
    required int guideId,
    required String contactNumber,
    required String otp,
  }) {
    return post('/api/auth/verify-otp', {
      "guide_id": guideId,
      "contact_number": contactNumber,
      "otp": otp,
    });
  }

  Future<Response> logout({
    required int guideId,
    required String contactNumber,
  }) {
    return post('/api/auth/logout', {
      "guide_id": guideId,
      "contact_number": contactNumber,
    });
  }

  Future<Response> loadArrivalData({required int guideId}) {
    return post("/api/guide/arrival", {"guide_id": guideId});
  }
}
