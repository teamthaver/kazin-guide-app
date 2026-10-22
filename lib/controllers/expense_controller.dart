import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/db_service.dart';
import 'package:kazin_guide_app/core/services/network_sync_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class ExpenseController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final DbService _dbService = DbService.instance;
  final ImagePicker _picker = ImagePicker();

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

  void clearForm() {
    amountController.clear();
    savedController.clear();
    notesController.clear();
    receiptFiles.clear();
    selectedCategory.value = categories.first;
    selectedCurrency.value = 'GEL';
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
    final categoryLower = selectedCategory.value.toLowerCase();
    final currencyUpper = selectedCurrency.value.toUpperCase();
    final remarksText = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();

    isSubmitting.value = true;

    final bool isOnline = Get.isRegistered<NetworkSyncService>()
        ? Get.find<NetworkSyncService>().isOnline.value
        : true;

    try {
      if (isOnline) {
        final response = await _apiService.addExpense(
          arrivalId: activeFile.arrivalId,
          category: categoryLower,
          currency: currencyUpper,
          spent: spentAmount,
          saved: savedAmount,
          remarks: remarksText,
          receiptFiles: receiptFiles.toList(),
        );

        // 200 ya 201 dono success mane jayenge
        if (response.isOk && response.body?['success'] == true) {
          clearForm();
          Get.back();
          Get.snackbar(
            "Expense Recorded",
            response.body?['message'] ?? "Expense added successfully.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KazinColors.greenAcceptedBg,
            colorText: KazinColors.greenAcceptedText,
          );
          return;
        }
      }

      // Offline ya server failure fallback
      await _queueExpenseOffline(
        activeFile.arrivalId,
        categoryLower,
        currencyUpper,
        spentAmount,
        savedAmount,
        remarksText,
      );
    } catch (_) {
      await _queueExpenseOffline(
        activeFile.arrivalId,
        categoryLower,
        currencyUpper,
        spentAmount,
        savedAmount,
        remarksText,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _queueExpenseOffline(
    int arrivalId,
    String category,
    String currency,
    double spent,
    double saved,
    String? remarks,
  ) async {
    await _dbService.queueOfflineAction(
      actionType: 'add_expense',
      payload: {
        'arrival_id': arrivalId,
        'category': category,
        'currency': currency,
        'spent': spent,
        'saved': saved,
        'remarks': remarks,
      },
      imagePaths: receiptFiles.map((f) => f.path).toList(),
    );

    clearForm();
    Get.back();
    Get.snackbar(
      "Saved Offline",
      "Expense recorded locally. Will sync when back online.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      icon: const Icon(Icons.cloud_off_rounded, color: Colors.white),
    );
  }
}
