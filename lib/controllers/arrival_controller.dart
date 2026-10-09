import 'package:get/get.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/db_service.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class ArrivalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final DbService _dbService = DbService.instance;

  final activeTourFile = Rxn<TourFileModel>();
  final isLoading = false.obs;
  final activeDayIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadArrivalData();
  }

  Future<void> loadArrivalData() async {
    isLoading.value = true;
    try {
      final localData = await _dbService.getActiveTourFile();
      if (localData != null) {
        activeTourFile.value = localData;
      }

      // 2. Fresh Network fetch
      final response = await _apiService.loadArrivalData(
        guideId: _authService.guideId,
      );

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final List dataList = response.body['data'] ?? [];
        if (dataList.isNotEmpty) {
          final freshTour = TourFileModel.fromJson(dataList.first);

          // 3. SQLite me replace/save karein
          await _dbService.saveTourFile(freshTour);
          activeTourFile.value = freshTour;
        }
      }
    } catch (_) {
      // Offline fallback already active from SQLite
    } finally {
      isLoading.value = false;
    }
  }

  // Live Task Toggle (SQLite local persistence)
  Future<void> toggleStepCompletion(int stepId, bool currentStatus) async {
    await _dbService.updateStepStatus(stepId, !currentStatus);

    // In-memory model update for zero flicker
    final current = activeTourFile.value;
    if (current != null) {
      final updatedSteps = current.itinerary.map((s) {
        if (s.id == stepId) {
          return ItineraryStepModel(
            id: s.id,
            date: s.date,
            time: s.time,
            title: s.title,
            content: s.content,
            remarks: s.remarks,
            isCompleted: !currentStatus,
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
  }
}
