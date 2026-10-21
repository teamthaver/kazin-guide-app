import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/db_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class ArrivalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final DbService _dbService = DbService.instance;

  final activeTourFile = Rxn<TourFileModel>();
  final isLoading = false.obs;
  final activeDayIndex = 0.obs;

  final ScrollController dayPillScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadArrivalData();
  }

  @override
  void onClose() {
    dayPillScrollController.dispose();
    super.onClose();
  }

  Future<void> loadArrivalData() async {
    isLoading.value = true;
    try {
      final localData = await _dbService.getActiveTourFile();
      if (localData != null) {
        activeTourFile.value = localData;
        _autoSelectTodayIndex(localData);
      }

      final response = await _apiService.loadArrivalData(
        guideId: _authService.guideId,
      );

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final List dataList = response.body['data'] ?? [];
        if (dataList.isNotEmpty) {
          final freshTour = TourFileModel.fromJson(dataList.first);

          await _dbService.saveTourFile(freshTour);
          activeTourFile.value = freshTour;
          _autoSelectTodayIndex(freshTour);
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void _autoSelectTodayIndex(TourFileModel file) {
    final Map<String, List<ItineraryStepModel>> grouped = {};
    for (var step in file.itinerary) {
      final dateKey = step.date.split('T')[0];
      if (dateKey.isNotEmpty) {
        grouped.putIfAbsent(dateKey, () => []).add(step);
      }
    }
    final sortedDates = grouped.keys.toList()..sort();
    final initialIndex = calculateInitialDayIndex(sortedDates);
    activeDayIndex.value = initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedDay(initialIndex);
    });
  }

  void selectDay(int index) {
    activeDayIndex.value = index;
    scrollToSelectedDay(index);
  }

  void scrollToSelectedDay(int index) {
    if (!dayPillScrollController.hasClients) return;

    const double itemExtent = 124.0;
    final double screenWidth = Get.width;
    final double targetOffset =
        (index * itemExtent) - (screenWidth / 2) + (itemExtent / 2);

    final double maxScroll = dayPillScrollController.position.maxScrollExtent;
    final double clampedOffset = targetOffset.clamp(0.0, maxScroll);

    dayPillScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  int calculateInitialDayIndex(List<String> sortedDates) {
    if (sortedDates.isEmpty) return 0;

    final now = DateTime.now();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    for (int i = 0; i < sortedDates.length; i++) {
      final tourDate = sortedDates[i].split("T")[0];
      if (tourDate == todayStr) {
        return i;
      }
    }

    final firstDate = DateTime.tryParse(sortedDates.first);
    if (firstDate != null && now.isBefore(firstDate)) {
      return 0;
    }

    final lastDate = DateTime.tryParse(sortedDates.last);
    if (lastDate != null && now.isAfter(lastDate)) {
      return sortedDates.length - 1;
    }

    return 0;
  }

  void resetToToday() {
    final file = activeTourFile.value;
    if (file == null) return;

    final Map<String, List<ItineraryStepModel>> grouped = {};
    for (var step in file.itinerary) {
      final dateKey = step.date.split('T')[0];
      if (dateKey.isNotEmpty) {
        grouped.putIfAbsent(dateKey, () => []).add(step);
      }
    }
    final sortedDates = grouped.keys.toList()..sort();
    final todayIndex = calculateInitialDayIndex(sortedDates);
    activeDayIndex.value = todayIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToSelectedDay(todayIndex);
    });
  }

  void _updateInMemoryStepStatus(int stepId, bool status) {
    final current = activeTourFile.value;
    if (current == null) return;

    final updatedSteps = current.itinerary.map((s) {
      if (s.id == stepId) {
        return ItineraryStepModel(
          id: s.id,
          date: s.date,
          time: s.time,
          title: s.title,
          content: s.content,
          remarks: s.remarks,
          isCompleted: status,
        );
      }
      return s;
    }).toList();

    activeTourFile.value = TourFileModel(
      arrivalId: current.arrivalId,
      arrivalDate: current.arrivalDate,
      guideId: current.guideId,
      groupType: current.groupType,
      leadName: current.leadName,
      leadContact: current.leadContact,
      status: current.status,
      enquiryId: current.enquiryId,
      enquiryNo: current.enquiryNo,
      numberPersons: current.numberPersons,
      checkInDate: current.checkInDate,
      checkOutDate: current.checkOutDate,
      numberOfNights: current.numberOfNights,
      itinerary: updatedSteps,
      flights: current.flights,
      hotel: current.hotel,
      restaurants: current.restaurants,
      persons: current.persons,
      driver: current.driver,
      transport: current.transport,
    );
  }

  // --- POST /api/action/mark-completed ---
  Future<void> submitMarkCompleted({
    required int itineraryId,
    required int arrivalId,
    String? delayReason,
    File? imageFile,
  }) async {
    final now = DateTime.now();
    // Document rule: Local "YYYY-MM-DD HH:MM"
    final currentTime =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    isLoading.value = true;
    try {
      final response = await _apiService.markCompleted(
        itineraryId: itineraryId,
        arrivalId: arrivalId,
        currentTime: currentTime,
        delayReason: delayReason,
        imageFile: imageFile,
      );

      if (response.statusCode == 200 && response.body?['success'] == true) {
        // Update SQLite and Reactive State
        await _dbService.updateStepStatus(itineraryId, true);
        _updateInMemoryStepStatus(itineraryId, true);

        Get.snackbar(
          "Checkpoint Completed",
          response.body?['message'] ?? "Activity marked as completed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.greenAcceptedBg,
          colorText: KazinColors.greenAcceptedText,
        );
      } else if (response.statusCode == 400 &&
          response.body?['message'] == "Provide delay reason.") {
        // Guide late condition - prompt for mandatory delay reason
        final delayedMinutes =
            response.body?['delayed_by_minutes']?.toString() ?? "";
        _promptDelayReason(
          itineraryId: itineraryId,
          arrivalId: arrivalId,
          imageFile: imageFile,
          delayedMinutes: delayedMinutes,
        );
      }
      //  else {
      //   final message =
      //       response.body?['message'] ?? "Failed to mark activity completed.";
      //   Get.snackbar("Notice", message, snackPosition: SnackPosition.BOTTOM);
      // }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Unable to submit checkpoint completion.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _promptDelayReason({
    required int itineraryId,
    required int arrivalId,
    File? imageFile,
    required String delayedMinutes,
  }) {
    final reasonCtrl = TextEditingController();

    Get.defaultDialog(
      title: "Delay Reason Required",
      titleStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: KazinColors.primaryNavy,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            delayedMinutes.isNotEmpty
                ? "This activity is being completed $delayedMinutes minutes after scheduled time. Please state reason:"
                : "Activity is delayed. Please specify the delay reason:",
            style: const TextStyle(
              fontSize: 13,
              color: KazinColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "e.g. Heavy traffic, guest request, weather...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: KazinColors.primaryNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (reasonCtrl.text.trim().isEmpty) {
            Get.snackbar(
              "Alert",
              "Delay reason cannot be empty.",
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
          Get.back();
          submitMarkCompleted(
            itineraryId: itineraryId,
            arrivalId: arrivalId,
            delayReason: reasonCtrl.text.trim(),
            imageFile: imageFile,
          );
        },
        child: const Text(
          "Submit with Reason",
          style: TextStyle(color: Colors.white),
        ),
      ),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  // Fallback direct toggle for offline/manual checkbox
  Future<void> toggleStepCompletion(int stepId, bool currentStatus) async {
    await _dbService.updateStepStatus(stepId, !currentStatus);
    _updateInMemoryStepStatus(stepId, !currentStatus);
  }
}
