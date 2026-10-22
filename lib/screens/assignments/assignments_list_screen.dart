import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/assignment_summary_model.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
              // Sirf accepted files ka count dikhaye
              final acceptedCount = controller.upcomingAssignments
                  .where((item) => item.isAccepted == 1)
                  .length;
              return Tab(text: "Upcoming ($acceptedCount)");
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
        itemBuilder: (context, index) => _buildActiveCard(items[index]),
      ),
    );
  }

  Widget _buildActiveCard(TourFileModel file) {
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
                    "FILE #${file.enquiryNo}",
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
              "${file.leadName} (${file.numberPersons} PAX)",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
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

  // --- TAB 2: UPCOMING ACCEPTED ASSIGNMENTS (AssignmentSummaryModel) ---
  Widget _buildUpcomingTab() {
    // Sirf wahi files jinka isAccepted == 1 hai
    final acceptedItems = controller.upcomingAssignments
        .where((item) => item.isAccepted == 1)
        .toList();

    if (acceptedItems.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_month_outlined,
        text: "No confirmed upcoming tours found.",
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAssignments,
      color: KazinColors.primaryNavy,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acceptedItems.length,
        itemBuilder: (context, index) =>
            _buildUpcomingCard(acceptedItems[index]),
      ),
    );
  }

  Widget _buildUpcomingCard(AssignmentSummaryModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KazinColors.greenAcceptedText.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Accepted Badge & Pax/Night Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: KazinColors.greenAcceptedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 13,
                        color: KazinColors.greenAcceptedText,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "CONFIRMED UPCOMING",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: KazinColors.greenAcceptedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${item.numberOfNights} Nights • ${item.numberPersons} PAX",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: KazinColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Lead Passenger Name
            Text(
              item.leadName.isNotEmpty
                  ? item.leadName
                  : "Group Tour Assignment",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 6),

            // Dates & Duration
            Row(
              children: [
                const Icon(
                  Icons.date_range_outlined,
                  size: 14,
                  color: KazinColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  controller.formatDateRange(
                    item.checkInDate,
                    item.checkOutDate,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: KazinColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 22),

            // Bottom Action Row: Contact Action & Arrival ID info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.leadContact.isNotEmpty)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final clean = item.leadContact.replaceAll(
                          RegExp(r'[^0-9+]'),
                          '',
                        );
                        launchUrl(Uri.parse('tel:$clean'));
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: KazinColors.scaffoldBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KazinColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: KazinColors.secondaryTeal,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.leadContact,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: KazinColors.secondaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                // Arrival Reference Tag
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
                    "ID: #${item.arrivalId}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: KazinColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: COMPLETED (AssignmentSummaryModel) ---
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
