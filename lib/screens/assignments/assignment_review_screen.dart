import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/controllers/notifications_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/assignment_summary_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentReviewScreen extends StatelessWidget {
  const AssignmentReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignmentsCtrl = Get.isRegistered<AssignmentsController>()
        ? Get.find<AssignmentsController>()
        : Get.put(AssignmentsController());

    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final AssignmentSummaryModel? item = args?["assignmentSummary"];

    if (item == null) {
      return Scaffold(
        backgroundColor: KazinColors.scaffoldBg,
        appBar: AppBar(
          title: const Text("Assignment Review"),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            "No assignment data found.",
            style: TextStyle(color: KazinColors.textSecondary),
          ),
        ),
      );
    }

    final String dateRange = assignmentsCtrl.formatDateRange(
      item.checkInDate,
      item.checkOutDate,
    );

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KazinColors.primaryNavy),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "New Assignment",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context, assignmentsCtrl, item),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Alert Banner

              // Main Details Card
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: KazinColors.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KazinColors.scaffoldBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Arrival ID: #${item.arrivalId}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: KazinColors.textSecondary,
                              ),
                            ),
                          ),
                          if (item.enquiryId > 0)
                            Text(
                              "Enquiry: #${item.enquiryId}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: KazinColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Lead Guest Name
                      Text(
                        item.leadName.isNotEmpty ? item.leadName : "Group Tour",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Contact Phone Button
                      if (item.leadContact.isNotEmpty)
                        InkWell(
                          onTap: () {
                            final clean = item.leadContact.replaceAll(
                              RegExp(r'[^0-9+]'),
                              '',
                            );
                            launchUrl(Uri.parse('tel:$clean'));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: KazinColors.secondaryTeal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.leadContact,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: KazinColors.secondaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Divider(height: 24),

                      // Schedule Grid (Dates & Duration)
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: "Tour Dates",
                        value: dateRange,
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.nights_stay_outlined,
                        label: "Duration",
                        value: "${item.numberOfNights} Nights",
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.groups_outlined,
                        label: "Total Guests",
                        value:
                            "${item.numberPersons} Adults ${item.numberChild > 0 ? '+ ${item.numberChild} Children' : ''}",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: KazinColors.scaffoldBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: KazinColors.primaryNavy),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: KazinColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: KazinColors.primaryNavy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    AssignmentsController assignmentsCtrl,
    AssignmentSummaryModel item,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: KazinColors.borderSubtle)),
      ),
      child: SafeArea(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Accept Assignment Action
              // 1. Accept Assignment Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KazinColors.greenAcceptedText,
                    minimumSize: const Size.fromHeight(50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: assignmentsCtrl.isActionLoading.value
                      ? null
                      : () async {
                          final bool isSuccess = await assignmentsCtrl
                              .acceptTourFile(item);

                          if (isSuccess) {
                            if (Get.isRegistered<NotificationsController>()) {
                              Get.find<NotificationsController>()
                                  .removeAssignmentNotification();
                            }

                            if (Get.isRegistered<KazinController>()) {
                              Get.find<KazinController>()
                                      .hasUnreadAlerts
                                      .value =
                                  false;
                            }

                            // Review Screen close karein
                            Navigator.of(context).pop();
                          }
                        },
                  child: assignmentsCtrl.isActionLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Accept Assignment",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Decline Assignment Action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KazinColors.redDanger,
                    side: const BorderSide(color: KazinColors.redDanger),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: assignmentsCtrl.isActionLoading.value
                      ? null
                      : () {
                          Get.toNamed(
                            Routes.DECLINE_ASSIGNMENT,
                            arguments: {
                              "enquiryId": item.enquiryId,
                              "arrivalId": item.arrivalId,
                              "leadName": item.leadName,
                            },
                          );
                        },
                  child: const Text(
                    "Decline Assignment",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
