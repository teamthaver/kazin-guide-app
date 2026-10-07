import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/notifications_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class DeclineAssignmentScreen extends StatelessWidget {
  const DeclineAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final TourFileModel? file = args?["tourFile"];

    final reasonCtrl = TextEditingController();
    final selectedReason = "Unavailable on these dates".obs;

    final reasons = [
      "Unavailable on these dates",
      "Personal emergency / Leave",
      "Conflict with prior assignment",
      "Language/Profile mismatch",
      "Vehicle / Logistics constraint",
      "Other reasons",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            if (file != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KazinColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 18,
                      color: KazinColors.primaryNavy,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "File #${file.enquiryNo} - ${file.leadName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              "Select Reason for Dispatch",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedReason.value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: reasons
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: const TextStyle(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedReason.value = val;
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Additional Explanation (Required)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Provide details for the operations team...",
                hintStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KazinColors.redDanger,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // 1. Remove from notifications screen
                if (Get.isRegistered<NotificationsController>()) {
                  Get.find<NotificationsController>()
                      .removeAssignmentNotification();
                }

                // 2. Remove red dot badge
                if (Get.isRegistered<KazinController>()) {
                  Get.find<KazinController>().hasUnreadAlerts.value = false;
                }

                // 3. Return back to navigation shell
                Get.until(
                  (route) =>
                      route.settings.name == Routes.NAVIGATION_SHELL ||
                      route.isFirst,
                );

                Get.snackbar(
                  "Assignment Declined",
                  "File #${file?.enquiryNo ?? ''} rejected. Logged with Kazin Dispatch.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.white,
                  colorText: KazinColors.redDanger,
                );
              },
              child: const Text("Confirm & Submit to Dispatch"),
            ),
          ],
        ),
      ),
    );
  }
}
