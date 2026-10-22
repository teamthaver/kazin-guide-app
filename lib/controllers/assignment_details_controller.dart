import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/db_service.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final DbService _dbService = DbService.instance;

  final selectedDayIndex = 0.obs;
  final isLoading = false.obs;
  final tourFile = Rxn<TourFileModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    // 1. Jodi already full object pass hoye thake
    if (args != null &&
        args.containsKey("tourFile") &&
        args["tourFile"] != null) {
      tourFile.value = args["tourFile"] as TourFileModel;
    }
    // 2. Jodi shudhu arrivalId pass hoy, tobe details fetch koro
    else if (args != null && args.containsKey("arrivalId")) {
      final int arrivalId = args["arrivalId"];
      fetchTourDossier(arrivalId);
    }
  }

  Future<void> fetchTourDossier(int arrivalId) async {
    isLoading.value = true;
    try {
      // Local SQLite cache check
      final cached = await _dbService.getActiveTourFile();
      if (cached != null && cached.arrivalId == arrivalId) {
        tourFile.value = cached;
      }

      // Backend API call
      final response = await _apiService.loadArrivalData(
        guideId: _authService.guideId,
      );

      if (response.isOk && response.body?['success'] == true) {
        final List dataList = response.body['data'] ?? [];
        final match = dataList.firstWhereOrNull(
          (item) => item['arrival_id'] == arrivalId,
        );

        if (match != null) {
          final loadedModel = TourFileModel.fromJson(match);
          tourFile.value = loadedModel;
          await _dbService.saveTourFile(loadedModel);
        }
      }
    } catch (e) {
      log("Error fetching dossier: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectDay(int index) {
    selectedDayIndex.value = index;
  }

  Map<String, List<ItineraryStepModel>> groupByDate(
    List<ItineraryStepModel> steps,
  ) {
    final Map<String, List<ItineraryStepModel>> grouped = {};
    for (var step in steps) {
      final dateKey = step.date.split('T')[0];
      if (dateKey.isNotEmpty) {
        grouped.putIfAbsent(dateKey, () => []).add(step);
      }
    }
    return grouped;
  }

  String formatShortDate(String isoDate) {
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

  Future<void> safeLaunch(String urlString) async {
    try {
      final uri = Uri.parse(urlString.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Launch Error: $e");
    }
  }
}
