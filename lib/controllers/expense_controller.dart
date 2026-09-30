import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  final selectedCategory = "Transport".obs;
  final categories = ["Transport", "Meal", "Toll/Parking", "Emergency"];

  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final receiptAttached = false.obs;

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
