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

  // ACTIVE TAB: Sirf actual arrival/active file jo closed ya cancelled nahi hai
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
        fetchUpcomingAssignments(),
        fetchCompletedAssignments(),
      ]);
    } catch (e) {
      log("Error loading all assignments: $e");
    } finally {
      isFetchingLists.value = false;
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
      return "${inDt.day} ${months[inDt.month - 1]} - ${outDt.day} ${months[outDt.month - 1]} ${outDt.year}";
    } catch (_) {
      return "$checkIn → $checkOut";
    }
  }

  void openLiveService(TourFileModel file) {
    arrivalCtrl.resetToToday();
    Get.toNamed(Routes.LIVE_SERVICE);
  }

  // Accept File via ApiService -> Success hone par fetchUpcomingAssignments() se lists re-sync honge
  Future<bool> acceptTourFile(dynamic fileOrSummary) async {
    isActionLoading.value = true;
    final int enquiryId = fileOrSummary is TourFileModel
        ? fileOrSummary.enquiryId
        : (fileOrSummary as AssignmentSummaryModel).enquiryId;
    final int arrivalId = fileOrSummary is TourFileModel
        ? fileOrSummary.arrivalId
        : (fileOrSummary as AssignmentSummaryModel).arrivalId;

    try {
      final response = await _apiService.acceptFile(
        enquiryId: enquiryId,
        arrivalId: arrivalId,
      );

      if (response.isOk && response.body?['success'] == true) {
        Get.snackbar(
          "Assignment Accepted",
          response.body?['message'] ?? "File accepted successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.greenAcceptedBg,
          colorText: KazinColors.greenAcceptedText,
        );

        // Upcoming API dobara call karke lists sync karein
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
