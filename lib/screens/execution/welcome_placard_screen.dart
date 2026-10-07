import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class WelcomePlacardScreen extends StatelessWidget {
  const WelcomePlacardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arrivalCtrl = Get.put(ArrivalController());

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
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                      color: KazinColors.primaryNavy,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                Center(
                  child: Obx(() {
                    final file = arrivalCtrl.activeTourFile.value;

                    final String leadGuest =
                        file?.leadName.toUpperCase() ?? "GUEST GROUP";
                    final String guestsCount =
                        "${file?.numberPersons ?? 1} GUESTS";
                    final String groupCategory =
                        file?.groupType.toUpperCase() ?? "GROUP";
                    final String fileNo = file != null
                        ? "FILE #${file.enquiryNo}"
                        : "KAZIN";

                    final inboundFlight = file?.flights.firstWhereOrNull(
                      (f) => f.flightMode.toLowerCase() == "inbound",
                    );
                    final String arrivalText = inboundFlight != null
                        ? "${inboundFlight.arrivalCity} Arrival (${inboundFlight.airlineName} ${inboundFlight.flightNumber})"
                        : "Airport Arrival";

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fileNo,
                          style: const TextStyle(
                            letterSpacing: 8,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "WELCOME",
                          style: TextStyle(
                            letterSpacing: 8,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: KazinColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            leadGuest,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              letterSpacing: 3,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: KazinColors.primaryNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "$guestsCount • $groupCategory",
                          style: const TextStyle(
                            letterSpacing: 2,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          arrivalText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: KazinColors.textMuted,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Obx(() {
                    final file = arrivalCtrl.activeTourFile.value;
                    final String driverName =
                        file?.driver?.name ?? "Assigned Driver";
                    final String vehicleName =
                        file?.transport?.vehicleName ?? "Vehicle";

                    return Column(
                      children: [
                        const Divider(color: KazinColors.borderSubtle),
                        const SizedBox(height: 8),
                        Text(
                          "Driver: $driverName • $vehicleName",
                          style: const TextStyle(
                            color: KazinColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
