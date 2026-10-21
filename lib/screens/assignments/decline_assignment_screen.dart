import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/controllers/notifications_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class DeclineAssignmentScreen extends StatelessWidget {
  const DeclineAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final TourFileModel? file = args?["tourFile"];
    final apiService = Get.find<ApiService>();

    final reasonCtrl = TextEditingController();

    // Document-compliant decline reason mapping
    final Map<String, String> reasonOptions = const {
      "Schedule Conflict": "schedule_conflict",
      "Unavailable on these dates": "unavailable",
      "Location Issue": "location_issue",
      "Other reason": "other",
    };

    final selectedLabel = "Schedule Conflict".obs;
    final isSubmitting = false.obs;

    if (file == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Decline Assignment")),
        body: const Center(child: Text("No assignment file provided.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Decline Assignment",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KazinColors.scaffoldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KazinColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 20,
                    color: KazinColors.primaryNavy,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FILE #${file.enquiryNo}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${file.leadName} (${file.numberPersons} PAX)",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: KazinColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Select Reason for Decline *",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedLabel.value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: KazinColors.borderSubtle,
                    ),
                  ),
                ),
                items: reasonOptions.keys
                    .map(
                      (label) => DropdownMenuItem(
                        value: label,
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedLabel.value = val;
                },
              ),
            ),
            const SizedBox(height: 18),

            Obx(() {
              final isOther = reasonOptions[selectedLabel.value] == "other";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOther
                        ? "Specific Reason (Compulsory for 'Other') *"
                        : "Additional Explanation (Optional)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: isOther
                          ? "Please specify the exact reason..."
                          : "Provide optional notes for the dispatch team...",
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: KazinColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: KazinColors.borderSubtle,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: KazinColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 28),

            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.redDanger,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting.value
                    ? null
                    : () async {
                        final rawCode =
                            reasonOptions[selectedLabel.value] ?? "other";
                        final explanation = reasonCtrl.text.trim();

                        // Document validation rule: other ke saath explanation zaroori hai
                        if (rawCode == "other" && explanation.isEmpty) {
                          Get.snackbar(
                            "Reason Required",
                            "Please provide details when selecting 'Other reason'.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: KazinColors.redDanger,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        isSubmitting.value = true;
                        try {
                          final response = await apiService.rejectFile(
                            enquiryId: file.enquiryId,
                            arrivalId: file.arrivalId,
                            declineReason: rawCode,
                            mentionedReason: explanation.isEmpty
                                ? null
                                : explanation,
                          );

                          if (response.statusCode == 200 &&
                              response.body?['success'] == true) {
                            // 1. Remove from notifications list
                            if (Get.isRegistered<NotificationsController>()) {
                              Get.find<NotificationsController>()
                                  .removeAssignmentNotification();
                            }

                            // 2. Remove unread notification badge
                            if (Get.isRegistered<KazinController>()) {
                              Get.find<KazinController>()
                                      .hasUnreadAlerts
                                      .value =
                                  false;
                            }

                            // 3. Refresh live arrivals data
                            if (Get.isRegistered<ArrivalController>()) {
                              Get.find<ArrivalController>().loadArrivalData();
                            }

                            // 4. Return back to navigation shell
                            Get.until(
                              (route) =>
                                  route.settings.name ==
                                      Routes.NAVIGATION_SHELL ||
                                  route.isFirst,
                            );

                            Get.snackbar(
                              "Assignment Declined",
                              response.body?['message'] ??
                                  "File #${file.enquiryNo} declined successfully.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.white,
                              colorText: KazinColors.redDanger,
                            );
                          }
                          // else {
                          //   final msg =
                          //       response.body?['message'] ??
                          //       "Failed to decline assignment.";
                          //   Get.snackbar(
                          //     "Decline Failed",
                          //     msg,
                          //     snackPosition: SnackPosition.BOTTOM,
                          //     backgroundColor: KazinColors.redDanger,
                          //     colorText: Colors.white,
                          //   );
                          // }
                        } catch (_) {
                          Get.snackbar(
                            "Network Error",
                            "Unable to communicate with Kazin server.",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } finally {
                          isSubmitting.value = false;
                        }
                      },
                child: isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Confirm & Decline Assignment",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
