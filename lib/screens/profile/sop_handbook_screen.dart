import 'package:flutter/material.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class SopHandbookScreen extends StatelessWidget {
  const SopHandbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      "Service Standards",
      "Reporting Time",
      "Grooming",
      "Greeting Guests",
      "Itinerary Changes",
      "Guest Confidentiality",
      "Cash Handling",
      "Supplier Interaction",
      "Social Media / Photo Policy",
      "Escalation Procedures",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "SOP / Guide Handbook",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search handbook",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KazinColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KazinColors.lightTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: KazinColors.secondaryTeal),
                  SizedBox(width: 10),
                  Text(
                    "Handbook available offline",
                    style: TextStyle(
                      color: KazinColors.secondaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Handbook topics",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "10 topics",
                  style: TextStyle(color: KazinColors.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...topics.map(
              (t) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    t,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: KazinColors.textMuted,
                  ),
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
