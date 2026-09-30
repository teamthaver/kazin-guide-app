import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/controllers/expense_controller.dart';
import 'cash_reconciliation_screen.dart';

class ExpenseSubmissionScreen extends StatelessWidget {
  const ExpenseSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller inject kiya taaki state properly lay out ho
    final ctrl = Get.put(ExpenseController());

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KazinColors.primaryNavy),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Add Expense",
          style: TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Category",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: KazinColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: KazinColors.borderSubtle),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ctrl.selectedCategory.value,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: KazinColors.textSecondary,
                      ),
                      items: ctrl.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) ctrl.selectedCategory.value = val;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                "Amount",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: KazinColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl.amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Text(
                      "₹",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: KazinColors.textPrimary,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 0,
                  ),
                  hintText: "0.00",
                  hintStyle: const TextStyle(color: KazinColors.textMuted),
                  suffixIcon: const Icon(
                    Icons.calculate_outlined,
                    color: KazinColors.textSecondary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: KazinColors.borderSubtle,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: KazinColors.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Fixed Layout: Receipt Card with proper flex bounds
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: KazinColors.scaffoldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: KazinColors.borderSubtle),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: KazinColors.textMuted,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Receipt",
                              style: TextStyle(
                                color: KazinColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Expanded se wrap kiya taaki button layout crash na ho
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ctrl.receiptAttached.value = true;
                          },
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text(
                            "Add Receipt",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: KazinColors.primaryNavy,
                            side: const BorderSide(
                              color: KazinColors.borderSubtle,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                "Notes",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: KazinColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl.notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Add notes (optional)",
                  hintStyle: const TextStyle(color: KazinColors.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: KazinColors.borderSubtle,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: KazinColors.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () => Get.to(() => const CashReconciliationScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.secondaryTeal,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Submit Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
