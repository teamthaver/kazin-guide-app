import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/device_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ApiService extends GetConnect {
  static const String baseUrlEndpoint = "https://kazin.thavertech.com";

  @override
  void onInit() {
    httpClient.baseUrl = baseUrlEndpoint;
    httpClient.timeout = const Duration(seconds: 30);

    // 1. Centralised Request Modifier (Injecting Documented Headers)
    httpClient.addRequestModifier<dynamic>((request) async {
      request.headers['Accept'] = 'application/json';

      // Inject custom auth headers if guide is authenticated
      if (Get.isRegistered<AuthService>()) {
        final auth = Get.find<AuthService>();
        if (auth.guideId > 0 && auth.sessionToken.isNotEmpty) {
          // request.headers['x-guide-id'] = '4';
          request.headers['x-guide-id'] = auth.guideId.toString();
          request.headers['x-session-token'] = auth.sessionToken;
          final deviceId = await DeviceService.getOrCreateDeviceId();
          request.headers['x-device-string'] = deviceId;
        }
      }

      log('🌐 [HTTP REQUEST] ${request.method} -> ${request.url}');
      log('📋 [HEADERS] ${request.headers}');
      return request;
    });

    // 2. Centralised Response Modifier (Auto 401 Session Clearance)
    httpClient.addResponseModifier((request, response) {
      log(
        '📥 [HTTP RESPONSE] ${request.method} ${request.url} | Status: ${response.statusCode}',
      );
      try {
        log('📦 [HTTP BODY] ${jsonEncode(response.body)}');
      } catch (_) {
        log('📦 [HTTP BODY (raw)] ${response.bodyString}');
      }

      _handleCentralizedError(response);
      return response;
    });

    super.onInit();
  }

  void _handleCentralizedError(Response response) {
    if (response.isOk) return;

    // 401 Session Invalid Handler
    if (response.statusCode == 401) {
      final code = response.body is Map ? response.body['code'] : null;
      if (code == 'SESSION_INVALID' ||
          response.body?['message']?.toString().contains('Session expired') ==
              true) {
        log('🚨 [401 SESSION_INVALID] Clearing session & routing to LOGIN...');
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().clearSession();
        }
        Get.offAllNamed(Routes.LOGIN);
        _showErrorSnackbar(
          "Session Expired",
          "Session expired or logged in on another device. Please log in again.",
        );
        return;
      }
    }

    if (response.status.connectionError) {
      _showErrorSnackbar(
        "No Internet",
        "Unable to connect to Kazin servers. Showing offline cached data.",
      );
      return;
    }

    // 400, 403, 404 - Server messages are directly human readable for guides
    switch (response.statusCode) {
      case 400:
        // Do not block snackbar if it's delay reason prompt (handled in controller)
        if (response.body is Map &&
            response.body['message'] == "Provide delay reason.") {
          return;
        }
        final message = _extractErrorMessage(
          response,
          "Invalid request. Missing parameters.",
        );
        _showErrorSnackbar("Action Alert", message);
        break;

      case 403:
        final message = _extractErrorMessage(
          response,
          "Guide assignment mismatch or permission denied.",
        );
        _showErrorSnackbar("Access Denied", message);
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
      duration: const Duration(seconds: 1),
      isDismissible: true,
    );
  }

  // Helper to determine exact image MIME type for backend Multer verification
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  // ==========================================
  // AUTH APIS
  // ==========================================

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

  Future<Response> loadChecklist({required int arrivalId}) {
    final payload = {"arrival_id": arrivalId};
    return post('/api/action/checklist', payload);
  }

  Future<Response> markChecklistItem({
    required int checklistId,
    bool checked = true,
  }) {
    final payload = {"checklist_id": checklistId, "checked": checked};
    return post('/api/action/checklist/mark', payload);
  }

  Future<Response> loadAlertData({required int guideId}) {
    return post("/api/guide/alert", {"guide_id": guideId});
  }

  Future<Response> loadUpcomingDetails({required int arrivalId}) {
    return post("/api/guide/upcoming-details", {"arrival_id": arrivalId});
  }

  Future<Response> loadArrivalData({required int guideId}) {
    return post("/api/guide/arrival", {"guide_id": guideId});
  }

  Future<Response> loadUpcommingData({required int guideId}) {
    return post("/api/guide/upcoming", {"guide_id": guideId});
  }

  Future<Response> loadCompletedData({required int guideId}) {
    return post("/api/guide/completed", {"guide_id": guideId});
  }

  // ==========================================
  // ACTION APIS (AS PER SPECIFICATION DOCUMENT)
  // ==========================================

  Future<Response> acceptFile({
    required int enquiryId,
    required int arrivalId,
  }) {
    final payload = {"enquiry_id": enquiryId, "arrival_id": arrivalId};
    log('📤 [ACTION ACCEPT FILE]: $payload');
    return post('/api/action/accept-file', payload);
  }

  Future<Response> rejectFile({
    required int enquiryId,
    required int arrivalId,
    required String declineReason,
    String? mentionedReason,
  }) {
    final payload = {
      "enquiry_id": enquiryId,
      "arrival_id": arrivalId,
      "decline_reason": declineReason,
      if (declineReason == "other" && mentionedReason != null)
        "mentioned_reason": mentionedReason,
    };
    log('📤 [ACTION REJECT FILE]: $payload');
    return post('/api/action/reject-file', payload);
  }

  Future<Response> markCompleted({
    required int itineraryId,
    required int arrivalId,
    required String currentTime,
    String? delayReason,
    File? imageFile,
  }) {
    final Map<String, dynamic> fields = {
      'itinerary_id': itineraryId.toString(),
      'arrival_id': arrivalId.toString(),
      'current_time': currentTime,
      if (delayReason != null && delayReason.trim().isNotEmpty)
        'delay_reason': delayReason.trim(),
    };

    final form = FormData(fields);

    if (imageFile != null) {
      final mime = _getMimeType(imageFile.path);
      form.files.add(
        MapEntry(
          'image',
          MultipartFile(
            imageFile,
            filename: imageFile.path.split('/').last,
            contentType: mime,
          ),
        ),
      );
    }

    log(
      '📤 [ACTION MARK COMPLETED]: fields=$fields, hasImage=${imageFile != null}',
    );
    return post('/api/action/mark-completed', form);
  }

  Future<Response> addExpense({
    required int arrivalId,
    required String category,
    required String currency,
    required double spent,
    double saved = 0.0,
    String? remarks,
    List<File> receiptFiles = const [],
  }) {
    final Map<String, dynamic> fields = {
      'arrival_id': arrivalId.toString(),
      'category': category.toLowerCase(),
      'currency': currency.toUpperCase(),
      'spent': spent.toStringAsFixed(2),
      'saved': saved.toStringAsFixed(2),
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    };

    final form = FormData(fields);

    for (var file in receiptFiles.take(5)) {
      final mime = _getMimeType(file.path);
      form.files.add(
        MapEntry(
          'receipt',
          MultipartFile(
            file,
            filename: file.path.split('/').last,
            contentType: mime,
          ),
        ),
      );
    }

    log(
      '📤 [ACTION ADD EXPENSE]: fields=$fields, receipts=${receiptFiles.length}',
    );
    return post('/api/action/add-expense', form);
  }

  Future<Response> reportIssue({
    required int arrivalId,
    required String category,
    required String incidentDate,
    required String incidentTime,
    required String issue,
    String? location,
    String? remark,
    List<File> imageFiles = const [],
  }) {
    final Map<String, dynamic> fields = {
      'arrival_id': arrivalId.toString(),
      'category': category.toLowerCase(),
      'incident_date': incidentDate,
      'incident_time': incidentTime,
      'issue': issue,
      if (location != null && location.isNotEmpty) 'location': location,
      if (remark != null && remark.isNotEmpty) 'remark': remark,
    };

    final form = FormData(fields);

    for (var file in imageFiles.take(5)) {
      final mime = _getMimeType(file.path);
      form.files.add(
        MapEntry(
          'image',
          MultipartFile(
            file,
            filename: file.path.split('/').last,
            contentType: mime,
          ),
        ),
      );
    }

    log(
      '📤 [ACTION REPORT ISSUE]: fields=$fields, images=${imageFiles.length}',
    );
    return post('/api/action/report-issue', form);
  }

  // POST /save-fcm-token (Backend par guide ka token save karne ke liye)
  Future<Response> saveFcmToken(String fcmToken) async {
    return await post('/api/action/save-fcm-token', {'fcm_token': fcmToken});
  }
}
