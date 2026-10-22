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
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon + Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: KazinColors.redDanger.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: KazinColors.redDanger,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Sign Out",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description Text
              const Text(
                "Are you sure you want to end your active session and sign out of Kazin Guide?",
                style: TextStyle(
                  fontSize: 13,
                  color: KazinColors.textSecondary,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              // Subtle Note for Field Guides
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: KazinColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KazinColors.borderSubtle),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: KazinColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Ensure offline itinerary updates are synced before signing out.",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Modern Action Buttons (Cancel + Logout)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KazinColors.textSecondary,
                        minimumSize: const Size.fromHeight(46),
                        side: const BorderSide(color: KazinColors.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KazinColors.redDanger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoggingOut.value ? null : _performLogout,
                        child: isLoggingOut.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Sign Out",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
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
