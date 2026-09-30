import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'assignment_details_screen.dart';

// Controller jo filter, search aur list state manage karega
class AssignmentsListController extends GetxController {
  final searchQuery = "".obs;
  final selectedFilter = "All".obs;

  final filterOptions = ["All", "Today", "Upcoming", "Action Required"];

  // Real tour data models
  final allAssignments = <Map<String, dynamic>>[
    {
      "fileId": "FILE #KZ10231",
      "guestName": "Smith Family & Group",
      "pax": "10 PAX",
      "packageTitle": "Almaty 5D/4N Complete Package",
      "dateRange": "25-Sep to 29-Sep-2026",
      "serviceType": "Airport Arrival & City Tour",
      "reportingTime": "10:20 AM",
      "pickupLocation": "Almaty Int'l Airport (1st Floor)",
      "destination": "The Ritz-Carlton Almaty",
      "status": "ACCEPTED",
      "isAccepted": true,
      "category": "Today",
    },
    {
      "fileId": "FILE #KZ10244",
      "guestName": "Mehta Group",
      "pax": "8 PAX",
      "packageTitle": "Charyn Canyon & Kolsai Lakes",
      "dateRange": "02-Oct to 05-Oct-2026",
      "serviceType": "Canyon Day Excursion",
      "reportingTime": "08:30 AM",
      "pickupLocation": "Hotel Kazakhstan",
      "destination": "Charyn Valley of Castles",
      "status": "ACTION REQUIRED",
      "isAccepted": false,
      "category": "Action Required",
    },
    {
      "fileId": "FILE #KZ10251",
      "guestName": "Wilson Couple",
      "pax": "2 PAX",
      "packageTitle": "Romantic Shymbulak Getaway",
      "dateRange": "10-Oct to 12-Oct-2026",
      "serviceType": "Mountain Transfer & Cable Car",
      "reportingTime": "09:00 AM",
      "pickupLocation": "InterContinental Almaty",
      "destination": "Shymbulak Mountain Resort",
      "status": "NEW",
      "isAccepted": false,
      "category": "Upcoming",
    },
  ].obs;

  // Filtered list getter
  List<Map<String, dynamic>> get filteredList {
    return allAssignments.where((item) {
      final matchesSearch =
          item["guestName"].toString().toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          item["fileId"].toString().toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );

      if (!matchesSearch) return false;

      if (selectedFilter.value == "All") return true;
      if (selectedFilter.value == "Today" && item["category"] == "Today") {
        return true;
      }
      if (selectedFilter.value == "Upcoming" &&
          item["category"] == "Upcoming") {
        return true;
      }
      if (selectedFilter.value == "Action Required" &&
          (item["category"] == "Action Required" ||
              item["status"] == "ACTION REQUIRED")) {
        return true;
      }
      return false;
    }).toList();
  }
}

class AssignmentsListScreen extends StatelessWidget {
  const AssignmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AssignmentsListController());

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "All Assignments",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: KazinColors.blueInfoBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(
              () => Center(
                child: Text(
                  "${ctrl.filteredList.length} Files",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: KazinColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) => ctrl.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: "Search by file ID, guest or tour...",
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: KazinColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: KazinColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: KazinColors.scaffoldBg,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: KazinColors.borderSubtle,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: KazinColors.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter Pills
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ctrl.filterOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final option = ctrl.filterOptions[index];
                      return Obx(() {
                        final isSelected = ctrl.selectedFilter.value == option;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ctrl.selectedFilter.value = option;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? KazinColors.primaryNavy
                                  : KazinColors.scaffoldBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? KazinColors.primaryNavy
                                    : KazinColors.borderSubtle,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : KazinColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Assignments List
          Expanded(
            child: Obx(() {
              final list = ctrl.filteredList;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.assignment_late_outlined,
                        size: 48,
                        color: KazinColors.textMuted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No assignments found",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Try searching with a different file ID or filter.",
                        style: TextStyle(
                          fontSize: 13,
                          color: KazinColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = list[index];
                  final bool isAccepted = item["isAccepted"] == true;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // File ID & Status Chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item["fileId"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: KazinColors.textSecondary,
                                ),
                              ),
                              _buildStatusChip(item["status"]),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Guest Name & PAX
                          Text(
                            item["guestName"],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: KazinColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${item["pax"]}  •  ${item["serviceType"]}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: KazinColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Divider(height: 20),

                          // Reporting Time & Dates
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: KazinColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Time: ${item["reportingTime"]}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: KazinColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: KazinColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item["dateRange"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KazinColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Route / Location
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me_outlined,
                                size: 16,
                                color: KazinColors.secondaryTeal,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "${item["pickupLocation"]} ➔ ${item["destination"]}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: KazinColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dynamic Action Button
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAccepted
                                        ? KazinColors.primaryNavy
                                        : KazinColors.primaryBlue,
                                    elevation: 0,
                                    minimumSize: const Size.fromHeight(46),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Pass isAlreadyAccepted parameter dynamically
                                    Get.to(
                                      () => AssignmentDetailsScreen(
                                        isAlreadyAccepted: isAccepted,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    isAccepted
                                        ? "View Active File"
                                        : "Review & Respond",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Status Badge Builder
  static Widget _buildStatusChip(String status) {
    Color bg;
    Color text;

    switch (status) {
      case "ACCEPTED":
        bg = KazinColors.greenAcceptedBg;
        text = KazinColors.greenAcceptedText;
        break;
      case "ACTION REQUIRED":
        bg = KazinColors.amberWarningBg;
        text = KazinColors.amberWarningText;
        break;
      case "NEW":
      default:
        bg = KazinColors.blueInfoBg;
        text = KazinColors.primaryBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: text,
        ),
      ),
    );
  }
}
