import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/screens/dashboard/home_dashboard_screen.dart';
import 'package:kazin_guide_app/screens/assignments/assignments_list_screen.dart';
import 'package:kazin_guide_app/screens/notifications/notifications_screen.dart';
import 'package:kazin_guide_app/screens/profile/profile_screen.dart';
import 'package:kazin_guide_app/widgets/live_pulse_button.dart';

class MainNavigationShell extends StatelessWidget {
  MainNavigationShell({super.key});
  final KazinController ctrl = Get.find<KazinController>();

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    AssignmentsListScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      // Screen stack maintain rahega glitch-free switching ke liye
      body: Obx(
        () => IndexedStack(
          index: ctrl.currentBottomNavIndex.value,
          children: _screens,
        ),
      ),

      // Right Side Floating Live Button
      floatingActionButton: const LivePulseFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Modern Premium Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: KazinColors.borderSubtle, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: KazinColors.primaryNavy.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  }) {
    return Obx(() {
      final isSelected = ctrl.currentBottomNavIndex.value == index;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (ctrl.currentBottomNavIndex.value != index) {
            HapticFeedback.lightImpact();
            ctrl.currentBottomNavIndex.value = index;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? KazinColors.secondaryTeal.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? KazinColors.secondaryTeal
                    : KazinColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? KazinColors.secondaryTeal
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
