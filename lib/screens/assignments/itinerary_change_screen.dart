import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ItineraryChangeScreen extends StatelessWidget {
  const ItineraryChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: KazinColors.amberWarningBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  size: 14,
                  color: KazinColors.amberWarningText,
                ),
                SizedBox(width: 4),
                Text(
                  "High priority",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: KazinColors.amberWarningText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "FILE KZ10231",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: KazinColors.amberWarningText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Assignment Updated",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              "A change requires your acknowledgement before continuing.",
              style: TextStyle(color: KazinColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time_filled, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          "Pickup Time",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: KazinColors.blueInfoBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text(
                            "10:00 AM",
                            style: TextStyle(
                              fontSize: 18,
                              color: KazinColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: KazinColors.primaryNavy,
                          ),
                          Text(
                            "11:30 AM",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: KazinColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "CHANGED BY",
                          style: TextStyle(
                            fontSize: 12,
                            color: KazinColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Kazin Operations",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "CHANGED AT",
                          style: TextStyle(
                            fontSize: 12,
                            color: KazinColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "09:42 AM",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: KazinColors.secondaryTeal,
              ),
              child: const Text("Acknowledge Change"),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("View full assignment"),
            ),
          ],
        ),
      ),
    );
  }
}
