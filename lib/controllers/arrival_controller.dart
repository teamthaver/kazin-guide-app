// lib/controllers/arrival_controller.dart
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/db_service.dart';
import 'package:kazin_guide_app/model/tour_file_model.dart';

class ArrivalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final DbService _dbService = DbService.instance;

  final activeTourFile = Rxn<TourFileModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadArrivalData();
  }

  Future<void> loadArrivalData() async {
    isLoading.value = true;
    try {
      // 1. Pehle local SQLite se offline cache load karein (Zero UI delay)
      final localData = await _dbService.getActiveTourFile();
      if (localData != null) {
        activeTourFile.value = localData;
      }

      // 2. Network se fresh data fetch karein
      final response = await _apiService.loadArrivalData(
        guideId: _authService.guideId,
      );

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final List dataList = response.body['data'] ?? [];
        if (dataList.isNotEmpty) {
          final freshTour = TourFileModel.fromJson(dataList.first);

          // 3. SQLite me save karein
          await _dbService.saveTourFile(freshTour);
          activeTourFile.value = freshTour;
        }
      }
    } catch (_) {
      // Offline fallback already handled from SQLite
    } finally {
      isLoading.value = false;
    }
  }

  // Live Task Toggle (Offline & Online sync)
  Future<void> toggleStepCompletion(int stepId, bool currentStatus) async {
    await _dbService.updateStepStatus(stepId, !currentStatus);
    // UI update
    loadArrivalData();
  }
}
