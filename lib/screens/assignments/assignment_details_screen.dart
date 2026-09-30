import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/screens/execution/readiness_checklist_screen.dart';
import 'decline_assignment_screen.dart';

class AssignmentDetailsScreen extends StatelessWidget {
  final bool isAlreadyAccepted;

  const AssignmentDetailsScreen({super.key, this.isAlreadyAccepted = false});

  @override
  Widget build(BuildContext context) {
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
          "Assignment Summary",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: KazinColors.primaryNavy,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: isAlreadyAccepted
                  ? KazinColors.greenAcceptedBg
                  : KazinColors.blueInfoBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                isAlreadyAccepted ? "ACCEPTED" : "ACTION REQUIRED",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isAlreadyAccepted
                      ? KazinColors.greenAcceptedText
                      : KazinColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main File & Duration Card
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
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: KazinColors.amberWarningBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "5 Days / 4 Nights",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: KazinColors.amberWarningText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Almaty Complete Tour Package",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(
                          Icons.date_range_rounded,
                          size: 16,
                          color: KazinColors.secondaryTeal,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "25-Sep-2026  ➔  29-Sep-2026",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: KazinColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBriefStat(
                          "Guests",
                          "10 PAX",
                          Icons.people_outline,
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: KazinColors.borderSubtle,
                        ),
                        _buildBriefStat(
                          "Vehicle",
                          "HiAce Van",
                          Icons.directions_bus_outlined,
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: KazinColors.borderSubtle,
                        ),
                        _buildBriefStat("Guide", "Vadim", Icons.badge_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Key Guest Brief
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.person_pin_outlined,
                          size: 18,
                          color: KazinColors.primaryBlue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Guest Brief",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: KazinColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRowDetail("Group Lead", "Smith Family & Group"),
                    _buildRowDetail("Total Count", "10 PAX (Adults)"),
                    _buildRowDetail("Language", "English"),
                    _buildRowDetail("Emergency Contact", "+44 20 5555 0182"),
                    _buildRowDetail(
                      "Meals Preference",
                      "Indian / Vegetarian Friendly",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Logistics & Reporting
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.flight_land_rounded,
                          size: 18,
                          color: KazinColors.secondaryTeal,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Reporting & Transfer Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: KazinColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRowDetail(
                      "Day 1 Reporting",
                      "10:20 AM @ Almaty Int'l Airport",
                    ),
                    _buildRowDetail(
                      "Pickup Spot",
                      "1st Floor (Legal Parking Only)",
                    ),
                    _buildRowDetail(
                      "Final Drop-off",
                      "29-Sep @ 17:00 (ALA Airport)",
                    ),
                    _buildRowDetail(
                      "Luggage Spec",
                      "6 Large / 4 Medium Suitcases",
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: KazinColors.amberWarningBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: KazinColors.amberWarningText.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: KazinColors.amberWarningText,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Notice: 2nd floor stops at Almaty airport are heavily fined. Use legal parking ground level.",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: KazinColors.amberWarningText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Conditional Buttons State: Accept/Decline vs Accepted State
            if (isAlreadyAccepted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: KazinColors.greenAcceptedBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: KazinColors.greenAcceptedText.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      color: KazinColors.greenAcceptedText,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Assignment Accepted",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: KazinColors.greenAcceptedText,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              ElevatedButton(
                onPressed: () => Get.to(() => const ReadinessChecklistScreen()),
                child: const Text("Accept Assignment"),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Get.to(() => const DeclineAssignmentScreen()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KazinColors.redDanger,
                  side: const BorderSide(color: KazinColors.redDanger),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Decline Assignment"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildBriefStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: KazinColors.secondaryTeal),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: KazinColors.primaryNavy,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: KazinColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static Widget _buildRowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: KazinColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: KazinColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
