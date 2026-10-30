import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/check_list_model.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:kazin_guide_app/screens/assignments/assignment_details_screen.dart';
import 'package:kazin_guide_app/widgets/sync_status_indicator.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  String _getCurrentDateAndMonth() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${now.day} ${months[now.month - 1]}";
  }

  void _onChecklistItemTap(
    BuildContext context,
    ChecklistItemModel item,
    TourFileModel? file,
    KazinController ctrl,
  ) {
    HapticFeedback.lightImpact();

    // Agar marked nahi hai to background me check call karein (One-way)
    if (!item.isChecked) {
      ctrl.markItemCompleted(checklistId: item.checklistId, status: true);
    }

    // View Details screen par navigate karein
    if (file != null) {
      Get.to(
        () => AssignmentDetailsScreen(tourFile: file),
        arguments: {"tourFile": file, "highlightType": item.type},
      );
    } else {
      Get.snackbar(
        "Notice",
        "Tour dossier file load nahi hui hai.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
            // 1. Authenticated Guide Header with Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: KazinColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getCurrentDateAndMonth(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: KazinColors.textSecondary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Hello, ${authService.firstName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: KazinColors.primaryNavy,
                          letterSpacing: -0.8,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: KazinColors.primaryBlue.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: KazinColors.primaryBlue,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                authService.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: KazinColors.primaryNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SyncStatusIndicator(size: 38),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: KazinColors.primaryBlue.withValues(
                            alpha: 0.25,
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 21,
                        backgroundColor: const Color.fromRGBO(15, 23, 42, 1),
                        backgroundImage:
                            authService.photoUrl != null &&
                                authService.photoUrl!.isNotEmpty
                            ? NetworkImage(authService.photoUrl!)
                            : null,
                        child:
                            authService.photoUrl == null ||
                                authService.photoUrl!.isEmpty
                            ? Text(
                                authService.firstName.isNotEmpty
                                    ? authService.firstName[0].toUpperCase()
                                    : "G",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Operational Metric Boxes (2x2 Grid: Live, Upcoming, Completed, Alerts)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: KazinColors.borderSubtle),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Row 1: Live & Upcoming
                  Row(
                    children: [
                      Obx(
                        () => _buildMetricTile(
                          count: "${assignmentsCtrl.activeAssignments.length}",
                          label: "Live Files",
                          icon: Icons.play_circle_outline_rounded,
                          iconColor: KazinColors.secondaryTeal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Obx(
                        () => _buildMetricTile(
                          count:
                              "${assignmentsCtrl.upcomingAssignments.length}",
                          label: "Upcoming",
                          icon: Icons.calendar_month_outlined,
                          iconColor: KazinColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: Completed & Alerts
                  Row(
                    children: [
                      Obx(
                        () => _buildMetricTile(
                          count:
                              "${assignmentsCtrl.completedAssignments.length}",
                          label: "Completed",
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: KazinColors.greenAcceptedText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Obx(() {
                        final alertCount = assignmentsCtrl.pendingAlerts.length;
                        return _buildMetricTile(
                          count: "$alertCount",
                          label: "Alerts",
                          icon: Icons.notification_important_outlined,
                          iconColor: alertCount > 0
                              ? KazinColors.redDanger
                              : KazinColors.textSecondary,
                          isAlert: alertCount > 0,
                          onTap: () {
                            ctrl.currentBottomNavIndex.value = 2; // Alerts Tab
                            ctrl.markAlertsAsRead();
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Active Dossier Card with Gated Live Button
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

              final int adults = file.numAdults > 0
                  ? file.numAdults
                  : file.numberPersons;
              final int children = file.numChild;
              final String guestDetails = children > 0
                  ? "$adults Adults, $children Child"
                  : "$adults Adults";

              // Check if today's checklist is finished
              int displayDay =
                  arrivalCtrl.calculateInitialDayIndex(sortedDates) + 1;
              final bool canOpenLive = ctrl.isTodayChecklistCompleted(
                "Day $displayDay",
              );

              // Format Arrival Date
              final String rawArrival = file.arrivalDate.isNotEmpty
                  ? file.arrivalDate
                  : file.checkInDate;
              final String formattedArrivalDate = assignmentsCtrl
                  .formatToDDMMYYYY(rawArrival);

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
                            file.enquiryNo.isNotEmpty
                                ? file.enquiryNo
                                : "${file.arrivalId}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: KazinColors.primaryNavy,
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
                        "${file.leadName} ($guestDetails)",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Arrival Date Row
                      Row(
                        children: [
                          const Icon(
                            Icons.flight_land_rounded,
                            size: 16,
                            color: KazinColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Arrival Date: $formattedArrivalDate",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: KazinColors.primaryNavy,
                            ),
                          ),
                        ],
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
                          Expanded(
                            child: Text(
                              "${file.transport?.vehicleName ?? 'Sedan'} • Driver: ${file.driver?.name ?? 'Assigned'}",
                              maxLines: 1,
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
                              "${file.hotel?.hotelName ?? 'Hotel'} (${file.hotel?.category ?? ''})",
                              maxLines: 1,
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

                      // Action Buttons
                      if (isFileClosed)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KazinColors.primaryNavy,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: () => Get.to(
                            () => AssignmentDetailsScreen(tourFile: file),
                          ),
                          child: const Text("View Details"),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canOpenLive
                                      ? KazinColors.greenAcceptedText
                                      : KazinColors.borderSubtle,
                                  foregroundColor: canOpenLive
                                      ? Colors.white
                                      : KazinColors.textMuted,
                                  elevation: canOpenLive ? 2 : 0,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: canOpenLive
                                    ? () {
                                        arrivalCtrl.resetToToday();
                                        Get.toNamed(Routes.LIVE_SERVICE);
                                      }
                                    : () {
                                        Get.snackbar(
                                          "Checklist Incomplete",
                                          "Review Todays checklist first.",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor:
                                              KazinColors.amberWarningBg,
                                          colorText:
                                              KazinColors.amberWarningText,
                                          margin: const EdgeInsets.all(16),
                                          borderRadius: 12,
                                        );
                                      },
                                icon: Icon(
                                  canOpenLive
                                      ? Icons.play_circle_fill
                                      : Icons.lock_outline_rounded,
                                  size: 18,
                                  color: canOpenLive
                                      ? Colors.white
                                      : KazinColors.textMuted,
                                ),
                                label: Text(
                                  "Open Live",
                                  style: TextStyle(
                                    fontWeight: canOpenLive
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 14,
                                    color: canOpenLive
                                        ? Colors.white
                                        : KazinColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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

            // 4. TODAY'S DAILY INSTRUCTIONS
            Obx(() {
              final file = arrivalCtrl.activeTourFile.value;
              final groups = ctrl.checklistGroups;

              // Current Active Day Number calculate karein (Day 1, Day 2 etc.)
              int displayDay = 1;
              if (file != null) {
                final Map<String, List<ItineraryStepModel>> grouped = {};
                for (var step in file.itinerary) {
                  final dateKey = step.date.split('T')[0];
                  if (dateKey.isNotEmpty) {
                    grouped.putIfAbsent(dateKey, () => []).add(step);
                  }
                }
                final sortedDates = grouped.keys.toList()..sort();
                displayDay =
                    arrivalCtrl.calculateInitialDayIndex(sortedDates) + 1;
              }

              // Sirf AAJ KE DIN ka group nikalna
              DayChecklistGroup? todayGroup;
              if (groups.isNotEmpty) {
                todayGroup = groups.firstWhereOrNull(
                  (g) =>
                      g.label.toLowerCase() == "day $displayDay".toLowerCase(),
                );
                todayGroup ??= groups.first;
              }

              final todayItems = todayGroup?.items ?? [];

              // Counter calculate sirf AAJ KE tasks ke liye hoga
              final int todayTotal = todayItems.length;
              final int todayDone = todayItems.where((i) => i.isChecked).length;
              final bool isTodayCompleted =
                  todayTotal > 0 && todayDone == todayTotal;

              return Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: KazinColors.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Day Title & Today's Progress Badge
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
                              Text(
                                "${todayGroup?.label ?? 'Day $displayDay'} • Instructions",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: KazinColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isTodayCompleted
                                  ? KazinColors.greenAcceptedBg
                                  : KazinColors.amberWarningBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$todayDone / $todayTotal Done",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isTodayCompleted
                                    ? KazinColors.greenAcceptedText
                                    : KazinColors.amberWarningText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      if (ctrl.isChecklistLoading.value)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: KazinColors.primaryNavy,
                            ),
                          ),
                        )
                      else if (todayItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              "Today's Instructions are not available.",
                              style: TextStyle(
                                fontSize: 13,
                                color: KazinColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      else
                        ...todayItems.map((item) {
                          final bool isChecked = item.isChecked;
                          final bool isThisLoading =
                              ctrl.markingChecklistId.value == item.checklistId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: isThisLoading
                                  ? null
                                  : () => _onChecklistItemTap(
                                      context,
                                      item,
                                      file,
                                      ctrl,
                                    ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? KazinColors.greenAcceptedBg
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isChecked
                                        ? KazinColors.greenAcceptedText
                                        : KazinColors.borderSubtle,
                                    width: isChecked ? 1.5 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isChecked
                                          ? KazinColors.greenAcceptedText
                                                .withValues(alpha: 0.08)
                                          : Colors.black.withValues(
                                              alpha: 0.02,
                                            ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 1. Circular Icon Pill
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isChecked
                                            ? Colors.white
                                            : KazinColors.blueInfoBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isChecked
                                            ? Icons.check_circle_rounded
                                            : ctrl.getTypeIcon(item.type),
                                        size: 20,
                                        color: isChecked
                                            ? KazinColors.greenAcceptedText
                                            : KazinColors.primaryNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // 2. Task Title & Subtitle / Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              height: 1.25,
                                              color: isChecked
                                                  ? KazinColors
                                                        .greenAcceptedText
                                                  : KazinColors.primaryNavy,
                                            ),
                                          ),
                                          if (item.details != null &&
                                              item.details!
                                                  .trim()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              item.details!.trim(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isChecked
                                                    ? KazinColors
                                                          .greenAcceptedText
                                                          .withValues(
                                                            alpha: 0.85,
                                                          )
                                                    : KazinColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // 3. Trailing Arrow Navigation Icon
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: isChecked
                                          ? KazinColors.greenAcceptedText
                                                .withValues(alpha: 0.8)
                                          : KazinColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetricTile({
    required String count,
    required String label,
    required IconData icon,
    required Color iconColor,
    bool isAlert = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isAlert
                  ? KazinColors.amberWarningBg.withValues(alpha: 0.4)
                  : KazinColors.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
              border: isAlert
                  ? Border.all(
                      color: KazinColors.redDanger.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isAlert
                            ? KazinColors.redDanger
                            : KazinColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAlert
                            ? KazinColors.redDanger
                            : KazinColors.textSecondary,
                        fontWeight: isAlert ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
