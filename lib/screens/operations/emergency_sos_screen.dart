import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class EmergencySosScreen extends StatelessWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KazinColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Emergency Assistance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: KazinColors.redDangerBg,
              child: Icon(
                Icons.warning_amber_rounded,
                size: 40,
                color: KazinColors.redDanger,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Choose the right contact",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              "Calls may share your current assignment details with Kazin Response Control.",
              textAlign: TextAlign.center,
              style: TextStyle(color: KazinColors.textSecondary),
            ),
            const SizedBox(height: 32),
            _buildEmergencyActionCard(
              title: "Call Kazin Emergency Contact",
              subtitle: "Primary emergency dispatch",
              icon: Icons.call,
              bgColor: KazinColors.redDanger,
            ),
            const SizedBox(height: 14),
            _buildEmergencyActionCard(
              title: "Call Destination Contact",
              subtitle: "On-file local operational team",
              icon: Icons.business,
              bgColor: Colors.orange.shade800,
            ),
            const SizedBox(height: 14),
            _buildEmergencyActionCard(
              title: "Local Emergency",
              subtitle: "Police, Ambulance & Medical (112)",
              icon: Icons.local_hospital,
              bgColor: Colors.white,
              textColor: KazinColors.primaryNavy,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEmergencyActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    Color textColor = Colors.white,
    bool isOutlined = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isOutlined
            ? Border.all(color: KazinColors.borderSubtle, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isOutlined
                ? KazinColors.scaffoldBg
                : Colors.white24,
            child: Icon(
              icon,
              color: isOutlined ? KazinColors.primaryNavy : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.8),
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
