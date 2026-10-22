import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/controllers/notifications_controller.dart';
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
          "Notifications",
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

          // Notification List Area
          Expanded(
            child: Obx(() {
              final activeFilter = controller.selectedFilter.value;
              final isAssignmentFilter =
                  activeFilter == "All" || activeFilter == "Assignments";

              // Real pending assignment items (jisme is_accepted == 0 hai)
              final pendingList = assignmentsCtrl.pendingAssignments;

              if (!isAssignmentFilter || pendingList.isEmpty) {
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
                        "No new notifications",
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
                  itemCount: pendingList.length,
                  itemBuilder: (context, index) {
                    final item = pendingList[index];
                    return _buildRealAssignmentNotificationCard(
                      item,
                      assignmentsCtrl,
                      controller,
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

  Widget _buildRealAssignmentNotificationCard(
    AssignmentSummaryModel item,
    AssignmentsController assignmentsCtrl,
    NotificationsController controller,
  ) {
    final String formattedDate = assignmentsCtrl.formatDateRange(
      item.checkInDate,
      item.checkOutDate,
    );

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: KazinColors.borderSubtle),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.openAssignmentDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Review CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KazinColors.blueInfoBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 14,
                          color: KazinColors.primaryBlue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "NEW ASSIGNMENT",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: KazinColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        "Review",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: KazinColors.primaryBlue,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: KazinColors.primaryBlue,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lead Passenger Name & Pax
              Text(
                "${item.leadName.isNotEmpty ? item.leadName : 'Group Tour'} (${item.numberPersons} PAX)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: KazinColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),

              // Nights Info
              Text(
                "${item.numberOfNights} Nights Accommodation Scheduled",
                style: const TextStyle(
                  fontSize: 13,
                  color: KazinColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Date Range
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 15,
                    color: KazinColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
