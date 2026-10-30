import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/models/check_list_model.dart';

class KazinController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final currentBottomNavIndex = 0.obs;
  final isOffline = false.obs;
  final syncStatusText = "Synced successfully".obs;

  final hasUnreadAlerts = true.obs;

  void markAlertsAsRead() {
    hasUnreadAlerts.value = false;
  }

  // --- Real Dynamic Checklist Observables (from POST /checklist) ---
  final checklistGroups = <DayChecklistGroup>[].obs;
  final isChecklistLoading = false.obs;
  final markingChecklistId = RxnInt(); // Specific item loader

  final totalDone = 0.obs;
  final totalCount = 0.obs;

  /// Overall File Completion Rule
  bool get isChecklistFullyCompleted =>
      totalCount.value > 0 && totalDone.value >= totalCount.value;

  bool isTodayChecklistCompleted(String currentDayLabel) {
    if (checklistGroups.isEmpty) return false;

    // 1. Current Day ka Group search karein
    final todayGroup = checklistGroups.firstWhereOrNull(
      (g) =>
          g.label.trim().toLowerCase() == currentDayLabel.trim().toLowerCase(),
    );

    // Fallback: Agar exact match na mile to first available group consider karein
    final targetGroup = todayGroup ?? checklistGroups.first;

    if (targetGroup.items.isEmpty) return false;

    // 2. Check karein ki target group ke sabhi items checked hain ya nahi
    return targetGroup.items.every((item) => item.isChecked);
  }

  /// Fetch checklist from POST /checklist for current arrival_id
  Future<void> fetchChecklist(int arrivalId) async {
    if (arrivalId <= 0) return;
    isChecklistLoading.value = true;
    try {
      final response = await _apiService.loadChecklist(arrivalId: arrivalId);
      log("📥 [CHECKLIST RESPONSE]: ${response.body}");

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final parsed = DailyChecklistResponseModel.fromJson(response.body);
        checklistGroups.assignAll(parsed.groups);
        totalDone.value = parsed.totalDone;
        totalCount.value = parsed.totalCount;
      }
    } catch (e) {
      log("❌ [FETCH CHECKLIST ERROR]: $e");
    } finally {
      isChecklistLoading.value = false;
    }
  }

  /// Mark / Unmark item via POST /checklist/mark
  Future<bool> markItemCompleted({
    required int checklistId,
    required bool status,
  }) async {
    markingChecklistId.value = checklistId;
    try {
      final response = await _apiService.markChecklistItem(
        checklistId: checklistId,
        checked: status,
      );

      if (response.isOk && response.body?['success'] == true) {
        // Local state update
        for (var group in checklistGroups) {
          for (var item in group.items) {
            if (item.checklistId == checklistId) {
              item.isChecked = status;
              break;
            }
          }
        }
        _recalculateCounts();
        checklistGroups.refresh();
        return true;
      }
    } catch (e) {
      log("❌ [MARK ITEM ERROR]: $e");
    } finally {
      markingChecklistId.value = null;
    }
    return false;
  }

  void _recalculateCounts() {
    int done = 0;
    int total = 0;
    for (var g in checklistGroups) {
      for (var item in g.items) {
        total++;
        if (item.isChecked) done++;
      }
    }
    totalDone.value = done;
    totalCount.value = total;
  }

  void clearChecklist() {
    checklistGroups.clear();
    totalDone.value = 0;
    totalCount.value = 0;
  }

  IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'itinerary':
        return Icons.map_outlined;
      case 'guests':
        return Icons.people_outline_rounded;
      case 'driver':
        return Icons.person_pin_circle_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'hotel':
        return Icons.hotel_outlined;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.fact_check_outlined;
    }
  }

  // --- Airport & Closure Logic ---
  final airportCurrentStep = 0.obs;
  final airportSteps = [
    "Airport Arrived",
    "Guest Contacted",
    "Guest Met",
    "Guests In Vehicle",
    "Hotel Reached",
  ];

  final currentExecutionStep = 2.obs;

  final expenseCategory = "Transport".obs;
  final expenseAmount = "0.00".obs;
  final expenseCurrency = "INR".obs;

  final cashReconcileConfirmed = false.obs;

  final closureChecks = <String, bool>{
    "Service completed": true,
    "Incidents resolved": true,
    "Expenses submitted": true,
    "Lost & Found checked": true,
    "Guest feedback requested": true,
    "Cash reconciled": true,
  }.obs;

  void toggleClosureCheck(String key) {
    if (closureChecks.containsKey(key)) {
      closureChecks[key] = !closureChecks[key]!;
    }
  }

  void nextAirportStep() {
    if (airportCurrentStep.value < airportSteps.length - 1) {
      airportCurrentStep.value++;
    }
  }
}
