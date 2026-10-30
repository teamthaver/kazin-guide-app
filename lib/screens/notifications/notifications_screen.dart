import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/controllers/notifications_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/assignment_summary_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());
    final assignmentsCtrl = Get.isRegistered<AssignmentsController>()
        ? Get.find<AssignmentsController>()
        : Get.put(AssignmentsController());

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Notifications & Alerts",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => Row(
                children: controller.filters.map((filter) {
                  final isSelected = controller.selectedFilter.value == filter;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: KazinColors.primaryNavy,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : KazinColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? KazinColors.primaryNavy
                              : KazinColors.borderSubtle,
                        ),
                      ),
                      onSelected: (_) => controller.selectFilter(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Alerts / Notification List Area
          Expanded(
            child: Obx(() {
              final activeFilter = controller.selectedFilter.value;
              final isAlertFilter =
                  activeFilter == "All" ||
                  activeFilter == "Assignments" ||
                  activeFilter == "Urgent";

              // POST /alert se aane wali unaccepted files
              final alertList = assignmentsCtrl.pendingAlerts;

              if (!isAlertFilter || alertList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 48,
                        color: KazinColors.textMuted,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No new alerts or pending assignments",
                        style: TextStyle(
                          color: KazinColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: KazinColors.primaryNavy,
                onRefresh: () => assignmentsCtrl.refreshAssignments(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: alertList.length,
                  itemBuilder: (context, index) {
                    final item = alertList[index];
                    return _buildAlertAssignmentCard(
                      context,
                      item,
                      assignmentsCtrl,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertAssignmentCard(
    BuildContext context,
    AssignmentSummaryModel item,
    AssignmentsController assignmentsCtrl,
  ) {
    // DD-MM-YYYY formatted dates
    final String formattedArrivalDate = assignmentsCtrl.formatToDDMMYYYY(
      item.arrivalDate.isNotEmpty ? item.arrivalDate : item.checkInDate,
    );

    final String formattedDateRange = assignmentsCtrl.formatRangeDDMMYYYY(
      item.checkInDate,
      item.checkOutDate,
    );

    final String guestsText = item.numberChild > 0
        ? "${item.numberPersons} Adults, ${item.numberChild} Children"
        : "${item.numberPersons} Guests";

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: KazinColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: New Assignment Badge & Arrival ID
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 8,
            //         vertical: 4,
            //       ),
            //       decoration: BoxDecoration(
            //         color: KazinColors.blueInfoBg,
            //         borderRadius: BorderRadius.circular(6),
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           const Icon(
            //             Icons.notification_important_rounded,
            //             size: 13,
            //             color: KazinColors.primaryBlue,
            //           ),
            //           const SizedBox(width: 4),
            //           Text(
            //             item.tripState.isNotEmpty
            //                 ? "NEW (${item.tripState.toUpperCase()})"
            //                 : "NEW ASSIGNMENT",
            //             style: const TextStyle(
            //               fontSize: 10,
            //               fontWeight: FontWeight.w800,
            //               color: KazinColors.primaryBlue,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     Text(
            //       "ID: #${item.arrivalId}",
            //       style: const TextStyle(
            //         fontSize: 11,
            //         fontWeight: FontWeight.bold,
            //         color: KazinColors.textSecondary,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 10),

            // Lead Passenger Name
            Text(
              item.leadName.isNotEmpty
                  ? item.leadName
                  : "Group Tour Assignment",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Group Type & No. of Guests Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KazinColors.scaffoldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.groups_outlined,
                      label: "No. Guests",
                      value: guestsText,
                    ),
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: KazinColors.borderSubtle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.category_outlined,
                      label: "Group Type",
                      value: item.groupType.isNotEmpty
                          ? item.groupType
                          : "Standard",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Arrival Date (DD-MM-YYYY) & File Duration
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KazinColors.scaffoldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.flight_land_rounded,
                      label: "Arrival Date",
                      value: formattedArrivalDate, // e.g. 15-11-2026
                    ),
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: KazinColors.borderSubtle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.timelapse_rounded,
                      label: "File Duration",
                      value: "${item.numberOfNights} Nights",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.date_range_outlined,
                  size: 15,
                  color: KazinColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Check in - Check out: $formattedDateRange",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Action Buttons: Decline & Accept
            // Action Buttons: Decline & Accept
            Obx(() {
              final bool isThisItemLoading =
                  assignmentsCtrl.acceptingArrivalId.value == item.arrivalId;

              final bool isAnyItemLoading =
                  assignmentsCtrl.acceptingArrivalId.value != null;

              return Row(
                children: [
                  // Decline Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KazinColors.redDanger,
                        side: const BorderSide(color: KazinColors.redDanger),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isAnyItemLoading 
                          ? null
                          : () {
                              Get.toNamed(
                                Routes.DECLINE_ASSIGNMENT,
                                arguments: {
                                  "assignmentSummary": item,
                                  "enquiryId": item.enquiryId,
                                  "arrivalId": item.arrivalId,
                                  "leadName": item.leadName,
                                },
                              );
                            },
                      child: const Text(
                        "Decline",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Accept Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KazinColors.greenAcceptedText,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isAnyItemLoading
                          ? null
                          : () async {
                              final bool isSuccess = await assignmentsCtrl
                                  .acceptTourFile(item);

                              if (isSuccess) {
                                if (Get.isRegistered<KazinController>()) {
                                  Get.find<KazinController>()
                                          .hasUnreadAlerts
                                          .value =
                                      assignmentsCtrl.pendingAlerts.isNotEmpty;
                                }
                              }
                            },
                      // YAHAN FIX HAI: 'isBusy' ki jagah strictly 'isThisItemLoading' aayega
                      child: isThisItemLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Accept",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: KazinColors.primaryNavy),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: KazinColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: KazinColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
