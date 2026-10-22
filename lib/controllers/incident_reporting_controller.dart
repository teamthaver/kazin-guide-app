import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/db_service.dart';
import 'package:kazin_guide_app/core/services/network_sync_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class IncidentReportingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final DbService _dbService = DbService.instance;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> categoryMap = const {
    "Operational": "operational",
    "Incident": "incident",
    "Lost & Found": "lost_found",
    "Other": "other",
  };

  final selectedCategoryKey = "Operational".obs;
  final selectedSeverity = "Normal".obs;

  final issueCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();

  final attachedImages = <File>[].obs;
  final isSubmitting = false.obs;

  @override
  void onClose() {
    issueCtrl.dispose();
    locationCtrl.dispose();
    remarkCtrl.dispose();
    super.onClose();
  }

  void clearForm() {
    issueCtrl.clear();
    locationCtrl.clear();
    remarkCtrl.clear();
    attachedImages.clear();
    selectedCategoryKey.value = "Operational";
    selectedSeverity.value = "Normal";
  }

  void setCategory(String categoryKey) {
    selectedCategoryKey.value = categoryKey;
  }

  void setSeverity(String severity) {
    selectedSeverity.value = severity;
  }

  Future<void> pickImage(ImageSource source) async {
    if (attachedImages.length >= 5) {
      Get.snackbar(
        "Limit Reached",
        "Maximum 5 images allowed per report.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file != null) {
        attachedImages.add(File(file.path));
      }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Unable to select image.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < attachedImages.length) {
      attachedImages.removeAt(index);
    }
  }

  Future<void> submitReport() async {
    final arrivalCtrl = Get.find<ArrivalController>();
    final activeFile = arrivalCtrl.activeTourFile.value;

    if (activeFile == null) {
      Get.snackbar(
        "Error",
        "No active tour assignment found.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (issueCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Missing Details",
        "Please describe what happened.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final now = DateTime.now();
    final dateStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final categoryCode = categoryMap[selectedCategoryKey.value] ?? "other";
    final issueDesc = issueCtrl.text.trim();
    final locationText = locationCtrl.text.trim().isEmpty
        ? null
        : locationCtrl.text.trim();
    final remarkText = remarkCtrl.text.trim().isEmpty
        ? null
        : remarkCtrl.text.trim();

    isSubmitting.value = true;

    final bool isOnline = Get.isRegistered<NetworkSyncService>()
        ? Get.find<NetworkSyncService>().isOnline.value
        : true;

    try {
      if (isOnline) {
        final response = await _apiService.reportIssue(
          arrivalId: activeFile.arrivalId,
          category: categoryCode,
          incidentDate: dateStr,
          incidentTime: timeStr,
          issue: issueDesc,
          location: locationText,
          remark: remarkText,
          imageFiles: attachedImages.toList(),
        );

        // 200 ya 201 dono success mane jayenge
        if (response.isOk && response.body?['success'] == true) {
          clearForm();
          Get.back();
          Get.snackbar(
            "Issue Reported",
            response.body?['message'] ?? "Issue reported to operations.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KazinColors.greenAcceptedBg,
            colorText: KazinColors.greenAcceptedText,
          );
          return;
        }
      }

      // Offline ya server failure fallback
      await _queueIssueOffline(
        activeFile.arrivalId,
        categoryCode,
        dateStr,
        timeStr,
        issueDesc,
        locationText,
        remarkText,
      );
    } catch (_) {
      await _queueIssueOffline(
        activeFile.arrivalId,
        categoryCode,
        dateStr,
        timeStr,
        issueDesc,
        locationText,
        remarkText,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _queueIssueOffline(
    int arrivalId,
    String category,
    String incidentDate,
    String incidentTime,
    String issue,
    String? location,
    String? remark,
  ) async {
    await _dbService.queueOfflineAction(
      actionType: 'report_issue',
      payload: {
        'arrival_id': arrivalId,
        'category': category,
        'incident_date': incidentDate,
        'incident_time': incidentTime,
        'issue': issue,
        'location': location,
        'remark': remark,
      },
      imagePaths: attachedImages.map((f) => f.path).toList(),
    );

    clearForm();
    Get.back();
    Get.snackbar(
      "Saved Offline",
      "Issue logged locally. Will sync when back online.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      icon: const Icon(Icons.cloud_off_rounded, color: Colors.white),
    );
  }
}