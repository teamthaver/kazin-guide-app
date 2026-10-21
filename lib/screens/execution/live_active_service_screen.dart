import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

        if (sortedDates.isEmpty) {
          return const Center(
            child: Text("No itinerary steps available for this assignment."),
          );
        }

        final int currentIndex =
            (arrivalCtrl.activeDayIndex.value < sortedDates.length)
            ? arrivalCtrl.activeDayIndex.value
            : 0;

        final String selectedDate = sortedDates[currentIndex];
        final List<ItineraryStepModel> currentTasks =
            grouped[selectedDate] ?? [];
        final bool isLastDay = currentIndex == sortedDates.length - 1;

        final String currentDayTitle = currentTasks.isNotEmpty
            ? currentTasks.first.title
            : "Tour Operations";
        final String currentTarget = currentTasks.isNotEmpty
            ? currentTasks.first.content
            : "Daily Sightseeing & Transfers";
        final String vehicleDisplayName =
            file.transport?.vehicleName ?? "Sedan";
        final String vehicleTypes = file.transport?.vehicleType ?? "";

        final int completedCount = currentTasks
            .where((s) => s.isCompleted)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Status Card (Day 1 Header)
              if (currentIndex == 0) ...[
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
                            "FILE #${file.enquiryNo}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
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
                      // const SizedBox(height: 4),
                      // Text(
                      //   "$currentDayTitle • Driver: ${file.driver?.name ?? 'Assigned'}",
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     color: Colors.white70,
                      //     fontSize: 13,
                      //   ),
                      // ),
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
              ],

              // Auto-scrolling Horizontal Day Pills
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedDates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSel = currentIndex == index;
                    return _DayPillItem(
                      index: index,
                      isSelected: isSel,
                      dateText: _formatDayPill(sortedDates[index]),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        arrivalCtrl.activeDayIndex.value = index;
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Route & Vehicle Status Card
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: KazinColors.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
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
                              color: KazinColors.primaryNavy,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
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
                      // const SizedBox(height: 10),
                      // Text(
                      //   currentTarget,
                      //   maxLines: 4,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     fontWeight: FontWeight.w600,
                      //     fontSize: 13,
                      //     height: 1.3,
                      //   ),
                      // ),
                      // if (vehicleTypes.isNotEmpty) ...[
                      //   const SizedBox(height: 6),
                      //   Text(
                      //     "Vehicle Fleet: $vehicleTypes",
                      //     maxLines: 2,
                      //     overflow: TextOverflow.ellipsis,
                      //     style: const TextStyle(
                      //       fontSize: 11,
                      //       color: KazinColors.textSecondary,
                      //     ),
                      //   ),
                      // ],
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  Get.toNamed(Routes.MAP_NAVIGATION),
                              icon: const Icon(
                                Icons.navigation_outlined,
                                size: 16,
                              ),
                              label: const Text("Live GPS"),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
                              icon: const Icon(Icons.call_outlined, size: 16),
                              label: Text(
                                file.driver?.name ?? "Driver",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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

              // Modern Checkpoints Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Day ${currentIndex + 1} Itineraries",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: completedCount == currentTasks.length
                          ? KazinColors.greenAcceptedBg
                          : KazinColors.blueInfoBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$completedCount / ${currentTasks.length} Completed",
                      style: TextStyle(
                        color: completedCount == currentTasks.length
                            ? KazinColors.greenAcceptedText
                            : KazinColors.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Interactive Modern Tasks
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDone
                          ? KazinColors.greenAcceptedText.withValues(alpha: 0.3)
                          : KazinColors.borderSubtle,
                      width: isDone ? 1.4 : 1.0,
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
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header (Time, Tags, Action/Status)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: KazinColors.scaffoldBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    step.time,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: KazinColors.primaryNavy,
                                    ),
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

                            // One-Way Toggle: If done, shows locked 'Completed' pill, otherwise tap to execute
                            if (isDone)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: KazinColors.greenAcceptedBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: KazinColors.greenAcceptedText,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Completed",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: KazinColors.greenAcceptedText,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  _showMarkCompletedSheet(
                                    context,
                                    arrivalCtrl,
                                    step,
                                    file.arrivalId,
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: KazinColors.scaffoldBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: KazinColors.borderSubtle,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.radio_button_unchecked,
                                        size: 14,
                                        color: KazinColors.textSecondary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Done",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: KazinColors.primaryNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Title (Never strikethrough, clean typography)
                        Text(
                          step.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDone
                                ? KazinColors.primaryNavy.withValues(
                                    alpha: 0.85,
                                  )
                                : KazinColors.primaryNavy,
                          ),
                        ),
                        // if (step.content.isNotEmpty &&
                        //     step.content != step.title) ...[
                        //   const SizedBox(height: 4),
                        //   Text(
                        //     step.content,
                        //     maxLines: 3,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: const TextStyle(
                        //       fontSize: 12,
                        //       color: KazinColors.textSecondary,
                        //       height: 1.35,
                        //     ),
                        //   ),
                        // ],
                        if (isWarn && step.remarks.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: KazinColors.amberWarningBg.withValues(
                                alpha: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(8),
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
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Quick Execution Controls
              const Text(
                "Quick Field Actions",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: KazinColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastDay
                      ? KazinColors.greenAcceptedText
                      : KazinColors.secondaryTeal,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (isLastDay) {
                    Get.toNamed(Routes.SERVICE_CLOSURE);
                  } else {
                    for (var s in currentTasks) {
                      if (!s.isCompleted) {
                        // arrivalCtrl.toggleStepCompletion(s.id, false);
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

  // Modern BottomSheet for Checkpoint Completion (Remarks + Picture)
  static void _showMarkCompletedSheet(
    BuildContext context,
    ArrivalController arrivalCtrl,
    ItineraryStepModel step,
    int arrivalId,
  ) {
    final remarksCtrl = TextEditingController();
    final attachedPhoto = Rxn<File>();
    final ImagePicker picker = ImagePicker();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: KazinColors.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Complete Itinerary Activity",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: KazinColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: KazinColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Photo Attachment Box
              const Text(
                "Proof / Activity Photo (Optional)",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: KazinColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final file = attachedPhoto.value;
                if (file != null) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          width: double.infinity,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => attachedPhoto.value = null,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(
                            color: KazinColors.borderSubtle,
                          ),
                        ),
                        onPressed: () async {
                          final img = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                          );
                          if (img != null) {
                            attachedPhoto.value = File(img.path);
                          }
                        },
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text("Camera"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(
                            color: KazinColors.borderSubtle,
                          ),
                        ),
                        onPressed: () async {
                          final img = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (img != null) {
                            attachedPhoto.value = File(img.path);
                          }
                        },
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const Text("Gallery"),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),

              // Operational Remarks
              const Text(
                "Execution Remarks (Optional)",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: KazinColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarksCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Add execution remarks or observations...",
                  filled: true,
                  fillColor: KazinColors.scaffoldBg,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirmation Action
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.secondaryTeal,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  HapticFeedback.heavyImpact();
                  arrivalCtrl.submitMarkCompleted(
                    itineraryId: step.id,
                    arrivalId: arrivalId,
                    delayReason: remarksCtrl.text.trim().isEmpty
                        ? null
                        : remarksCtrl.text.trim(),
                    imageFile: attachedPhoto.value,
                  );
                },
                child: const Text(
                  "Confirm Itinerary Completion",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
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

class _DayPillItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final String dateText;
  final VoidCallback onTap;

  const _DayPillItem({
    required this.index,
    required this.isSelected,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? KazinColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? KazinColors.primaryNavy
                : KazinColors.borderSubtle,
          ),
        ),
        child: Center(
          child: Text(
            "Day ${index + 1} ($dateText)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : KazinColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
