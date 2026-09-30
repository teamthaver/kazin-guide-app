import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class WelcomePlacardScreen extends StatelessWidget {
  const WelcomePlacardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm off-white
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 28, color: KazinColors.primaryNavy),
                    onPressed: () => Get.back(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "KAZIN",
                        style: TextStyle(
                          letterSpacing: 10,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 36),
                      Text(
                        "WELCOME",
                        style: TextStyle(
                          letterSpacing: 8,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                      SizedBox(height: 28),
                      Text(
                        "SMITH FAMILY",
                        style: TextStyle(
                          letterSpacing: 4,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "4 GUESTS",
                        style: TextStyle(
                          letterSpacing: 3,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Airport Arrival",
                        style: TextStyle(fontSize: 16, color: KazinColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    children: const [
                      Divider(color: KazinColors.borderSubtle),
                      SizedBox(height: 8),
                      Text(
                        "Your guide: Arjun Mehta",
                        style: TextStyle(color: KazinColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}