import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class DeclineAssignmentScreen extends StatelessWidget {
  const DeclineAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedReason = "Unavailable".obs;
    final reasons = ["Unavailable", "Schedule Conflict", "Location Issue", "Other"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Why are you declining?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text("Select a reason so Operations can reassign quickly.", style: TextStyle(color: KazinColors.textSecondary)),
            const SizedBox(height: 24),
            ...reasons.map((r) => Obx(() => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: KazinColors.borderSubtle),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: RadioListTile<String>(
                title: Text(r, style: const TextStyle(fontWeight: FontWeight.w600)),
                value: r,
                groupValue: selectedReason.value,
                onChanged: (val) => selectedReason.value = val!,
                activeColor: KazinColors.primaryNavy,
              ),
            ))),
            const SizedBox(height: 12),
            const Text("Notes", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add context (optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: KazinColors.borderSubtle)),
              ),
            ),
            const SizedBox(height: 8),
            const Text("Reason is required", style: TextStyle(color: KazinColors.redDanger, fontSize: 12)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(backgroundColor: KazinColors.redDanger),
              child: const Text("Confirm Decline"),
            ),
          ],
        ),
      ),
    );
  }
}