import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/screens/assignments/assignments_list_screen.dart';
import 'package:kazin_guide_app/screens/dashboard/home_dashboard_screen.dart';
import 'package:kazin_guide_app/screens/notifications/notifications_screen.dart';
import 'package:kazin_guide_app/screens/profile/profile_screen.dart';
import 'package:kazin_guide_app/widgets/live_pulse_button.dart';

class MainNavigationShell extends StatelessWidget {
  MainNavigationShell({super.key});
  final KazinController ctrl = Get.find<KazinController>();

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    AssignmentListScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      body: Obx(
        () => IndexedStack(
          index: ctrl.currentBottomNavIndex.value,
          children: _screens,
        ),
      ),

      // Right Side Floating Live Button
      floatingActionButton: const LivePulseFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Minimalist Clean Bottom Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.8)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: "Home",
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment_rounded,
                  label: "Assignments",
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.notifications_none_rounded,
                  selectedIcon: Icons.notifications_rounded,
                  label: "Alerts",
                  showBadge: true,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool showBadge = false,
  }) {
    return Obx(() {
      final isSelected = ctrl.currentBottomNavIndex.value == index;
      final showRedDot = showBadge && ctrl.hasUnreadAlerts.value;

      return Expanded(
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            if (ctrl.currentBottomNavIndex.value != index) {
              HapticFeedback.lightImpact();
              ctrl.currentBottomNavIndex.value = index;

              // Alerts open hote hi red dot mark read ho jayega
              if (index == 2) {
                ctrl.markAlertsAsRead();
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected
                        ? KazinColors.primaryNavy
                        : KazinColors.textMuted,
                    size: 22,
                  ),
                  if (showRedDot)
                    Positioned(
                      top: -1,
                      right: -3,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: KazinColors.redDanger,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? KazinColors.primaryNavy
                      : KazinColors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
