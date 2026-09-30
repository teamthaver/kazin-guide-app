import 'package:flutter/material.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class DocumentWalletScreen extends StatelessWidget {
  const DocumentWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = [
      {"name": "Flight Ticket", "type": "PDF", "offline": true},
      {"name": "Hotel Voucher", "type": "PDF", "offline": true},
      {"name": "Passenger List", "type": "PDF", "offline": true},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Documents",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.description_outlined,
              color: KazinColors.primaryBlue,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: KazinColors.blueInfoBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 16,
                    color: KazinColors.primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Offline — essential data available",
                    style: TextStyle(
                      fontSize: 13,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: "Search documents",
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KazinColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Flights", "Hotels", "Restaurants", "Passengers"]
                    .map(
                      (cat) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KazinColors.primaryBlue,
                            minimumSize: const Size(90, 38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "3 documents stored locally",
              style: TextStyle(color: KazinColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...docs.map(
              (d) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: KazinColors.redDangerBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: KazinColors.redDanger,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d["name"].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: KazinColors.secondaryTeal,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Available Offline",
                                  style: TextStyle(
                                    color: KazinColors.secondaryTeal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("View"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
