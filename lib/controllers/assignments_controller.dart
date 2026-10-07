// lib/controllers/assignments_controller.dart me:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:kazin_guide_app/screens/assignments/assignment_details_screen.dart';

class AssignmentsController extends GetxController with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final ArrivalController arrivalCtrl = Get.find<ArrivalController>();

  final selectedTabIndex = 0.obs;

  // RxList taaki dynamically upcoming list reactive rahe
  final upcomingFilesList = <TourFileModel>[].obs;

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

  List<TourFileModel> get activeAssignments {
    final file = activeFile;
    if (file == null) return [];
    final status = file.status.toLowerCase();
    if (status.contains("active") || status.contains("live") || status.contains("assigned")) {
      return [file];
    }
    return [];
  }

  // Active file check + Accepted alert files list
  List<TourFileModel> get upcomingAssignments => upcomingFilesList;

  List<TourFileModel> get completedAssignments {
    final file = activeFile;
    if (file == null) return [];
    final status = file.status.toLowerCase();
    if (status.contains("closed") || status.contains("completed")) {
      return [file];
    }
    return [];
  }

  // Nayi file add karne ka method (Alert screen se call hoga)
  void addUpcomingAssignment(TourFileModel file) {
    if (!upcomingFilesList.any((f) => f.arrivalId == file.arrivalId)) {
      upcomingFilesList.add(file);
    }
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