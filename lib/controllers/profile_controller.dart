import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/auth_service/auth_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final guideName = "Arjun Mehta".obs;
  final guideLocation = "New Delhi, India".obs;
  final guideLanguages = "English · Hindi · French".obs;
  final guideEmail = "arjun.mehta@kazin.com".obs;
  final profileCompletion = 0.90.obs;

  // Make guidePhone an observable RxString
  final guidePhone = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadPhoneNumber();
  }

  void _loadPhoneNumber() {
    final phone = _authService.savedPhone;
    guidePhone.value = phone.isNotEmpty ? "+91 $phone" : "+91 98765 43210";
  }

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
                "Are you sure you want to log out? Offline cached records will remain saved on this device.",
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KazinColors.redDanger,
                      minimumSize: const Size(100, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      _authService.clearSession();
                      Get.offAllNamed(Routes.LOGIN);
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
