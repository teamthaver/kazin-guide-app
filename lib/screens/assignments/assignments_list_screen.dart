import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/model/tour_file_model.dart';

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
    final bool isClosed = controller.isFileClosed(file);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "FILE #${file.enquiryNo}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: KazinColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isClosed
                        ? KazinColors.borderSubtle
                        : KazinColors.greenAcceptedBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    file.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isClosed
                          ? KazinColors.textSecondary
                          : KazinColors.greenAcceptedText,
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
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${file.hotel!.hotelName} (${file.hotel!.category})",
                      style: const TextStyle(
                        fontSize: 13,
                        color: KazinColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  size: 16,
                  color: KazinColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  "${file.transport?.vehicleName ?? 'Sedan'} • Driver: ${file.driver?.name ?? 'Assigned'}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: KazinColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isClosed)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.primaryNavy,
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: () => controller.viewDossier(file),
                child: const Text("View Dossier"),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KazinColors.primaryNavy,
                      ),
                      onPressed: () => controller.openLiveService(file),
                      icon: const Icon(
                        Icons.play_circle_fill,
                        size: 16,
                        color: Colors.tealAccent,
                      ),
                      label: const Text("Open Live"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => controller.viewDossier(file),
                      child: const Text("View Dossier"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
