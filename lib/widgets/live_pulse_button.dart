import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/live_pulse_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class LivePulseFloatingButton extends StatelessWidget {
  const LivePulseFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller inject ya find karein
    final controller = Get.put(LivePulseController());

    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Wave Outer Pulse
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

          // Main Floating Action Button
          FloatingActionButton(
            elevation: 4,
            highlightElevation: 8,
            backgroundColor: KazinColors.primaryNavy,
            shape: const CircleBorder(),
            onPressed: () => Get.toNamed(Routes.LIVE_SERVICE),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: KazinColors.redDanger,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
