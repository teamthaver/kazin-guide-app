import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/screens/assignments/assignment_details_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AppController se readiness state bind karenge
    final ctrl = Get.find<KazinController>();

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Image.asset('assets/images/kazin_logo.png', height: 26),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(color: KazinColors.borderSubtle),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 14,
                  color: KazinColors.textSecondary,
                ),
                SizedBox(width: 6),
                Text(
                  "Offline",
                  style: TextStyle(
                    fontSize: 12,
                    color: KazinColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Good Morning, Vadim",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: KazinColors.primaryBlue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Almaty, Kazakhstan",
                          style: TextStyle(
                            color: KazinColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: KazinColors.borderSubtle),
                      ),
                      child: const Icon(Icons.notifications_none, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      backgroundColor: KazinColors.primaryNavy,
                      child: Text(
                        "V",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Offline Sync Alert
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: KazinColors.blueInfoBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.cloud_done_outlined,
                    size: 16,
                    color: KazinColors.primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Almaty Dossier cached — Available offline",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Operational Metric Tiles (Today, Upcoming, Completed)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: KazinColors.borderSubtle),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  _buildMetricTile("1", "Today"),
                  const SizedBox(width: 8),
                  _buildMetricTile("3", "Upcoming"),
                  const SizedBox(width: 8),
                  _buildMetricTile("5", "Completed"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Dossier Card (Today's Assignment)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "FILE #KZ10231",
                          style: TextStyle(
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
                            color: KazinColors.greenAcceptedBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: KazinColors.greenAcceptedText,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "DAY 1 • LIVE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: KazinColors.greenAcceptedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Almaty 5D/4N Complete Package",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 16,
                          color: KazinColors.textSecondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Toyota HiAce Mini Van  •  10 PAX",
                          style: TextStyle(
                            fontSize: 13,
                            color: KazinColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: KazinColors.textSecondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "25-Sep to 29-Sep-2026",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: KazinColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: KazinColors.secondaryTeal,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Next: 10:20 AM Meet & Greet (Airport 1st Floor)",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: KazinColors.secondaryTeal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KazinColors.primaryNavy,
                            ),
                            onPressed: () => Get.toNamed(Routes.LIVE_SERVICE),
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
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Get.to(
                              () => const AssignmentDetailsScreen(
                                isAlreadyAccepted: true,
                              ),
                            ),
                            child: const Text("View Details"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- NAYA SECTION: TODAY'S PRE-SERVICE CHECKLIST & INSTRUCTIONS ---
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
                          children: const [
                            Icon(
                              Icons.fact_check_outlined,
                              size: 20,
                              color: KazinColors.secondaryTeal,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Day 1 • Pre-Service Checks",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: KazinColors.primaryNavy,
                              ),
                            ),
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

                    // Interactive Checklist Items
                    Obx(
                      () => Column(
                        children: ctrl.checklistState.entries.map((entry) {
                          final isChecked = entry.value;
                          return InkWell(
                            onTap: () {
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
