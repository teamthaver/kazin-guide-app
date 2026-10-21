import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/profile_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/widgets/profile_image_viewer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          "Guide Profile",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            // fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: KazinColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: KazinColors.primaryNavy.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Clickable Avatar with Full Preview
                  GestureDetector(
                    onTap: () {
                      ProfileImageViewer.show(
                        imageUrl: ctrl.photoUrl,
                        name: ctrl.guideName,
                        heroTag: 'profile_screen_avatar',
                      );
                    },
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'profile_screen_avatar',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 96,
                              height: 96,
                              color: KazinColors.primaryNavy,
                              child: ctrl.photoUrl != null
                                  ? Image.network(
                                      ctrl.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _buildFallbackInitial(ctrl.guideName),
                                    )
                                  : _buildFallbackInitial(ctrl.guideName),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: KazinColors.secondaryTeal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Guide Full Name
                  Text(
                    ctrl.guideName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role & Region
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 15,
                        color: KazinColors.secondaryTeal,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Certified DMC Guide",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.secondaryTeal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: KazinColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ctrl.guideLocation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: KazinColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Personal & Professional Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: KazinColors.primaryBlue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Personal & Operational Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: KazinColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildProfileField(
                      icon: Icons.phone_outlined,
                      label: "Contact Number",
                      value: ctrl.guidePhone,
                    ),
                    _buildProfileField(
                      icon: Icons.language_rounded,
                      label: "Spoken Languages",
                      value: ctrl.guideLanguages,
                    ),
                    _buildProfileField(
                      icon: Icons.location_city_outlined,
                      label: "Operating Region",
                      value: ctrl.guideLocation,
                    ),
                    _buildProfileField(
                      icon: Icons.pin_drop_outlined,
                      label: "Country",
                      value:
                          ctrl.authService.guideData['country']?.toString() ??
                          "Kazakhstan",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Settings & Preferences
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.offline_bolt_outlined,
                        color: KazinColors.secondaryTeal,
                      ),
                      title: const Text(
                        "Offline Tour Cache",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "All active vouchers & routes kept locally",
                        style: TextStyle(
                          fontSize: 12,
                          color: KazinColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: KazinColors.secondaryTeal,
                        size: 20,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.security_outlined,
                        color: KazinColors.primaryNavy,
                      ),
                      title: const Text(
                        "Privacy & Policy",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: KazinColors.textMuted,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Action Button
            OutlinedButton.icon(
              onPressed: ctrl.showLogoutConfirmation,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text("Sign Out"),
              style: OutlinedButton.styleFrom(
                foregroundColor: KazinColors.redDanger,
                side: const BorderSide(color: KazinColors.redDanger),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "G",
        style: const TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: KazinColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: KazinColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KazinColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
