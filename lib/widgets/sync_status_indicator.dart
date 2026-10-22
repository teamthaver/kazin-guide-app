import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:kazin_guide_app/core/services/network_sync_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class SyncStatusIndicator extends StatelessWidget {
  final double size;
  const SyncStatusIndicator({super.key, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final netSync = Get.isRegistered<NetworkSyncService>()
          ? Get.find<NetworkSyncService>()
          : null;

      final bool isOnline = netSync?.isOnline.value ?? true;
      final bool isSyncing = netSync?.isSyncing.value ?? false;

      // 1. Syncing State (Smooth Continuous Loop via TweenAnimationBuilder)
      if (isSyncing) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: KazinColors.blueInfoBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: KazinColors.primaryBlue.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1100),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.141592653589793,
                  child: child,
                );
              },
              child: const Icon(
                Icons.sync_rounded,
                size: 20,
                color: KazinColors.primaryBlue,
              ),
            ),
          ),
        );
      }

      // 2. Offline State
      if (!isOnline) {
        return InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: () {
            Get.snackbar(
              "Offline Mode",
              "Changes are saved in SQLite and will sync automatically when back online.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF1E293B),
              colorText: Colors.white,
            );
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.cloud_off_rounded,
                size: 19,
                color: Color(0xFFD97706),
              ),
            ),
          ),
        );
      }

      // 3. Synced & Online (Tap to trigger sync)
      return InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: () {
          HapticFeedback.selectionClick();
          netSync?.syncPendingData();
          Get.snackbar(
            "Sync Status",
            "Everything is up-to-date with Kazin server.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KazinColors.greenAcceptedBg,
            colorText: KazinColors.greenAcceptedText,
            duration: const Duration(seconds: 2),
          );
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: KazinColors.greenAcceptedBg.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: KazinColors.greenAcceptedText.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.cloud_done_rounded,
              size: 20,
              color: KazinColors.greenAcceptedText,
            ),
          ),
        ),
      );
    });
  }
}