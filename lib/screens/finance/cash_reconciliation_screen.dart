import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/screens/closure/service_closure_screen.dart';

class CashReconciliationScreen extends StatelessWidget {
  const CashReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final confirmed = false.obs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Cash Reconciliation",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Cash Received",
                          style: TextStyle(
                            fontSize: 14,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                        Text(
                          "₹10,000",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Approved Expenses",
                          style: TextStyle(
                            fontSize: 14,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                        Text(
                          "₹6,750",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KazinColors.greenAcceptedBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Remaining Balance",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: KazinColors.greenAcceptedText,
                            ),
                          ),
                          Text(
                            "₹3,250",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: KazinColors.greenAcceptedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Cash returned / held",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "₹ ",
                hintText: "Enter amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KazinColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "I confirm this balance is accurate.",
                  style: TextStyle(fontSize: 13),
                ),
                value: confirmed.value,
                onChanged: (v) => confirmed.value = v!,
                activeColor: KazinColors.secondaryTeal,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.to(() => const ServiceClosureScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: KazinColors.secondaryTeal,
              ),
              child: const Text("Confirm Cash Balance"),
            ),
          ],
        ),
      ),
    );
  }
}
