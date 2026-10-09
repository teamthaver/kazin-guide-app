import 'dart:convert';
import 'dart:developer';
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

    // Request Interceptor with Logging
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';
      log('🌐 [HTTP REQUEST] ${request.method} -> ${request.url}');
      return request;
    });

    // Response Interceptor with Logging
    httpClient.addResponseModifier((request, response) {
      log(
        '📥 [HTTP RESPONSE] ${request.method} ${request.url} | Status: ${response.statusCode}',
      );
      log('📦 [HTTP BODY] ${jsonEncode(response.body)}');
      _handleCentralizedError(response);
      return response;
    });

    super.onInit();
  }

  // --- Centralised Error Dispatcher ---
  void _handleCentralizedError(Response response) {
    if (response.isOk) {
      if (response.body is Map && response.body['success'] == false) {
        final String message =
            response.body['message'] ?? "Something went wrong.";
        _showErrorSnackbar("Operation Failed", message);
      }
      return;
    }

    if (response.status.connectionError) {
      _showErrorSnackbar(
        "No Internet",
        "Unable to connect to Kazin servers. Showing offline cached data.",
      );
      return;
    }

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
    required String deviceString,
  }) {
    final payload = {
      "contact_number": contactNumber,
      "password": password,
      "device_string": deviceString,
    };
    log('📤 [AUTH LOGIN PAYLOAD]: $payload');
    return post('/api/auth/login', payload);
  }

  Future<Response> verifyOtp({
    required int guideId,
    required String contactNumber,
    required String otp,
  }) {
    final payload = {
      "guide_id": guideId,
      "contact_number": contactNumber,
      "otp": otp,
    };
    log('📤 [AUTH VERIFY OTP PAYLOAD]: $payload');
    return post('/api/auth/verify-otp', payload);
  }

  Future<Response> validateSession({
    required int guideId,
    required String contactNumber,
    required String sessionToken,
    required String deviceString,
  }) {
    final payload = {
      "guide_id": guideId,
      "contact_number": contactNumber,
      "sessionToken": sessionToken,
      "device_string": deviceString,
    };
    log('📤 [AUTH VALIDATE PAYLOAD]: $payload');
    return post('/api/auth/validate', payload);
  }

  Future<Response> logout({
    required int guideId,
    required String contactNumber,
    required String sessionToken,
  }) {
    final payload = {
      "guide_id": guideId,
      "contact_number": contactNumber,
      "sessionToken": sessionToken,
    };
    log('📤 [AUTH LOGOUT PAYLOAD]: $payload');
    return post('/api/auth/logout', payload);
  }

  Future<Response> loadArrivalData({required int guideId}) {
    return post("/api/guide/arrival", {"guide_id": guideId});
  }
}
