import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
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
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          indicatorColor: KazinColors.primaryNavy,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Upcoming"),
            Tab(text: "Completed"),
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
            _buildListTab(
              items: controller.activeAssignments,
              emptyText: "No active tours currently in progress.",
            ),
            _buildListTab(
              items: controller.upcomingAssignments,
              emptyText: "No upcoming tours assigned yet.",
            ),
            _buildListTab(
              items: controller.completedAssignments,
              emptyText: "No completed assignments found.",
            ),
          ],
        );
      }),
    );
  }

  Widget _buildListTab({
    required List<TourFileModel> items,
    required String emptyText,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 54,
              color: KazinColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: const TextStyle(
                fontSize: 14,
                color: KazinColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshAssignments,
      color: KazinColors.primaryNavy,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildAssignmentCard(items[index]),
      ),
    );
  }

  Widget _buildAssignmentCard(TourFileModel file) {
    final status = file.status.toLowerCase();
    final bool isClosed = controller.isFileClosed(file);
    final bool isActive =
        status.contains("active") ||
        status.contains("live") ||
        status.contains("assigned");
    final bool isUpcoming =
        status.contains("upcoming") || status.contains("pending");

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: File No & Status Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    "FILE #${file.enquiryNo}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: KazinColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isClosed
                        ? KazinColors.borderSubtle
                        : (isUpcoming
                              ? KazinColors.blueInfoBg
                              : KazinColors.greenAcceptedBg),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    file.status.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isClosed
                          ? KazinColors.textSecondary
                          : (isUpcoming
                                ? KazinColors.primaryBlue
                                : KazinColors.greenAcceptedText),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Lead Guest & PAX (Overflow safe)
            Text(
              "${file.leadName} (${file.numberPersons} PAX)",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 6),

            // Hotel Info
            if (file.hotel != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.hotel_outlined,
                      size: 16,
                      color: KazinColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${file.hotel!.hotelName} (${file.hotel!.category})",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: KazinColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            // Transport & Driver Info (Overflow safe)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.directions_car_outlined,
                    size: 16,
                    color: KazinColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${file.transport?.vehicleName ?? 'Sedan'} • Driver: ${file.driver?.name ?? 'Assigned'}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: KazinColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Button actions
            if (isActive)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.primaryNavy,
                  minimumSize: const Size.fromHeight(48),
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
                  "Open Live",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              )
            else if (isUpcoming)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.viewDossier(file),
                child: const Text(
                  "View Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.primaryNavy,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.viewDossier(file),
                child: const Text(
                  "View Dossier",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
