import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class IncidentReportingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  // Document allowed categories mapping
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

    isSubmitting.value = true;
    try {
      final response = await _apiService.reportIssue(
        arrivalId: activeFile.arrivalId,
        category: categoryMap[selectedCategoryKey.value] ?? "other",
        incidentDate: dateStr,
        incidentTime: timeStr,
        issue: issueCtrl.text.trim(),
        location: locationCtrl.text.trim().isEmpty
            ? null
            : locationCtrl.text.trim(),
        remark: remarkCtrl.text.trim().isEmpty ? null : remarkCtrl.text.trim(),
        imageFiles: attachedImages.toList(),
      );

      if (response.statusCode == 201 && response.body?['success'] == true) {
        Get.back();
        Get.snackbar(
          "Issue Reported",
          response.body?['message'] ?? "Issue reported to operations.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.greenAcceptedBg,
          colorText: KazinColors.greenAcceptedText,
        );
      } else {
        final message = response.body?['message'] ?? "Failed to report issue.";
        Get.snackbar(
          "Submission Failed",
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Network connection failed.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
