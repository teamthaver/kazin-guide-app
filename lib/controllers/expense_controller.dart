import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ExpenseController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  // Document allowed categories
  final List<String> categories = [
    'Fuel',
    'Parking',
    'Toll',
    'Meals',
    'Tickets',
    'Entrance',
    'Tips',
    'Transport',
    'Other',
  ];

  final selectedCategory = 'Fuel'.obs;
  final selectedCurrency = 'GEL'.obs;
  final amountController = TextEditingController();
  final savedController = TextEditingController();
  final notesController = TextEditingController();

  final receiptFiles = <File>[].obs;
  final isSubmitting = false.obs;

  @override
  void onClose() {
    amountController.dispose();
    savedController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> pickReceipt(ImageSource source) async {
    if (receiptFiles.length >= 5) {
      Get.snackbar(
        "Limit Reached",
        "Maximum 5 receipts allowed per expense entry.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (image != null) {
        receiptFiles.add(File(image.path));
      }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Unable to select receipt photo.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeReceipt(int index) {
    if (index >= 0 && index < receiptFiles.length) {
      receiptFiles.removeAt(index);
    }
  }

  Future<void> submitExpense() async {
    final arrivalCtrl = Get.find<ArrivalController>();
    final activeFile = arrivalCtrl.activeTourFile.value;

    if (activeFile == null) {
      Get.snackbar(
        "Error",
        "No active tour assignment found.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final double? spentAmount = double.tryParse(amountController.text.trim());
    if (spentAmount == null || spentAmount <= 0) {
      Get.snackbar(
        "Invalid Amount",
        "Please enter a valid amount spent.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final double savedAmount =
        double.tryParse(savedController.text.trim()) ?? 0.0;

    isSubmitting.value = true;
    try {
      final response = await _apiService.addExpense(
        arrivalId: activeFile.arrivalId,
        category: selectedCategory.value
            .toLowerCase(), // Document required lowercase
        currency: selectedCurrency.value.toUpperCase(),
        spent: spentAmount,
        saved: savedAmount,
        remarks: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        receiptFiles: receiptFiles.toList(),
      );

      if (response.statusCode == 201 && response.body?['success'] == true) {
        Get.back();
        Get.snackbar(
          "Expense Recorded",
          response.body?['message'] ?? "Expense added successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KazinColors.greenAcceptedBg,
          colorText: KazinColors.greenAcceptedText,
        );
      } else {
        final message =
            response.body?['message'] ?? "Unable to submit expense.";
        Get.snackbar(
          "Submission Failed",
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        "Error",
        "Network connection failed.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
