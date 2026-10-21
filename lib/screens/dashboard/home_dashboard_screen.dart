import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:kazin_guide_app/screens/assignments/assignment_details_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<KazinController>();
    final arrivalCtrl = Get.put(ArrivalController());
    final authService = Get.find<AuthService>();
    final assignmentsCtrl = Get.put(AssignmentsController());

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Image.asset('assets/images/kazin_logo.png', height: 26),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Authenticated Guide Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${authService.firstName}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: KazinColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          authService.location,
                          style: const TextStyle(
                            color: KazinColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: KazinColors.primaryNavy,
                      backgroundImage: authService.photoUrl != null
                          ? NetworkImage(authService.photoUrl!)
                          : null,
                      child: authService.photoUrl == null
                          ? Text(
                              authService.firstName.isNotEmpty
                                  ? authService.firstName[0].toUpperCase()
                                  : "G",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Offline Sync Alert
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            //   decoration: BoxDecoration(
            //     color: KazinColors.blueInfoBg,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: const Row(
            //     children: [
            //       Icon(
            //         Icons.cloud_done_outlined,
            //         size: 16,
            //         color: KazinColors.primaryBlue,
            //       ),
            //       SizedBox(width: 8),
            //       Text(
            //         "Almaty Dossier cached — Available offline",
            //         style: TextStyle(
            //           fontSize: 13,
            //           fontWeight: FontWeight.w600,
            //           color: KazinColors.primaryNavy,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 20),

            // Operational Metric Boxes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: KazinColors.borderSubtle),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  _buildMetricTile("1", "Live"),
                  const SizedBox(width: 8),
                  Obx(
                    () => _buildMetricTile(
                      "${assignmentsCtrl.upcomingAssignments.length}",
                      "Upcoming",
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildMetricTile("0", "Completed"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Dossier Card (Today's Tour Package)
            Obx(() {
              final file = arrivalCtrl.activeTourFile.value;

              if (file == null) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        "No tour file assigned.",
                        style: TextStyle(color: KazinColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }

              final bool isFileClosed = file.status.toLowerCase().contains(
                "closed",
              );

              // Calculate current day index dynamically
              final Map<String, List<ItineraryStepModel>> grouped = {};
              for (var step in file.itinerary) {
                final dateKey = step.date.split('T')[0];
                if (dateKey.isNotEmpty) {
                  grouped.putIfAbsent(dateKey, () => []).add(step);
                }
              }
              final sortedDates = grouped.keys.toList()..sort();
              final int currentDayIndex = arrivalCtrl.calculateInitialDayIndex(
                sortedDates,
              );
              final String currentDayBadge = "DAY-${currentDayIndex + 1}";

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
                              color: isFileClosed
                                  ? KazinColors.borderSubtle
                                  : KazinColors.greenAcceptedBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isFileClosed
                                  ? file.status.toUpperCase()
                                  : "${file.status.toUpperCase()} • $currentDayBadge",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isFileClosed
                                    ? KazinColors.textSecondary
                                    : KazinColors.greenAcceptedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${file.leadName} (${file.numberPersons} PAX)",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.hotel_outlined,
                            size: 16,
                            color: KazinColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${file.hotel?.hotelName ?? 'Hotel'} (${file.hotel?.category ?? ''})",
                            style: const TextStyle(
                              fontSize: 13,
                              color: KazinColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // if (!isFileClosed && nextStep != null) ...[
                      //   const SizedBox(height: 8),
                      //   Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.flag_outlined,
                      //         size: 16,
                      //         color: KazinColors.secondaryTeal,
                      //       ),
                      //       const SizedBox(width: 6),
                      //       Expanded(
                      //         child: Text(
                      //           "Next: ${nextStep.time} ${nextStep.title}",
                      //           style: const TextStyle(
                      //             fontSize: 13,
                      //             fontWeight: FontWeight.w600,
                      //             color: KazinColors.secondaryTeal,
                      //           ),
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                      const SizedBox(height: 16),

                      // Button Actions
                      if (isFileClosed)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KazinColors.primaryNavy,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: () => Get.to(
                            () => AssignmentDetailsScreen(tourFile: file),
                          ),
                          child: const Text("View Dossier"),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KazinColors.primaryNavy,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      30,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  arrivalCtrl.resetToToday();
                                  Get.toNamed(Routes.LIVE_SERVICE);
                                },
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  size: 18,
                                  color: Colors.tealAccent,
                                ),
                                label: const Text("Open Live"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: () => Get.to(
                                  () => AssignmentDetailsScreen(tourFile: file),
                                ),
                                child: const Text("View Details"),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Today's Pre-Service Checklist Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.fact_check_outlined,
                              size: 20,
                              color: KazinColors.secondaryTeal,
                            ),
                            const SizedBox(width: 8),
                            // Dynamic Day match on Instructions
                            Obx(() {
                              final file = arrivalCtrl.activeTourFile.value;
                              int displayDay = 1;
                              if (file != null) {
                                final Map<String, List<ItineraryStepModel>>
                                grouped = {};
                                for (var step in file.itinerary) {
                                  final dateKey = step.date.split('T')[0];
                                  if (dateKey.isNotEmpty) {
                                    grouped
                                        .putIfAbsent(dateKey, () => [])
                                        .add(step);
                                  }
                                }
                                final sortedDates = grouped.keys.toList()
                                  ..sort();
                                displayDay =
                                    arrivalCtrl.calculateInitialDayIndex(
                                      sortedDates,
                                    ) +
                                    1;
                              }
                              return Text(
                                "Day $displayDay • Instructions",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: KazinColors.primaryNavy,
                                ),
                              );
                            }),
                          ],
                        ),
                        // Live Progress Counter
                        Obx(() {
                          final total = ctrl.checklistState.length;
                          final completed = ctrl.checklistState.values
                              .where((v) => v == true)
                              .length;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: completed == total
                                  ? KazinColors.greenAcceptedBg
                                  : KazinColors.amberWarningBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$completed / $total Done",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: completed == total
                                    ? KazinColors.greenAcceptedText
                                    : KazinColors.amberWarningText,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Ensure these operational tasks are checked before meeting guests.",
                      style: TextStyle(
                        fontSize: 12,
                        color: KazinColors.textSecondary,
                      ),
                    ),
                    const Divider(height: 20),

                    // Interactive Checklist Items (One-Way Tick: Can NOT untick once checked)
                    Obx(
                      () => Column(
                        children: ctrl.checklistState.entries.map((entry) {
                          final isChecked = entry.value;
                          return InkWell(
                            // Agar pehle se checked hai to tap disable kar diya
                            onTap: isChecked
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    ctrl.toggleChecklistItem(entry.key);
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    isChecked
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked,
                                    size: 20,
                                    color: isChecked
                                        ? KazinColors.secondaryTeal
                                        : KazinColors.textMuted,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isChecked
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        decoration: isChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isChecked
                                            ? KazinColors.textMuted
                                            : KazinColors.primaryNavy,
                                      ),
                                    ),
                                  ),
                                  // if (isChecked)
                                  //   const Icon(
                                  //     Icons.lock_outline_rounded,
                                  //     size: 14,
                                  //     color: KazinColors.textMuted,
                                  //   ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetricTile(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: KazinColors.scaffoldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: KazinColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: KazinColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
