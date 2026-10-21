import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:kazin_guide_app/screens/assignments/assignment_details_screen.dart';

class AssignmentsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final ArrivalController arrivalCtrl = Get.find<ArrivalController>();
  final ApiService _apiService = Get.find<ApiService>();

  final selectedTabIndex = 0.obs;
  final isActionLoading = false.obs;

  final upcomingFilesList = <TourFileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });
  }

  TourFileModel? get activeFile => arrivalCtrl.activeTourFile.value;
  bool get isLoading => arrivalCtrl.isLoading.value;

  List<TourFileModel> get activeAssignments {
    final file = activeFile;
    if (file == null) return [];
    final status = file.status.toLowerCase();
    if (status.contains("active") ||
        status.contains("live") ||
        status.contains("assigned")) {
      return [file];
    }
    return [];
  }

  List<TourFileModel> get upcomingAssignments => upcomingFilesList;

  List<TourFileModel> get completedAssignments {
    final file = activeFile;
    if (file == null) return [];
    final status = file.status.toLowerCase();
    if (status.contains("closed") || status.contains("completed")) {
      return [file];
    }
    return [];
  }

  void addUpcomingAssignment(TourFileModel file) {
    if (!upcomingFilesList.any((f) => f.arrivalId == file.arrivalId)) {
      upcomingFilesList.add(file);
    }
  }

  Future<void> refreshAssignments() async {
    await arrivalCtrl.loadArrivalData();
  }

  void openLiveService(TourFileModel file) {
    arrivalCtrl.resetToToday();
    Get.toNamed(Routes.LIVE_SERVICE);
  }

  void viewDossier(TourFileModel file) {
    Get.to(() => AssignmentDetailsScreen(tourFile: file));
  }

  bool isFileClosed(TourFileModel file) {
    final status = file.status.toLowerCase();
    return status.contains("closed") || status.contains("completed");
  }

  // --- POST /api/action/accept-file ---
  // lib/controllers/assignments_controller.dart

  Future<bool> acceptTourFile(TourFileModel file) async {
    isActionLoading.value = true;
    try {
      final response = await _apiService.acceptFile(
        enquiryId: file.enquiryId,
        arrivalId: file.arrivalId,
      );

      if (response.statusCode == 200 && response.body?['success'] == true) {
        Get.snackbar(
          "Assignment Accepted",
          response.body?['message'] ?? "File accepted successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.greenAcceptedBg,
          colorText: KazinColors.greenAcceptedText,
        );
        await refreshAssignments();
        return true; // Success hone par true return karein
      } else {
        // final message = response.body?['message'] ?? "Unable to accept file.";
        // Get.snackbar("Notice", message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Network connection failed.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // --- POST /api/action/reject-file Dialog & Execution ---
  void showRejectDialog(TourFileModel file) {
    String selectedReason = 'schedule_conflict';
    final otherReasonCtrl = TextEditingController();
    final isOtherSelected = false.obs;

    Get.defaultDialog(
      title: "Decline Assignment",
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: KazinColors.primaryNavy,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: StatefulBuilder(
        builder: (context, setLocalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please select a reason for declining this assignment:",
                style: TextStyle(
                  fontSize: 13,
                  color: KazinColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: InputDecoration(
                  labelText: "Decline Reason",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'schedule_conflict',
                    child: Text("Schedule Conflict"),
                  ),
                  DropdownMenuItem(
                    value: 'unavailable',
                    child: Text("Unavailable"),
                  ),
                  DropdownMenuItem(
                    value: 'location_issue',
                    child: Text("Location Issue"),
                  ),
                  DropdownMenuItem(value: 'other', child: Text("Other")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setLocalState(() {
                      selectedReason = val;
                      isOtherSelected.value = (val == 'other');
                    });
                  }
                },
              ),
              Obx(
                () => isOtherSelected.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextField(
                          controller: otherReasonCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "Specify reason...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.all(10),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: KazinColors.redDanger,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          if (selectedReason == 'other' &&
              otherReasonCtrl.text.trim().isEmpty) {
            Get.snackbar(
              "Missing Reason",
              "Please specify your reason for declining.",
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
          Get.back();
          await _performReject(
            file: file,
            declineReason: selectedReason,
            mentionedReason: otherReasonCtrl.text.trim(),
          );
        },
        child: const Text(
          "Decline File",
          style: TextStyle(color: Colors.white),
        ),
      ),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  Future<void> _performReject({
    required TourFileModel file,
    required String declineReason,
    String? mentionedReason,
  }) async {
    isActionLoading.value = true;
    try {
      final response = await _apiService.rejectFile(
        enquiryId: file.enquiryId,
        arrivalId: file.arrivalId,
        declineReason: declineReason,
        mentionedReason: mentionedReason,
      );

      if (response.statusCode == 200 && response.body?['success'] == true) {
        Get.snackbar(
          "Declined",
          response.body?['message'] ?? "Assignment declined.",
          snackPosition: SnackPosition.BOTTOM,
        );
        await refreshAssignments();
      } else {
        final message = response.body?['message'] ?? "Unable to decline file.";
        Get.snackbar("Notice", message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Network connection failed.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
