import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazin_guide_app/controllers/expense_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ExpenseSubmissionScreen extends StatelessWidget {
  const ExpenseSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        top: false,
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

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Amount Spent",
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
                            hintText: "0.00",
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Currency",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: KazinColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: KazinColors.borderSubtle),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Obx(
                            () => DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: ctrl.selectedCurrency.value,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: "GEL",
                                    child: Text("GEL (₾)"),
                                  ),
                                  DropdownMenuItem(
                                    value: "USD",
                                    child: Text("USD (\$)"),
                                  ),
                                  DropdownMenuItem(
                                    value: "INR",
                                    child: Text("INR (₹)"),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    ctrl.selectedCurrency.value = val;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Receipts Section (Up to 5 receipts with preview)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Receipt Proofs",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: KazinColors.textPrimary,
                    ),
                  ),
                  Obx(
                    () => Text(
                      "${ctrl.receiptFiles.length} / 5 Attached",
                      style: const TextStyle(
                        fontSize: 12,
                        color: KazinColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Obx(() {
                        if (ctrl.receiptFiles.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: ctrl.receiptFiles.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      ctrl.receiptFiles[idx],
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => ctrl.removeReceipt(idx),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }),
                      Obx(
                        () => ctrl.receiptFiles.isNotEmpty
                            ? const SizedBox(height: 12)
                            : const SizedBox.shrink(),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showImageSourceSheet(context, ctrl),
                        icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                        label: const Text(
                          "Attach Receipt (Max 5)",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: KazinColors.primaryNavy,
                          minimumSize: const Size.fromHeight(46),
                          side: const BorderSide(
                            color: KazinColors.borderSubtle,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                "Remarks",
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
                  hintText: "Add remarks or reference (optional)",
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

              Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isSubmitting.value
                      ? null
                      : ctrl.submitExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KazinColors.secondaryTeal,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: ctrl.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Submit Expense",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, ExpenseController ctrl) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: KazinColors.borderSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: KazinColors.primaryNavy,
                  ),
                  title: const Text(
                    "Take Photo with Camera",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    ctrl.pickReceipt(ImageSource.camera);
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: KazinColors.primaryNavy,
                  ),
                  title: const Text(
                    "Select from Gallery",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    ctrl.pickReceipt(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
