import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final ApiService _apiService = Get.put(ApiService());

  final isLoggingOut = false.obs;

  String get guideName => authService.fullName;
  String get guideLocation => authService.location;
  String get guideLanguages => authService.languages;
  String get guidePhone => authService.formattedPhone;
  String? get photoUrl => authService.photoUrl;

  void showLogoutConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: KazinColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to log out?",
                style: TextStyle(
                  fontSize: 14,
                  color: KazinColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: KazinColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KazinColors.redDanger,
                        minimumSize: const Size(100, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoggingOut.value ? null : _performLogout,
                      child: isLoggingOut.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    isLoggingOut.value = true;
    log(
      '🚪 [LOGOUT] Initiating logout for Guide ID: ${authService.guideId}...',
    );

    try {
      await _apiService.logout(
        guideId: authService.guideId,
        contactNumber: authService.savedPhone,
        sessionToken: authService.sessionToken,
      );
    } catch (e) {
      log('⚠️ [LOGOUT ERROR] Exception during logout API call: $e');
    } finally {
      isLoggingOut.value = false;
      authService.clearSession();

      if (Get.isRegistered<KazinController>()) {
        Get.find<KazinController>().currentBottomNavIndex.value = 0;
        Get.delete<KazinController>();
      }

      if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
        Get.back();
      }

      Get.offAllNamed(Routes.LOGIN);
      log('✅ [LOGOUT] Reset nav to 0 and navigated to login');
    }
  }
}
