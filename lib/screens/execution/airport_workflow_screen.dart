import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class AirportWorkflowScreen extends StatelessWidget {
  const AirportWorkflowScreen({super.key});

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
              color: KazinColors.lightTeal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "1 / 5",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: KazinColors.secondaryTeal,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "AIRPORT WORKFLOW",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: KazinColors.textMuted,
                      ),
                    ),
                    Text(
                      "Flight AI 101",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KazinColors.blueInfoBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "In progress",
                    style: TextStyle(
                      fontSize: 12,
                      color: KazinColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
                          "ARRIVAL\n10:05 AM",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "TERMINAL\nTerminal 3",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "GUESTS\n4 PAX",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "VEHICLE\nToyota Innova",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "DRIVER\nRajiv Kumar (DL 01 AB 4582)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Arrival progress",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "Complete each step as the service progresses.",
              style: TextStyle(color: KazinColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: KazinColors.borderSubtle),
              ),
              child: Obx(
                () => Column(
                  children: List.generate(ctrl.airportSteps.length, (idx) {
                    final active = ctrl.airportCurrentStep.value == idx;
                    final done = ctrl.airportCurrentStep.value > idx;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            done
                                ? Icons.check_circle
                                : (active
                                      ? Icons.arrow_circle_right
                                      : Icons.radio_button_unchecked),
                            color: done
                                ? KazinColors.greenAcceptedText
                                : (active
                                      ? KazinColors.primaryBlue
                                      : KazinColors.textMuted),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            ctrl.airportSteps[idx],
                            style: TextStyle(
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ctrl.nextAirportStep();
                // Get.to(() => const MapNavigationScreen());
              },
              child: const Text("Confirm Step Completed"),
            ),
          ],
        ),
      ),
    );
  }
}
