import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../core/routes/app_pages.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: KazinColors.greenAcceptedBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: KazinColors.greenAcceptedText,
                ),
                SizedBox(width: 4),
                Text(
                  "Synced successfully",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: KazinColors.greenAcceptedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: KazinColors.scaffoldBg,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: KazinColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        ctrl.guideName.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        ctrl.guideLocation.value,
                        style: const TextStyle(
                          color: KazinColors.textSecondary,
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProfileField(
                          "Languages",
                          ctrl.guideLanguages.value,
                        ),
                        Obx(
                          () => _buildProfileField(
                            "Phone",
                            ctrl.guidePhone.value,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: KazinColors.primaryBlue,
                    ),
                    title: const Text("Documents"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.toNamed(Routes.DOCUMENT_WALLET),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.menu_book_outlined,
                      color: KazinColors.secondaryTeal,
                    ),
                    title: const Text("SOP / Guide Handbook"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.toNamed(Routes.SOP_HANDBOOK),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text("Settings"),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: KazinColors.redDanger,
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        color: KazinColors.redDanger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: ctrl.showLogoutConfirmation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProfileField(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: KazinColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
