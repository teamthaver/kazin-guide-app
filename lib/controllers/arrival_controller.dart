import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
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
      // 1. Offline Fallback: Pehle local cached data load karein
      final localData = await _dbService.getActiveTourFile();
      if (localData != null) {
        activeTourFile.value = localData;
        _autoSelectTodayIndex(localData);

        // Cached file ki checklist load karein agar controller registered ho
        if (Get.isRegistered<KazinController>()) {
          Get.find<KazinController>().fetchChecklist(localData.arrivalId);
        }
      }

      // 2. Server se live arrival check karein
      final response = await _apiService.loadArrivalData(
        guideId: _authService.guideId,
      );

      // Agar server reachable hai aur valid success response mila hai
      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final List dataList = response.body['data'] ?? [];

        if (dataList.isNotEmpty) {
          // Case A: Nayi active tour file mili -> Local DB update karein aur state refresh karein
          final freshTour = TourFileModel.fromJson(dataList.first);
          await _dbService.saveTourFile(freshTour);
          activeTourFile.value = freshTour;
          _autoSelectTodayIndex(freshTour);

          // Server checklist fetch trigger karein
          if (Get.isRegistered<KazinController>()) {
            Get.find<KazinController>().fetchChecklist(freshTour.arrivalId);
          }
        } else {
          // Case B: Server par koi active file nahi hai (dataList empty)
          await _dbService.clearActiveTourFile();
          activeTourFile.value = null;

          if (Get.isRegistered<KazinController>()) {
            Get.find<KazinController>().clearChecklist();
          }
        }
      }
    } catch (_) {
      // Offline mode me local cached data barkarar rahega
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

  void _updateInMemoryStepStatus(int stepId, int status) {
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
          completedAt: s.completedAt,
          delayReason: s.delayReason,
          image: s.image,
        );
      }
      return s;
    }).toList();

    activeTourFile.value = TourFileModel(
      arrivalId: current.arrivalId,
      arrivalDate: current.arrivalDate,
      groupType: current.groupType,
      leadName: current.leadName,
      leadIsdCode: current.leadIsdCode,
      leadContact: current.leadContact,
      leadPhoto: current.leadPhoto,
      hotelId: current.hotelId,
      numberRooms: current.numberRooms,
      numAdults: current.numAdults,
      numChild: current.numChild,
      childAges: current.childAges,
      driverId: current.driverId,
      status: current.status,
      remarks: current.remarks,
      enquiryId: current.enquiryId,
      enquiryNo: current.enquiryNo,
      enquiryAbbr: current.enquiryAbbr,
      enquirySequence: current.enquirySequence,
      mode: current.mode,
      numberPersons: current.numberPersons,
      checkInDate: current.checkInDate,
      checkOutDate: current.checkOutDate,
      numberOfNights: current.numberOfNights,
      enquiryFor: current.enquiryFor,
      enquiryType: current.enquiryType,
      enquiryRemarks: current.enquiryRemarks,
      guideId: current.guideId,
      itinerary: updatedSteps,
      flights: current.flights,
      hotel: current.hotel,
      restaurants: current.restaurants,
      persons: current.persons,
      driver: current.driver,
      transport: current.transport,
    );
  }

  int _calculateDelayInMinutes(String stepDate, String stepTime) {
    try {
      final dateOnly = stepDate.split('T')[0];
      final timeParts = stepTime.trim().split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final scheduledDateTime = DateTime(
        int.parse(dateOnly.split('-')[0]),
        int.parse(dateOnly.split('-')[1]),
        int.parse(dateOnly.split('-')[2]),
        hour,
        minute,
      );

      final now = DateTime.now();
      return now.difference(scheduledDateTime).inMinutes;
    } catch (_) {
      return 0;
    }
  }

  // --- POST /api/action/mark-completed With Offline Delay Detection ---
  Future<void> submitMarkCompleted({
    required int itineraryId,
    required int arrivalId,
    String? delayReason,
    File? imageFile,
  }) async {
    final now = DateTime.now();
    final currentTime =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final current = activeTourFile.value;
    final step = current?.itinerary.firstWhereOrNull(
      (s) => s.id == itineraryId,
    );

    if ((delayReason == null || delayReason.trim().isEmpty) && step != null) {
      final delayMins = _calculateDelayInMinutes(step.date, step.time);
      if (delayMins > 15) {
        _promptDelayReason(
          itineraryId: itineraryId,
          arrivalId: arrivalId,
          imageFile: imageFile,
          delayedMinutes: delayMins.toString(),
        );
        return;
      }
    }

    await _dbService.updateStepStatus(itineraryId, true);
    _updateInMemoryStepStatus(itineraryId, 1);

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
        Get.snackbar(
          "Checkpoint Completed",
          response.body?['message'] ?? "Activity marked as completed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.greenAcceptedBg,
          colorText: KazinColors.greenAcceptedText,
        );
      } else if (response.statusCode == 400 &&
          response.body?['message'] == "Provide delay reason.") {
        final delayedMinutes =
            response.body?['delayed_by_minutes']?.toString() ?? "";
        _promptDelayReason(
          itineraryId: itineraryId,
          arrivalId: arrivalId,
          imageFile: imageFile,
          delayedMinutes: delayedMinutes,
        );
      } else {
        await _queueForSync(
          itineraryId,
          arrivalId,
          currentTime,
          delayReason,
          imageFile,
        );
      }
    } catch (_) {
      await _queueForSync(
        itineraryId,
        arrivalId,
        currentTime,
        delayReason,
        imageFile,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _queueForSync(
    int itineraryId,
    int arrivalId,
    String currentTime,
    String? delayReason,
    File? imageFile,
  ) async {
    await _dbService.queueOfflineAction(
      actionType: 'mark_completed',
      payload: {
        'itinerary_id': itineraryId,
        'arrival_id': arrivalId,
        'current_time': currentTime,
        'delay_reason': delayReason,
      },
      imagePaths: imageFile != null ? [imageFile.path] : [],
    );

    Get.snackbar(
      "Saved Offline",
      "Activity marked complete. Will sync automatically when online.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      icon: const Icon(Icons.cloud_off_rounded, color: Colors.white),
    );
  }

  String _formatDelayDuration(String delayedMinutes) {
    final totalMins = int.tryParse(delayedMinutes) ?? 0;
    if (totalMins <= 0) return "";

    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;

    if (hours > 0 && mins > 0) {
      return "${hours}h ${mins}m";
    } else if (hours > 0) {
      return "${hours}h";
    } else {
      return "${mins}m";
    }
  }

  void _promptDelayReason({
    required int itineraryId,
    required int arrivalId,
    File? imageFile,
    required String delayedMinutes,
  }) {
    final reasonCtrl = TextEditingController();
    final formattedDelay = _formatDelayDuration(delayedMinutes);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: KazinColors.amberWarningBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: KazinColors.amberWarningText,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Delay Notice",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: KazinColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KazinColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: KazinColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formattedDelay.isNotEmpty
                            ? "Activity is completing $formattedDelay past the scheduled time."
                            : "This activity is completing behind schedule.",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Reason for Delay Log *",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: KazinColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KazinColors.primaryNavy,
                ),
                decoration: InputDecoration(
                  hintText:
                      "e.g., Guest request, heavy traffic, weather delay...",
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: KazinColors.textMuted,
                  ),
                  filled: true,
                  fillColor: KazinColors.scaffoldBg,
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: KazinColors.borderSubtle,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: KazinColors.primaryNavy,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KazinColors.textSecondary,
                        minimumSize: const Size.fromHeight(46),
                        side: const BorderSide(color: KazinColors.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KazinColors.primaryNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final reason = reasonCtrl.text.trim();
                        if (reason.isEmpty) {
                          Get.snackbar(
                            "Required Field",
                            "Please provide a delay reason to continue.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: KazinColors.redDanger,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                          return;
                        }
                        Get.back();
                        submitMarkCompleted(
                          itineraryId: itineraryId,
                          arrivalId: arrivalId,
                          delayReason: reason,
                          imageFile: imageFile,
                        );
                      },
                      child: const Text(
                        "Submit Checkpoint",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
      barrierDismissible: false,
    );
  }

  Future<void> toggleStepCompletion(int stepId, int currentStatus) async {
    final nextStatus = currentStatus == 1 ? 0 : 1;
    await _dbService.updateStepStatus(stepId, nextStatus == 1);
    _updateInMemoryStepStatus(stepId, nextStatus);
  }
}
