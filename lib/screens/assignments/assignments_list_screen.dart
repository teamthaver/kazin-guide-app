import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/assignment_summary_model.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class AssignmentListScreen extends GetView<AssignmentsController> {
  const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AssignmentsController());

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "My Assignments",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: KazinColors.primaryNavy,
          unselectedLabelColor: KazinColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          indicatorColor: KazinColors.primaryNavy,
          indicatorWeight: 3,
          tabs: [
            Obx(
              () =>
                  Tab(text: "Active (${controller.activeAssignments.length})"),
            ),
            Obx(() {
              // Sirf confirmed upcoming files ka count
              final count = controller.upcomingAssignments.length;
              return Tab(text: "Upcoming ($count)");
            }),
            Obx(
              () => Tab(
                text: "Completed (${controller.completedAssignments.length})",
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: KazinColors.primaryNavy),
          );
        }

        return TabBarView(
          controller: controller.tabController,
          children: [
            // Tab 1: Active Assignment (Full TourFileModel)
            _buildActiveTab(),

            // Tab 2: Upcoming Accepted Assignments (AssignmentSummaryModel)
            _buildUpcomingTab(),

            // Tab 3: Completed Assignments (AssignmentSummaryModel)
            _buildCompletedTab(),
          ],
        );
      }),
    );
  }

  // --- TAB 1: ACTIVE (TourFileModel) ---
  Widget _buildActiveTab() {
    final items = controller.activeAssignments;
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: Icons.tour_outlined,
        text: "No active tours currently in progress.",
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAssignments,
      color: KazinColors.primaryNavy,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildActiveCard(items[index]);
        },
      ),
    );
  }

  Widget _buildActiveCard(TourFileModel file) {
    final int adults = file.numAdults > 0 ? file.numAdults : file.numberPersons;
    final int children = file.numChild;
    final String guestDetails = children > 0
        ? "$adults Adults, $children Child"
        : "$adults Adults";
    final String groupType = file.groupType.isNotEmpty
        ? file.groupType
        : "Standard";
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${file.enquiryNo}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KazinColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KazinColors.greenAcceptedBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    "LIVE ACTIVE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: KazinColors.greenAcceptedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "${file.leadName}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 4),

            // Guest details: Adults, Child & Group Type under Lead Name (NO PAX)
            Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 15,
                  color: KazinColors.greenAcceptedText,
                ),
                const SizedBox(width: 6),
                Text(
                  "$guestDetails • $groupType",
                  style: TextStyle(
                    color: KazinColors.primaryNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (file.hotel != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.hotel_outlined,
                    size: 16,
                    color: KazinColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${file.hotel!.hotelName} (${file.hotel!.category})",
                      style: const TextStyle(
                        fontSize: 12,
                        color: KazinColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  size: 16,
                  color: KazinColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${file.transport?.vehicleName ?? 'Sedan'} • Driver: ${file.driver?.name ?? 'Assigned'}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: KazinColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: KazinColors.primaryNavy,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => controller.openLiveService(file),
              icon: const Icon(
                Icons.play_circle_fill,
                size: 18,
                color: Colors.tealAccent,
              ),
              label: const Text(
                "Open Live Execution",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: UPCOMING ACCEPTED ASSIGNMENTS ---
  Widget _buildUpcomingTab() {
    final items = controller.upcomingAssignments;

    if (items.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_month_outlined,
        text: "No confirmed upcoming tours found.",
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAssignments,
      color: KazinColors.primaryNavy,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildUpcomingAlertStyleCard(items[index]),
      ),
    );
  }

  /// Alert Page card ke format par based Upcoming Card
  Widget _buildUpcomingAlertStyleCard(AssignmentSummaryModel item) {
    final bool isUnlocked = item.isDetailsUnlocked;

    final String formattedArrivalDate = controller.formatToDDMMYYYY(
      item.arrivalDate.isNotEmpty ? item.arrivalDate : item.checkInDate,
    );

    final String formattedDateRange = controller.formatRangeDDMMYYYY(
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
        side: BorderSide(
          color: isUnlocked
              ? KazinColors.secondaryTeal.withValues(alpha: 0.4)
              : KazinColors.borderSubtle,
          width: isUnlocked ? 1.2 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Lock/Unlock Badge & Arrival ID
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 8,
            //         vertical: 4,
            //       ),
            //       decoration: BoxDecoration(
            //         color: isUnlocked
            //             ? KazinColors.greenAcceptedBg
            //             : KazinColors.scaffoldBg,
            //         borderRadius: BorderRadius.circular(6),
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Icon(
            //             isUnlocked
            //                 ? Icons.lock_open_rounded
            //                 : Icons.lock_outline_rounded,
            //             size: 13,
            //             color: isUnlocked
            //                 ? KazinColors.greenAcceptedText
            //                 : KazinColors.textSecondary,
            //           ),
            //           const SizedBox(width: 4),
            //           Text(
            //             isUnlocked
            //                 ? "DOSSIER UNLOCKED"
            //                 : "LOCKED • OPENS IN ${item.arrivalDate}D",
            //             style: TextStyle(
            //               fontSize: 10,
            //               fontWeight: FontWeight.w800,
            //               color: isUnlocked
            //                   ? KazinColors.greenAcceptedText
            //                   : KazinColors.textSecondary,
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

            // 1. Group Type & No. of Guests Row (Alert Style)
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

            // 2. Arrival Date & File Duration Row (Alert Style)
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
                      value: formattedArrivalDate,
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

            // 3. Check-In & Check-Out Date Range (DD-MM-YYYY)
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

            // Bottom Action: View Details / Locked Notice
            Obx(() {
              final bool isLoadingCurrent =
                  controller.loadingArrivalId.value == item.arrivalId;

              if (!isUnlocked) {
                // 48 hours se bahar: Disabled / Locked view
                return OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KazinColors.textSecondary,
                    side: const BorderSide(color: KazinColors.borderSubtle),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => controller.openUpcomingFileDetails(item),
                  icon: const Icon(Icons.lock_clock_rounded, size: 16),
                  label: Text(
                    "Currently details are not available",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              // 48 hours ke andar: Active View Details button
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.primaryNavy,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoadingCurrent
                    ? null
                    : () => controller.openUpcomingFileDetails(item),
                child: isLoadingCurrent
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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

  // --- TAB 3: COMPLETED ---
  Widget _buildCompletedTab() {
    final items = controller.completedAssignments;
    if (items.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        text: "No completed assignments found.",
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAssignments,
      color: KazinColors.primaryNavy,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildCompletedCard(items[index]),
      ),
    );
  }

  Widget _buildCompletedCard(AssignmentSummaryModel item) {
    final bool hasValidName = item.leadName.isNotEmpty && item.leadName != "NA";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KazinColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KazinColors.greenAcceptedBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: KazinColors.greenAcceptedText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasValidName ? item.leadName : "Tour Assignment",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KazinColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  controller.formatDateRange(
                    item.checkInDate,
                    item.checkOutDate,
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: KazinColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${item.numberPersons} PAX • ${item.numberOfNights} Nights",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: KazinColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: KazinColors.scaffoldBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "Closed",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: KazinColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: KazinColors.textMuted),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KazinColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
