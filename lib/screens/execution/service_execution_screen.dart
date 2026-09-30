import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'airport_workflow_screen.dart';

class ServiceExecutionScreen extends StatelessWidget {
  const ServiceExecutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {"title": "Assignment Accepted", "time": "09:18 AM", "done": true},
      {"title": "Ready", "time": "09:42 AM", "done": true},
      {"title": "En Route", "time": "10:02 AM", "active": true},
      {"title": "Arrived at Pickup", "time": "", "done": false},
      {"title": "Guests Met", "time": "", "done": false},
      {"title": "Service Started", "time": "", "done": false},
      {"title": "Service Completed", "time": "", "done": false},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Airport Arrival",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: KazinColors.blueInfoBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "EN ROUTE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: KazinColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ASSIGNMENT #KZ10231",
              style: TextStyle(
                fontSize: 12,
                color: KazinColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Service Execution",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            ...List.generate(steps.length, (index) {
              final s = steps[index];
              final isDone = s["done"] == true;
              final isActive = s["active"] == true;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle
                            : (isActive
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked),
                        color: isDone
                            ? KazinColors.greenAcceptedText
                            : (isActive
                                  ? KazinColors.primaryBlue
                                  : KazinColors.textMuted),
                        size: 20,
                      ),
                      if (index != steps.length - 1)
                        Container(
                          width: 2,
                          height: 36,
                          color: KazinColors.borderSubtle,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s["title"].toString(),
                        style: TextStyle(
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isActive
                              ? KazinColors.primaryBlue
                              : KazinColors.textPrimary,
                        ),
                      ),
                      if (s["time"].toString().isNotEmpty)
                        Text(
                          s["time"].toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: KazinColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KazinColors.blueInfoBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CURRENT STATUS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: KazinColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "En Route",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Your status has been recorded.",
                    style: TextStyle(
                      color: KazinColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () =>
                        Get.to(() => const AirportWorkflowScreen()),
                    child: const Text("Update Status"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KazinColors.borderSubtle),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: KazinColors.primaryBlue,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "My Current Location → Delhi Airport T3",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Saved locally — waiting to sync",
                style: TextStyle(color: KazinColors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
