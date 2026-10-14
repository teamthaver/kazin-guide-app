import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
 import 'package:kazin_guide_app/models/tour_file_model.dart';

class NotificationsController extends GetxController {
  final filters = ["All", "Assignments", "Changes", "Reminders", "Urgent"];
  final selectedFilter = "All".obs;

   final hasNewAssignment = true.obs;

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void removeAssignmentNotification() {
    hasNewAssignment.value = false;
  }

  void openAssignmentDetails(TourFileModel file) {
    Get.toNamed(
      Routes.ASSIGNMENT_DETAILS,
      arguments: {"tourFile": file, "isNewAssignment": true},
    );
  }
}
