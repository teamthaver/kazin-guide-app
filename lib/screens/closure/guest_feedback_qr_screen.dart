import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GuestFeedbackQrScreen extends StatelessWidget {
  const GuestFeedbackQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Guest Feedback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text("Ask the guest to scan this QR code.", style: TextStyle(color: KazinColors.textSecondary)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KazinColors.borderSubtle),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: 'https://kazin.travel/feedback/KZ10231',
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 12),
                  const Text("KZ10231 FEEDBACK", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("Guest does not need to install the app.", style: TextStyle(color: KazinColors.textMuted, fontSize: 13)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text("Share Feedback Link"),
              style: ElevatedButton.styleFrom(backgroundColor: KazinColors.secondaryTeal),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.copy),
              label: const Text("Copy Link"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}