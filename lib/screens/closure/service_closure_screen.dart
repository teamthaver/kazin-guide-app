import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'guest_feedback_qr_screen.dart';

class ServiceClosureScreen extends StatelessWidget {
  const ServiceClosureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<KazinController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "KZ10231",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Complete Assignment",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              "Review the final service requirements before closing.",
              style: TextStyle(color: KazinColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => Column(
                    children: ctrl.closureChecks.entries
                        .map(
                          (entry) => CheckboxListTile(
                            title: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            value: entry.value,
                            onChanged: (v) =>
                                ctrl.toggleClosureCheck(entry.key),
                            activeColor: KazinColors.secondaryTeal,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Guide remarks",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add optional remarks",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KazinColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.to(() => const GuestFeedbackQrScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: KazinColors.secondaryTeal,
              ),
              child: const Text("Close Assignment"),
            ),
          ],
        ),
      ),
    );
  }
}
