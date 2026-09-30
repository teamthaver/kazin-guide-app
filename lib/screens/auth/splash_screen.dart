import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/kazin_logo.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KazinColors.cardWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const KazinLogo(height: 52),
            const SizedBox(height: 16),
            const Text(
              "Field Operations",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1.2,
                color: KazinColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: KazinColors.secondaryTeal,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
