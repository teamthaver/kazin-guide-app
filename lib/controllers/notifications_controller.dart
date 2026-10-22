import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/models/assignment_summary_model.dart';

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

  // Nayi AssignmentReviewScreen par Summary object pass karein
  void openAssignmentDetails(AssignmentSummaryModel item) {
    Get.toNamed(
      Routes.ASSIGNMENT_REVIEW,
      arguments: {"assignmentSummary": item},
    );
  }
}
