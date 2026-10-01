import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/model/tour_file_model.dart';
import 'package:kazin_guide_app/screens/assignments/assignment_details_screen.dart';

class AssignmentsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final ArrivalController arrivalCtrl = Get.find<ArrivalController>();

  final selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });
  }

  TourFileModel? get activeFile => arrivalCtrl.activeTourFile.value;
  bool get isLoading => arrivalCtrl.isLoading.value;

  // Filtered List getters for each tab
  List<TourFileModel> get activeAssignments {
    final file = activeFile;
    if (file == null) return [];
    final status = file.status.toLowerCase();
    if (status.contains("active") ||
        status.contains("live") ||
        status.contains("assigned")) {
      return [file];
    }
    return [];
  }

  List<TourFileModel> get upcomingAssignments {
    final file = activeFile;
    if (file == null) return [];
    final status = file.status.toLowerCase();
    if (status.contains("upcoming") || status.contains("pending")) {
      return [file];
    }
    return [];
  }

  List<TourFileModel> get completedAssignments {
    final file = activeFile;
    if (file == null) return [];
    final status = file.status.toLowerCase();
    if (status.contains("closed") || status.contains("completed")) {
      return [file];
    }
    return [];
  }

  Future<void> refreshAssignments() async {
    await arrivalCtrl.loadArrivalData();
  }

  void openLiveService(TourFileModel file) {
    Get.toNamed(Routes.LIVE_SERVICE);
  }

  void viewDossier(TourFileModel file) {
    Get.to(() => AssignmentDetailsScreen(tourFile: file));
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
