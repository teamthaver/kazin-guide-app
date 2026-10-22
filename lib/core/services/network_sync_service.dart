import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/db_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class NetworkSyncService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final DbService _dbService = DbService.instance;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  final isOnline = true.obs;
  final isSyncing = false.obs;
  bool _isFirstCheck = true;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  void _initConnectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final bool hasNet = results.any((r) => r != ConnectivityResult.none);

      if (_isFirstCheck) {
        _isFirstCheck = false;
        isOnline.value = hasNet;
        return;
      }

      if (isOnline.value && !hasNet) {
        isOnline.value = false;
        _showOfflineSnackbar();
      } else if (!isOnline.value && hasNet) {
        isOnline.value = true;
        _showOnlineSnackbar();
        syncPendingData();
      }
    });
  }

  void _showOfflineSnackbar() {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      titleText: const Text(
        "No Internet Connection",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      messageText: const Text(
        "You are offline. Changes will be saved locally and synced automatically.",
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 22),
      backgroundColor: const Color(0xFF1E293B),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  void _showOnlineSnackbar() {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      titleText: const Text(
        "Back Online",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      messageText: const Text(
        "Connection restored. Syncing offline activities with server...",
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      icon: const Icon(Icons.wifi_rounded, color: Colors.tealAccent, size: 22),
      backgroundColor: KazinColors.primaryNavy,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> syncPendingData() async {
    if (isSyncing.value || !isOnline.value) return;
    isSyncing.value = true;

    try {
      final pendingActions = await _dbService.getPendingSyncActions();
      if (pendingActions.isEmpty) return;

      log(
        '🔄 [SYNC ENGINE] Found ${pendingActions.length} pending actions to sync.',
      );
      final apiService = Get.find<ApiService>();

      for (var action in pendingActions) {
        final int actionId = action['id'] as int;
        final String actionType = action['action_type'] as String;
        final Map<String, dynamic> payload = jsonDecode(
          action['payload'] as String,
        );
        final List<dynamic> imagePathsDynamic = jsonDecode(
          action['image_paths'] as String? ?? '[]',
        );
        final List<File> files = imagePathsDynamic
            .map((p) => File(p.toString()))
            .where((f) => f.existsSync())
            .toList();

        bool success = false;

        switch (actionType) {
          case 'mark_completed':
            final res = await apiService.markCompleted(
              itineraryId: payload['itinerary_id'],
              arrivalId: payload['arrival_id'],
              currentTime: payload['current_time'],
              delayReason: payload['delay_reason'],
              imageFile: files.isNotEmpty ? files.first : null,
            );
            success = res.statusCode == 200 && res.body?['success'] == true;
            break;

          case 'add_expense':
            final res = await apiService.addExpense(
              arrivalId: payload['arrival_id'],
              category: payload['category'],
              currency: payload['currency'],
              spent: (payload['spent'] as num).toDouble(),
              saved: (payload['saved'] as num).toDouble(),
              remarks: payload['remarks'],
              receiptFiles: files,
            );
            // res.isOk lagayein (200 ya 201 dono accept honge)
            success = res.isOk && res.body?['success'] == true;
            break;

          case 'report_issue':
            final res = await apiService.reportIssue(
              arrivalId: payload['arrival_id'],
              category: payload['category'],
              incidentDate: payload['incident_date'],
              incidentTime: payload['incident_time'],
              issue: payload['issue'],
              location: payload['location'],
              remark: payload['remark'],
              imageFiles: files,
            );
            // res.isOk lagayein (200 ya 201 dono accept honge)
            success = res.isOk && res.body?['success'] == true;
            break;
        }

        if (success) {
          await _dbService.removeQueueAction(actionId);
          log('✅ [SYNC SUCCESS] Action #$actionId ($actionType) synced.');
        } else {
          log('⚠️ [SYNC RETRY LATER] Action #$actionId failed or needs retry.');
        }
      }

      if (Get.isRegistered<ArrivalController>()) {
        Get.find<ArrivalController>().loadArrivalData();
      }
    } catch (e) {
      log('❌ [SYNC ERROR] $e');
    } finally {
      isSyncing.value = false;
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
