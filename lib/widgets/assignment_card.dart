import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'status_chip.dart';

class AssignmentCard extends StatelessWidget {
  final String fileId;
  final String guestName;
  final int paxCount;
  final String serviceType;
  final String time;
  final String pickupLocation;
  final String destinationLocation;
  final KazinStatus status;
  final String buttonText;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.fileId,
    required this.guestName,
    required this.paxCount,
    required this.serviceType,
    required this.time,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    this.buttonText = "View Assignment",
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fileId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: KazinColors.textSecondary,
                  ),
                ),
                StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              guestName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 16, color: KazinColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  "$paxCount PAX  •  $serviceType",
                  style: const TextStyle(
                    fontSize: 13,
                    color: KazinColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: KazinColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: KazinColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.route_outlined, size: 16, color: KazinColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "$pickupLocation → $destinationLocation",
                    style: const TextStyle(
                      fontSize: 13,
                      color: KazinColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}