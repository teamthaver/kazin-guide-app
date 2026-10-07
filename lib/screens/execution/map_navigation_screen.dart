import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MapNavigationScreen extends StatelessWidget {
  const MapNavigationScreen({super.key});

  Future<void> _launchMaps(String query) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}",
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final arrivalCtrl = Get.put(ArrivalController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Navigation",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        final file = arrivalCtrl.activeTourFile.value;

        // Pickup point from inbound flight or fallback to Tbilisi Airport
        final inboundFlight = file?.flights.firstWhereOrNull(
          (f) => f.flightMode.toLowerCase() == "inbound",
        );
        final String pickupLocation =
            inboundFlight != null && inboundFlight.arrivalCity.isNotEmpty
            ? "Tbilisi International Airport (${inboundFlight.arrivalCity})"
            : "Tbilisi International Airport (TBS)";

        // Destination from booked hotel or itinerary
        final String destinationName = file?.hotel?.hotelName.isNotEmpty == true
            ? file!.hotel!.hotelName
            : "Hotel Royal Tulip";
        final String destinationAddress = file?.hotel != null
            ? "${file!.hotel!.address}, ${file.hotel!.city}".trim()
            : "10 Leuvile Embankment, Tbilisi, Georgia";

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Navigation",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                file != null
                    ? "Plan route for File #${file.enquiryNo} (${file.leadName})"
                    : "Plan your route between pickup and destination.",
                style: const TextStyle(color: KazinColors.textSecondary),
              ),
              const SizedBox(height: 20),
              // Map Preview Box
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KazinColors.borderSubtle),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(200, 100),
                      painter: _SimpleRoutePainter(),
                    ),
                    Positioned(
                      top: 40,
                      left: 60,
                      child: CircleAvatar(
                        backgroundColor: KazinColors.secondaryTeal.withValues(
                          alpha: 0.2,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: KazinColors.secondaryTeal,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 60,
                      child: CircleAvatar(
                        backgroundColor: KazinColors.primaryBlue.withValues(
                          alpha: 0.2,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: KazinColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.radio_button_checked,
                            color: KazinColors.secondaryTeal,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "PICKUP",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: KazinColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  pickupLocation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: KazinColors.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "DESTINATION",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: KazinColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  destinationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (destinationAddress.isNotEmpty)
                                  Text(
                                    destinationAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: KazinColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _launchMaps(pickupLocation),
                icon: const Icon(Icons.navigation_outlined),
                label: const Text("Navigate to Pickup"),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () =>
                    _launchMaps("$destinationName, $destinationAddress"),
                icon: const Icon(Icons.navigation_outlined),
                label: const Text("Navigate to Destination"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Opens your preferred maps app.",
                  style: TextStyle(color: KazinColors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SimpleRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KazinColors.secondaryTeal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      const Offset(30, 20),
      Offset(size.width - 30, size.height - 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
