import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentDetailsController extends GetxController {
  final selectedDayIndex = 0.obs;

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
