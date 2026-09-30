import 'package:get/get.dart';

class KazinController extends GetxController {
  final currentBottomNavIndex = 0.obs;
  final isOffline = false.obs;
  final syncStatusText = "Synced successfully".obs;

  // Assignment & Checklist State
  final checklistState = <String, bool>{
    "Itinerary reviewed": true,
    "Reporting location understood": true,
    "Driver contacted": false,
    "Guest / flight details checked": true,
    "Required tickets / vouchers available": true,
  }.obs;

  // Airport Progress Step (0 to 4)
  final airportCurrentStep = 0.obs;
  final airportSteps = [
    "Airport Arrived",
    "Guest Contacted",
    "Guest Met",
    "Guests In Vehicle",
    "Hotel Reached",
  ];

  // Execution Step State
  final currentExecutionStep = 2.obs; // 0: Accepted, 1: Ready, 2: En Route...

  // Expense Form State
  final expenseCategory = "Transport".obs;
  final expenseAmount = "0.00".obs;
  final expenseCurrency = "INR".obs;

  // Cash Reconciliation
  final cashReconcileConfirmed = false.obs;

  // Closure Checklist
  final closureChecks = <String, bool>{
    "Service completed": true,
    "Incidents resolved": true,
    "Expenses submitted": true,
    "Lost & Found checked": true,
    "Guest feedback requested": true,
    "Cash reconciled": true,
  }.obs;

  void toggleChecklistItem(String key) {
    if (checklistState.containsKey(key)) {
      checklistState[key] = !checklistState[key]!;
    }
  }

  void toggleClosureCheck(String key) {
    if (closureChecks.containsKey(key)) {
      closureChecks[key] = !closureChecks[key]!;
    }
  }

  void nextAirportStep() {
    if (airportCurrentStep.value < airportSteps.length - 1) {
      airportCurrentStep.value++;
    }
  }
}
