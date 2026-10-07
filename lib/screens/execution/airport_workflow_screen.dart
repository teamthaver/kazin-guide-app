import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AirportWorkflowScreen extends StatelessWidget {
  const AirportWorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<KazinController>();
    final arrivalCtrl = Get.put(ArrivalController());

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: KazinColors.lightTeal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "${ctrl.airportCurrentStep.value + 1} / ${ctrl.airportSteps.length}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: KazinColors.secondaryTeal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final file = arrivalCtrl.activeTourFile.value;

        // Inbound flight retrieval
        final inboundFlight = file?.flights.firstWhereOrNull(
          (f) => f.flightMode.toLowerCase() == "inbound",
        );

        final String flightTitle = inboundFlight != null
            ? "Flight ${inboundFlight.airlineName} ${inboundFlight.flightNumber}"
            : "Arrival Flight";
        final String arrivalTime =
            inboundFlight != null && inboundFlight.departureTime.isNotEmpty
            ? inboundFlight.departureTime
            : "14:10";
        final String arrivalAirport =
            inboundFlight != null && inboundFlight.departureAirport.isNotEmpty
            ? inboundFlight.departureAirport.split('-')[0]
            : "TBS";
        final String paxText = "${file?.numberPersons ?? 3} PAX";
        final String vehicleText = file?.transport?.vehicleName ?? "Sedan";
        final String driverText = file?.driver != null
            ? "${file!.driver!.name} (${file.driver!.phone})"
            : "Assigned Driver";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AIRPORT WORKFLOW",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: KazinColors.textMuted,
                        ),
                      ),
                      Text(
                        flightTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: KazinColors.primaryNavy,
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
                    child: Text(
                      file?.status.toUpperCase() ?? "IN PROGRESS",
                      style: const TextStyle(
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
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "ARRIVAL TIME",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: KazinColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                arrivalTime,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "AIRPORT",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: KazinColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                arrivalAirport,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "GUESTS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: KazinColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                paxText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "VEHICLE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: KazinColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicleText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "DRIVER",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: KazinColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  driverText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (file?.driver != null &&
                              file!.driver!.phone.isNotEmpty)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const CircleAvatar(
                                radius: 15,
                                backgroundColor: KazinColors.greenAcceptedBg,
                                child: Icon(
                                  Icons.call,
                                  size: 15,
                                  color: KazinColors.greenAcceptedText,
                                ),
                              ),
                              onPressed: () {
                                final phone = file.driver!.phone.replaceAll(
                                  RegExp(r'[^0-9+]'),
                                  '',
                                );
                                launchUrl(Uri.parse('tel:$phone'));
                              },
                            ),
                        ],
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
                style: TextStyle(
                  color: KazinColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KazinColors.borderSubtle),
                ),
                child: Column(
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
                          Expanded(
                            child: Text(
                              ctrl.airportSteps[idx],
                              style: TextStyle(
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                                color: done
                                    ? KazinColors.textSecondary
                                    : KazinColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  if (ctrl.airportCurrentStep.value <
                      ctrl.airportSteps.length - 1) {
                    ctrl.nextAirportStep();
                  } else {
                    Get.toNamed(Routes.MAP_NAVIGATION);
                  }
                },
                child: Text(
                  ctrl.airportCurrentStep.value < ctrl.airportSteps.length - 1
                      ? "Confirm Step Completed"
                      : "Proceed to GPS Navigation",
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
