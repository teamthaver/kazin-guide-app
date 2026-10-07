import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveActiveServiceScreen extends StatelessWidget {
  const LiveActiveServiceScreen({super.key});

  String _formatDayPill(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      return "${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arrivalCtrl = Get.put(ArrivalController());
    final activeDayIndex = 0.obs;

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
      body: Obx(() {
        final file = arrivalCtrl.activeTourFile.value;

        if (file == null) {
          return const Center(
            child: CircularProgressIndicator(color: KazinColors.primaryNavy),
          );
        }

        // Group API/DB Itinerary Steps Day-Wise
        final Map<String, List<ItineraryStepModel>> grouped = {};
        for (var step in file.itinerary) {
          final dateKey = step.date.split('T')[0];
          if (dateKey.isNotEmpty) {
            grouped.putIfAbsent(dateKey, () => []).add(step);
          }
        }
        final sortedDates = grouped.keys.toList()..sort();

        // Fallback agar koi itinerary na ho
        if (sortedDates.isEmpty) {
          return const Center(
            child: Text("No itinerary steps available for this assignment."),
          );
        }

        final int currentIndex = (activeDayIndex.value < sortedDates.length)
            ? activeDayIndex.value
            : 0;
        final String selectedDate = sortedDates[currentIndex];
        final List<ItineraryStepModel> currentTasks =
            grouped[selectedDate] ?? [];
        final bool isLastDay = currentIndex == sortedDates.length - 1;

        // Dynamic targets / details from active file
        final String currentDayTitle = currentTasks.isNotEmpty
            ? currentTasks.first.title
            : "Tour Operations";
        final String currentTarget = currentTasks.isNotEmpty
            ? currentTasks.first.content
            : "Daily Sightseeing & Transfers";
        final String vehicleDisplayName =
            file.transport?.vehicleName ?? "Sedan";
        final String vehicleTypes = file.transport?.vehicleType ?? "";

        return SingleChildScrollView(
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
                        Text(
                          "FILE #${file.enquiryNo} ",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
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
                            "DAY ${currentIndex + 1}",
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${file.leadName} (${file.numberPersons} PAX)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$currentDayTitle • Driver: ${file.driver?.name ?? 'Assigned'}",
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
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
                            onPressed: () =>
                                Get.toNamed(Routes.AIRPORT_WORKFLOW),
                            icon: const Icon(Icons.flight_land, size: 16),
                            label: const Text("Arrival"),
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
                            onPressed: () =>
                                Get.toNamed(Routes.WELCOME_PLACARD),
                            icon: const Icon(Icons.badge_outlined, size: 16),
                            label: const Text(
                              "Placard",
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

              // Horizontal Day Pills (Dynamic from API dates)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedDates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSel = currentIndex == index;
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
                            "Day ${index + 1} (${_formatDayPill(sortedDates[index])})",
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
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Route & Vehicle Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
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
                            child: Text(
                              vehicleDisplayName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: KazinColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentTarget,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (vehicleTypes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Vehicle Fleet: $vehicleTypes",
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                      ],
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
                                if (file.driver != null &&
                                    file.driver!.phone.isNotEmpty) {
                                  final cleanPhone = file.driver!.phone
                                      .replaceAll(RegExp(r'[^0-9+]'), '');
                                  launchUrl(Uri.parse('tel:$cleanPhone'));
                                } else {
                                  Get.snackbar(
                                    "Driver Info",
                                    "No direct phone number allocated for driver.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.contact_phone_outlined,
                                size: 16,
                              ),
                              label: Text(
                                file.driver?.name ?? "Driver Info",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
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
              ),
              const SizedBox(height: 18),

              // Today's Live Checkpoint Execution Steps (From API / Local SQLite DB)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Day ${currentIndex + 1} Operational Tasks",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${currentTasks.length} Checkpoints",
                        style: const TextStyle(
                          color: KazinColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(currentTasks.length, (idx) {
                    final step = currentTasks[idx];
                    final bool isDone = step.isCompleted;
                    final bool hasVoucher =
                        step.remarks.toLowerCase().contains("included") ||
                        step.remarks.toLowerCase().contains("ticket") ||
                        step.remarks.toLowerCase().contains("voucher");
                    final bool isWarn =
                        step.remarks.toLowerCase().contains("direct payment") ||
                        step.remarks.contains("4X4") ||
                        step.remarks.contains("160");

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone
                              ? KazinColors.greenAcceptedBg
                              : (isWarn
                                    ? KazinColors.amberWarningText.withValues(
                                        alpha: 0.5,
                                      )
                                    : KazinColors.borderSubtle),
                          width: isDone ? 1.5 : 1.0,
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
                                    step.time,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: KazinColors.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (hasVoucher)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: KazinColors.lightTeal,
                                        borderRadius: BorderRadius.circular(4),
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
                                  isDone
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isDone
                                      ? KazinColors.secondaryTeal
                                      : KazinColors.textMuted,
                                ),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  // Update directly in local SQLite DB and reactive state
                                  arrivalCtrl.toggleStepCompletion(
                                    step.id,
                                    isDone,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isDone
                                  ? KazinColors.textMuted
                                  : KazinColors.primaryNavy,
                            ),
                          ),
                          if (step.content.isNotEmpty &&
                              step.content != step.title) ...[
                            const SizedBox(height: 4),
                            Text(
                              step.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: KazinColors.textSecondary,
                              ),
                            ),
                          ],
                          if (isWarn && step.remarks.isNotEmpty) ...[
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
                                      step.remarks,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                          if (hasVoucher) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => Get.toNamed(Routes.DOCUMENT_WALLET),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    size: 14,
                                    color: KazinColors.secondaryTeal,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      step.remarks.isNotEmpty
                                          ? step.remarks
                                          : "Open Voucher",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: KazinColors.secondaryTeal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // Quick Execution Controls
              const Text(
                "Quick Field Actions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
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

              // Day Closure CTA (Updated: only closes tour on last day, otherwise closes day locally)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastDay
                      ? KazinColors.greenAcceptedText
                      : KazinColors.secondaryTeal,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () {
                  if (isLastDay) {
                    Get.toNamed(Routes.SERVICE_CLOSURE);
                  } else {
                    for (var s in currentTasks) {
                      if (!s.isCompleted) {
                        arrivalCtrl.toggleStepCompletion(s.id, false);
                      }
                    }
                    Get.snackbar(
                      "Day Concluded",
                      "Day ${currentIndex + 1} checkpoints marked complete locally.",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Text(
                  isLastDay
                      ? "Close Tour Assignment"
                      : "Complete & Close Day ${currentIndex + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
