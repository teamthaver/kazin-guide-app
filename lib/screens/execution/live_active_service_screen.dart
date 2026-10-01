import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class LiveActiveServiceScreen extends StatelessWidget {
  const LiveActiveServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeDayIndex = 0.obs;

    // Multi-day execution pipeline loaded from Kazin CRM itinerary
    final executionDays = [
      {
        "day": "Day 1",
        "date": "25-Sep-2026",
        "title": "Arrival & City Orientation",
        "status": "EN ROUTE",
        "target": "Almaty Int'l Airport (1st Floor Legal Parking)",
        "tasks": [
          {
            "time": "10:20",
            "title": "Airport Customs & Immigration Clearance",
            "desc": "Assist 10 guests in arrival hall with baggage.",
            "completed": true.obs,
          },
          {
            "time": "10:20",
            "title": "Meet & Greet with Driver (Legal Parking)",
            "desc":
                "Pickup strictly on 1st floor parking. 2nd-floor stops are fined.",
            "completed": true.obs,
            "isWarning": true,
            "warningText":
                "Airport police enforce zero tolerance on 2nd-floor stopping.",
          },
          {
            "time": "12:00",
            "title": "Prepaid Lunch at Silver Spoon",
            "desc": "Table reserved for 10 PAX (Prepaid Voucher).",
            "completed": false.obs,
            "voucher": "Silver Spoon Voucher",
          },
          {
            "time": "15:00",
            "title": "Hotel Check-in & Luggage Handling",
            "desc": "Assist group with key distribution.",
            "completed": false.obs,
            "voucher": "Hotel Voucher",
          },
          {
            "time": "16:00",
            "title": "Almaty Orientation Tour",
            "desc": "Guided walking tour with Guide Vadim.",
            "completed": false.obs,
          },
          {
            "time": "20:00",
            "title": "Dinner at Deli (Prepaid)",
            "desc": "Prepaid dinner for entire group.",
            "completed": false.obs,
            "voucher": "Deli Dinner Voucher",
          },
          {
            "time": "21:30",
            "title": "Transfer Back to Hotel",
            "desc": "Coordinate with driver for hotel drop.",
            "completed": false.obs,
          },
        ],
      },
      {
        "day": "Day 2",
        "date": "26-Sep-2026",
        "title": "Cathedral, Green Bazaar & Kok Tobe",
        "status": "SCHEDULED",
        "target": "Panfilov Park & Zenkov Cathedral",
        "tasks": [
          {
            "time": "07:00",
            "title": "Breakfast at Hotel",
            "desc": "Buffet breakfast.",
            "completed": false.obs,
          },
          {
            "time": "10:00",
            "title": "Visit Panfilov Park & Zenkov Cathedral",
            "desc": "Historic wooden cathedral walk.",
            "completed": false.obs,
          },
          {
            "time": "12:30",
            "title": "Green Bazaar & Rahat Chocolate Shop",
            "desc": "Local confectionery & dry fruits.",
            "completed": false.obs,
          },
          {
            "time": "14:00",
            "title": "Lunch at Taj (Prepaid)",
            "desc": "Indian cuisine prepaid meal.",
            "completed": false.obs,
            "voucher": "Taj Meal Voucher",
          },
          {
            "time": "17:00",
            "title": "Sunset at Kok Tobe (Return Gondola)",
            "desc": "Distribute return cable car passes.",
            "completed": false.obs,
            "voucher": "Gondola Ticket",
          },
          {
            "time": "20:00",
            "title": "Open Restaurant (Dinner)",
            "desc": "Direct payment by guests (20:00 - 21:00).",
            "completed": false.obs,
          },
          {
            "time": "21:30",
            "title": "Hotel Transfer",
            "desc": "Return to accommodation.",
            "completed": false.obs,
          },
        ],
      },
      {
        "day": "Day 3",
        "date": "27-Sep-2026",
        "title": "Shymbulak Mountain Resort",
        "status": "SCHEDULED",
        "target": "Medeu to Shymbulak Base",
        "tasks": [
          {
            "time": "07:00",
            "title": "Breakfast at Hotel",
            "desc": "Buffet service.",
            "completed": false.obs,
          },
          {
            "time": "10:00",
            "title": "Shymbulak Resort - Level 3 Gondola",
            "desc": "Return cable car to 3,200m peak.",
            "completed": false.obs,
            "isWarning": true,
            "warningText":
                "Level 3 peak is freezing. Verify all guests have warm jackets before boarding.",
            "voucher": "L3 Gondola Pass",
          },
          {
            "time": "13:00",
            "title": "Lunch at Magic Masala (Prepaid)",
            "desc": "Pre-booked lunch voucher.",
            "completed": false.obs,
            "voucher": "Magic Masala Voucher",
          },
          {
            "time": "17:00",
            "title": "Panfilov & Arbat Street Walk",
            "desc": "Pedestrian artisan market.",
            "completed": false.obs,
          },
          {
            "time": "20:00",
            "title": "Open Restaurant (Dinner)",
            "desc": "Direct payment by guests.",
            "completed": false.obs,
          },
          {
            "time": "21:30",
            "title": "Hotel Transfer",
            "desc": "Drop at hotel.",
            "completed": false.obs,
          },
        ],
      },
      {
        "day": "Day 4",
        "date": "28-Sep-2026",
        "title": "Charyn Canyon Excursion",
        "status": "SCHEDULED",
        "target": "Charyn Canyon Valley of Castles",
        "tasks": [
          {
            "time": "07:00",
            "title": "Breakfast at Hotel",
            "desc": "Early morning breakfast.",
            "completed": false.obs,
          },
          {
            "time": "09:00",
            "title": "Transit to Charyn Canyon",
            "desc": "220 km highway transit (3 hrs one-way).",
            "completed": false.obs,
            "isWarning": true,
            "warningText":
                "Check vehicle fuel, emergency kit & water supply before departure.",
          },
          {
            "time": "14:30",
            "title": "Packed Lunch by Deli (Prepaid)",
            "desc": "Distribute boxed lunches at canyon rest area.",
            "completed": false.obs,
            "voucher": "Packed Meal Voucher",
          },
          {
            "time": "16:00",
            "title": "Return Transit to Almaty",
            "desc": "3-hour journey back to city.",
            "completed": false.obs,
          },
          {
            "time": "20:00",
            "title": "Open Restaurant (Dinner)",
            "desc": "Direct payment by guests.",
            "completed": false.obs,
          },
          {
            "time": "21:30",
            "title": "Hotel Drop-off",
            "desc": "Overnight rest.",
            "completed": false.obs,
          },
        ],
      },
      {
        "day": "Day 5",
        "date": "29-Sep-2026",
        "title": "Check-out, Gorge & Departure",
        "status": "SCHEDULED",
        "target": "Almaty International Airport (ALA)",
        "tasks": [
          {
            "time": "07:00",
            "title": "Breakfast at Hotel",
            "desc": "Final breakfast.",
            "completed": false.obs,
          },
          {
            "time": "09:30",
            "title": "Check-out & Luggage Loading",
            "desc": "Settle room extras. Guide & van on disposal.",
            "completed": false.obs,
          },
          {
            "time": "10:00",
            "title": "Almarasan Gorge Ayusai",
            "desc": "Mountain nature walk.",
            "completed": false.obs,
          },
          {
            "time": "13:00",
            "title": "Lunch at Maharaja (Prepaid)",
            "desc": "Final tour group lunch.",
            "completed": false.obs,
            "voucher": "Maharaja Voucher",
          },
          {
            "time": "14:00",
            "title": "Almaty Souvenir Shopping",
            "desc": "City center artisan market.",
            "completed": false.obs,
          },
          {
            "time": "17:00",
            "title": "Airport Transfer & Departure",
            "desc": "Luggage check-in assistance at ALA.",
            "completed": false.obs,
          },
        ],
      },
    ];

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
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: KazinColors.redDanger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "LIVE EXECUTION",
              style: TextStyle(
                color: KazinColors.primaryNavy,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shield_outlined,
              color: KazinColors.redDanger,
            ),
            onPressed: () => Get.toNamed(Routes.EMERGENCY_SOS),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Status Card with Day Switcher
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "FILE #KZ10231 • ALMATY DOSSIER",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: KazinColors.secondaryTeal.withValues(
                              alpha: 0.25,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: KazinColors.secondaryTeal,
                            ),
                          ),
                          child: Text(
                            "${executionDays[activeDayIndex.value]["day"]} ACTIVE",
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Almaty 5D/4N Group (10 PAX)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      "${executionDays[activeDayIndex.value]["title"]} • Guide: Vadim",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KazinColors.primaryBlue,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Get.toNamed(Routes.AIRPORT_WORKFLOW),
                          icon: const Icon(Icons.flight_land, size: 16),
                          label: const Text("Arrival Steps"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Get.toNamed(Routes.WELCOME_PLACARD),
                          icon: const Icon(Icons.badge_outlined, size: 16),
                          label: const Text(
                            "Show Placard",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal Day Pills
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: executionDays.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSel = activeDayIndex.value == index;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        activeDayIndex.value = index;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSel ? KazinColors.primaryNavy : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? KazinColors.primaryNavy
                                : KazinColors.borderSubtle,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${executionDays[index]["day"]} (${(executionDays[index]["date"] as String).split("-")[0]} Sep)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSel
                                  ? Colors.white
                                  : KazinColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Route & Vehicle Status Card
            Obx(() {
              final currDay = executionDays[activeDayIndex.value];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Active Day Route",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: KazinColors.blueInfoBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Toyota HiAce Mini Van",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: KazinColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me,
                            color: KazinColors.secondaryTeal,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Target: ${currDay["target"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  Get.toNamed(Routes.MAP_NAVIGATION),
                              icon: const Icon(Icons.navigation, size: 16),
                              label: const Text("Live GPS"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  "Driver Pending",
                                  "Driver not allocated yet in Kazin CRM. Dispatch notified.",
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              icon: const Icon(
                                Icons.contact_phone_outlined,
                                size: 16,
                              ),
                              label: const Text("Driver Info"),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 18),

            // Today's Live Checkpoint Execution Steps
            Obx(() {
              final tasks =
                  executionDays[activeDayIndex.value]["tasks"]
                      as List<Map<String, dynamic>>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${executionDays[activeDayIndex.value]["day"]} Operational Tasks",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${tasks.length} Checkpoints",
                        style: const TextStyle(
                          color: KazinColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(tasks.length, (idx) {
                    final t = tasks[idx];
                    final RxBool isDone = t["completed"] as RxBool;
                    final bool isWarn = t["isWarning"] == true;

                    return Obx(
                      () => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDone.value
                                ? KazinColors.greenAcceptedBg
                                : (isWarn
                                      ? KazinColors.amberWarningText.withValues(
                                          alpha: 0.5,
                                        )
                                      : KazinColors.borderSubtle),
                            width: isDone.value ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      t["time"] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: KazinColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (t["voucher"] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: KazinColors.lightTeal,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          "VOUCHER",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: KazinColors.secondaryTeal,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                IconButton(
                                  iconSize: 22,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    isDone.value
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isDone.value
                                        ? KazinColors.secondaryTeal
                                        : KazinColors.textMuted,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    isDone.value = !isDone.value;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t["title"] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: isDone.value
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone.value
                                    ? KazinColors.textMuted
                                    : KazinColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t["desc"] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: KazinColors.textSecondary,
                              ),
                            ),
                            if (isWarn && t["warningText"] != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: KazinColors.amberWarningBg.withValues(
                                    alpha: 0.4,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 14,
                                      color: KazinColors.amberWarningText,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        t["warningText"] as String,
                                        style: const TextStyle(
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
                            if (t["voucher"] != null) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () =>
                                    Get.toNamed(Routes.DOCUMENT_WALLET),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      size: 14,
                                      color: KazinColors.secondaryTeal,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Open ${t["voucher"]}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: KazinColors.secondaryTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
            const SizedBox(height: 12),

            // Quick Execution Controls
            const Text(
              "Quick Field Actions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // _buildActionTile(
                //   icon: Icons.checklist_rtl_rounded,
                //   title: "Readiness",
                //   color: KazinColors.primaryBlue,
                //   onTap: () => Get.toNamed(Routes.READINESS_CHECKLIST),
                // ),
                const SizedBox(width: 12),
                _buildActionTile(
                  icon: Icons.receipt_long,
                  title: "Add Expense",
                  color: KazinColors.secondaryTeal,
                  onTap: () => Get.toNamed(Routes.EXPENSE_SUBMISSION),
                ),
                const SizedBox(width: 12),
                _buildActionTile(
                  icon: Icons.report_problem_outlined,
                  title: "Report Issue",
                  color: KazinColors.redDanger,
                  onTap: () => Get.toNamed(Routes.INCIDENT_REPORTING),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Day Closure CTA
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.secondaryTeal,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => Get.toNamed(Routes.SERVICE_CLOSURE),
                child: Text(
                  "Complete & Close ${executionDays[activeDayIndex.value]["day"]}",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KazinColors.borderSubtle),
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                radius: 22,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
