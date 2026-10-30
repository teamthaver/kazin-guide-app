import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/assignment_summary_model.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class AssignmentsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final ArrivalController arrivalCtrl = Get.find<ArrivalController>();
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();

  final selectedTabIndex = 0.obs;
  final isActionLoading = false.obs;
  final isFetchingLists = false.obs;

  // 1. Unaccepted files (is_accepted == 0) -> Alerts / Action required section ke liye
  final pendingAssignments = <AssignmentSummaryModel>[].obs;

  // 2. Confirmed upcoming files (is_accepted == 1) -> Upcoming Tab ke liye
  final upcomingAssignments = <AssignmentSummaryModel>[].obs;

  // 3. Completed tour files -> Completed Tab ke liye
  final completedAssignments = <AssignmentSummaryModel>[].obs;

  final pendingAlerts = <AssignmentSummaryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });
    fetchAllData();
  }

  bool get isLoading => arrivalCtrl.isLoading.value || isFetchingLists.value;

  TourFileModel? get activeFile => arrivalCtrl.activeTourFile.value;

  List<TourFileModel> get activeAssignments {
    final file = activeFile;
    if (file == null) return [];

    final status = file.status.toLowerCase().trim();
    if (status.contains("closed") ||
        status.contains("completed") ||
        status.contains("cancelled") ||
        status.contains("rejected")) {
      return [];
    }

    return [file];
  }

  // Teeno APIs sync karein
  Future<void> fetchAllData() async {
    isFetchingLists.value = true;
    try {
      await arrivalCtrl.loadArrivalData();

      await Future.wait([
        fetchAlertsData(),
        fetchUpcomingAssignments(),
        fetchCompletedAssignments(),
      ]);
    } catch (e) {
      log("Error loading all assignments: $e");
    } finally {
      isFetchingLists.value = false;
    }
  }

  String formatToDDMMYYYY(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return "N/A";
    try {
      final dt = DateTime.parse(rawDate.trim());
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      return "$day-$month-$year";
    } catch (_) {
      // Agar backend se "2026-11-15 14:30:00" jaisa format aaye
      try {
        final parts = rawDate.trim().split(' ')[0].split('-');
        if (parts.length == 3) {
          return "${parts[2].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}-${parts[0]}";
        }
      } catch (_) {}
      return rawDate;
    }
  }

  String formatRangeDDMMYYYY(String checkIn, String checkOut) {
    final start = formatToDDMMYYYY(checkIn);
    final end = formatToDDMMYYYY(checkOut);
    return "$start  to  $end";
  }

  // 1. Unlocked TourFileModel files ki reactive list (/upcoming-details se)
  final upcomingTourFiles = <TourFileModel>[].obs;

  // Kaunsi file ki details load ho rahi hai (single item loader tracking)
  final loadingArrivalId = RxnInt();

  Future<void> openUpcomingFileDetails(AssignmentSummaryModel item) async {
    if (!item.isDetailsUnlocked) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_clock_rounded, color: KazinColors.primaryNavy),
              SizedBox(width: 8),
              Text(
                "Dossier Locked",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: KazinColors.primaryNavy,
                ),
              ),
            ],
          ),
          content: Text(
            "This file will be unlock only before 48 hours before its execution.\n\nStarts in: ${item.arrivalDate} days.",
            style: const TextStyle(
              fontSize: 13,
              color: KazinColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 48-Hour Unlocked File: Fetch details
    loadingArrivalId.value = item.arrivalId;
    try {
      final response = await _apiService.loadUpcomingDetails(
        arrivalId: item.arrivalId,
      );

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final List dataList = response.body['data'] ?? [];
        if (dataList.isNotEmpty) {
          final TourFileModel fullTourFile = TourFileModel.fromJson(
            dataList.first,
          );

          // Details Screen par navigate karein
          Get.toNamed(
            Routes.ASSIGNMENT_DETAILS,
            arguments: {"tourFile": fullTourFile, "isNewAssignment": false},
          );
        }
      } else if (response.statusCode == 403 &&
          response.body is Map &&
          response.body['code'] == 'DETAILS_NOT_OPEN') {
        Get.snackbar(
          "Dossier Locked",
          "Details will open 48 hours prior to check-in.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.redDanger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("❌ [OPEN UPCOMING DETAILS ERROR]: $e");
    } finally {
      loadingArrivalId.value = null; // Loader hide
    }
  }

  Future<void> fetchAlertsData() async {
    try {
      final response = await _apiService.loadAlertData(
        guideId: _authService.guideId,
      );

      log("📥 [ALERT API RESPONSE]: ${response.body}");

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final List list = response.body['data'] ?? [];
        final parsedList = <AssignmentSummaryModel>[];

        for (var item in list) {
          try {
            parsedList.add(AssignmentSummaryModel.fromJson(item));
          } catch (err) {
            log("❌ [ALERT PARSE ERROR]: $err | data: $item");
          }
        }

        // List update karein
        pendingAlerts.assignAll(parsedList);

        log(
          "✅ [ALERTS FETCHED]: ${pendingAlerts.length} files waiting for action",
        );
      } else {
        log("⚠️ [ALERT API FAILED]: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      log("❌ [ALERT API EXCEPTION]: $e");
    }
  }

  // Upcoming API Fetching (/api/guide/upcoming) & Splitting based on is_accepted
  Future<void> fetchUpcomingAssignments() async {
    try {
      final res = await _apiService.loadUpcommingData(
        guideId: _authService.guideId,
      );

      log("📥 [UPCOMING API RESPONSE]: ${res.body}");

      if (res.isOk && res.body != null && res.body['success'] == true) {
        final List list = res.body['data'] ?? [];
        final unacceptedList = <AssignmentSummaryModel>[];
        final acceptedUpcomingList = <AssignmentSummaryModel>[];

        final currentActiveArrivalId = activeFile?.arrivalId ?? 0;
        final activeStatus = activeFile?.status.toLowerCase().trim() ?? "";
        final isExecutionLive =
            activeStatus == "active" || activeStatus == "live";

        for (var item in list) {
          try {
            final summary = AssignmentSummaryModel.fromJson(item);

            // Agar same file abhi execute ho rahi hai, to usko skip karein
            if (currentActiveArrivalId > 0 &&
                summary.arrivalId == currentActiveArrivalId &&
                isExecutionLive) {
              continue;
            }

            // is_accepted ke basis par divide karein
            if (summary.isAccepted == 0) {
              unacceptedList.add(summary); // Alerts & Review section
            } else {
              acceptedUpcomingList.add(summary); // Confirmed Upcoming list
            }
          } catch (err) {
            log("❌ [UPCOMING PARSE ERROR]: $err | data: $item");
          }
        }

        pendingAssignments.assignAll(unacceptedList);
        upcomingAssignments.assignAll(acceptedUpcomingList);

        log(
          "✅ [ASSIGNMENTS SPLIT]: Pending Alert = ${pendingAssignments.length}, Upcoming = ${upcomingAssignments.length}",
        );
      }
    } catch (e) {
      log("❌ [UPCOMING EXCEPTION]: $e");
    }
  }

  // Completed API Fetching (/api/guide/completed)
  Future<void> fetchCompletedAssignments() async {
    try {
      final res = await _apiService.loadCompletedData(
        guideId: _authService.guideId,
      );

      if (res.isOk && res.body != null && res.body['success'] == true) {
        final List list = res.body['data'] ?? [];
        final parsedList = <AssignmentSummaryModel>[];

        for (var item in list) {
          try {
            parsedList.add(AssignmentSummaryModel.fromJson(item));
          } catch (err) {
            log("Error parsing completed item: $err | data: $item");
          }
        }

        completedAssignments.assignAll(parsedList);
      }
    } catch (e) {
      log("Error fetching completed assignments: $e");
    }
  }

  Future<void> refreshAssignments() async {
    await fetchAllData();
  }

  String formatDateRange(String checkIn, String checkOut) {
    try {
      final inDt = DateTime.parse(checkIn);
      final outDt = DateTime.parse(checkOut);
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
      return "${inDt.day}-${months[inDt.month - 1]}-${inDt.year} / ${outDt.day}-${months[outDt.month - 1]}-${outDt.year}";
    } catch (_) {
      return "$checkIn → $checkOut";
    }
  }

  void openLiveService(TourFileModel file) {
    arrivalCtrl.resetToToday();
    Get.toNamed(Routes.LIVE_SERVICE);
  }

  // Specific arrival ID tracking
  final acceptingArrivalId = RxnInt();

  Future<bool> acceptTourFile(dynamic fileOrSummary) async {
    final int enquiryId = fileOrSummary is TourFileModel
        ? fileOrSummary.enquiryId
        : (fileOrSummary as AssignmentSummaryModel).enquiryId;
    final int arrivalId = fileOrSummary is TourFileModel
        ? fileOrSummary.arrivalId
        : (fileOrSummary as AssignmentSummaryModel).arrivalId;

    // Sirf is specific ID ko loader ke liye set karein
    acceptingArrivalId.value = arrivalId;
    isActionLoading.value = true;

    try {
      final response = await _apiService.acceptFile(
        enquiryId: enquiryId,
        arrivalId: arrivalId,
      );

      if (response.isOk && response.body?['success'] == true) {
        // Pending list se remove karein
        pendingAlerts.removeWhere((e) => e.arrivalId == arrivalId);
        await fetchUpcomingAssignments();

        Get.snackbar(
          "Assignment Accepted",
          "Tour assignment successfully confirmed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.greenAcceptedBg,
          colorText: KazinColors.greenAcceptedText,
        );
        return true;
      }
      return false;
    } catch (_) {
      Get.snackbar(
        "Error",
        "Network connection failed.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      // Done hone par null reset karein
      acceptingArrivalId.value = null;
      isActionLoading.value = false;
    }
  }

  // Reject / Decline file action
  Future<bool> declineTourFile({
    required int enquiryId,
    required int arrivalId,
    required String declineReason,
    String? mentionedReason,
  }) async {
    isActionLoading.value = true;
    try {
      final response = await _apiService.rejectFile(
        enquiryId: enquiryId,
        arrivalId: arrivalId,
        declineReason: declineReason,
        mentionedReason: mentionedReason,
      );

      if (response.isOk && response.body?['success'] == true) {
        Get.snackbar(
          "Assignment Declined",
          response.body?['message'] ?? "Assignment declined.",
          snackPosition: SnackPosition.BOTTOM,
        );

        // Reject hone ke baad bhi lists sync karein
        await fetchUpcomingAssignments();
        return true;
      }
      return false;
    } catch (_) {
      Get.snackbar(
        "Error",
        "Network connection failed.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  bool isFileClosed(TourFileModel file) {
    final status = file.status.toLowerCase();
    return status.contains("closed") || status.contains("completed");
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
