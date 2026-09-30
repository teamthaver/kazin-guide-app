import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class MapNavigationScreen extends StatelessWidget {
  const MapNavigationScreen({super.key});

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
        title: const Text(
          "Navigation",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Navigation",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              "Plan your route between pickup and destination.",
              style: TextStyle(color: KazinColors.textSecondary),
            ),
            const SizedBox(height: 20),
            // Mock Map Preview Box
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
                  children: const [
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          color: KazinColors.secondaryTeal,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PICKUP",
                              style: TextStyle(
                                fontSize: 11,
                                color: KazinColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Current location",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 20),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: KazinColors.primaryBlue),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DESTINATION",
                              style: TextStyle(
                                fontSize: 11,
                                color: KazinColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Delhi Airport T3",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.navigation_outlined),
              label: const Text("Navigate to Pickup"),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {},
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
      ),
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
