import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/controllers/live_pulse_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class LivePulseFloatingButton extends StatelessWidget {
  const LivePulseFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LivePulseController());
    final ctrl = Get.find<KazinController>();

    return Obx(() {
      final arrivalCtrl = Get.find<ArrivalController>();
      final file = arrivalCtrl.activeTourFile.value;

      int displayDay = 1;
      if (file != null) {
        final Map<String, List<ItineraryStepModel>> grouped = {};
        for (var step in file.itinerary) {
          final dateKey = step.date.split('T')[0];
          if (dateKey.isNotEmpty) {
            grouped.putIfAbsent(dateKey, () => []).add(step);
          }
        }
        final sortedDates = grouped.keys.toList()..sort();
        displayDay = arrivalCtrl.calculateInitialDayIndex(sortedDates) + 1;
      }

      // Sirf aaj ke din ki checklist complete hone par pulse button open hoga
      final bool canOpenLive = ctrl.isTodayChecklistCompleted(
        "Day $displayDay",
      );

      return SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (canOpenLive)
              AnimatedBuilder(
                animation: controller.pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: controller.scaleAnimation.value,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: KazinColors.redDanger.withValues(
                          alpha: controller.opacityAnimation.value,
                        ),
                      ),
                    ),
                  );
                },
              ),

            FloatingActionButton(
              elevation: canOpenLive ? 4 : 0,
              highlightElevation: canOpenLive ? 8 : 0,
              backgroundColor: canOpenLive
                  ? KazinColors.primaryNavy
                  : KazinColors.borderSubtle,
              shape: const CircleBorder(),
              onPressed: () {
                if (!canOpenLive) {
                  Get.snackbar(
                    "Checklist Incomplete",
                    "Please review all instructions for Day $displayDay before starting live execution.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: KazinColors.amberWarningBg,
                    colorText: KazinColors.amberWarningText,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                  return;
                }
                arrivalCtrl.resetToToday();
                Get.toNamed(Routes.LIVE_SERVICE);
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: canOpenLive
                      ? KazinColors.redDanger
                      : KazinColors.textMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    canOpenLive
                        ? Icons.play_arrow_rounded
                        : Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
