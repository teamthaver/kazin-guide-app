import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends GetxService with WidgetsBindingObserver {
  final List<Permission> _requiredPermissions = [
    Permission.notification,
    Permission.camera,
    Permission.location,
  ];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAndRequestPermission();
    }
  }

  Future<bool> checkAndRequestPermission() async {
    final List<Permission> missingPermissions = [];

    for (var permission in _requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        missingPermissions.add(permission);
      }
    }

    if (missingPermissions.isNotEmpty) {
      final Map<Permission, PermissionStatus> results =
          await missingPermissions.request();

      final bool hasPermanentDenial = results.values.any(
        (status) => status.isPermanentlyDenied,
      );

      if (hasPermanentDenial) {
        _showManualSettingsButton(
          title: 'Permission Required',
          message: 'Please allow required permissions from app settings to receive alerts and notifications.',
        );
        return false;
      }

      return results.values.every((status) => status.isGranted);
    }

    return true;
  }

  void _showManualSettingsButton({
    required String title,
    required String message,
  }) {
    if (Get.isDialogOpen ?? false) return;

    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: 'Settings',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF0F172A),
      onConfirm: () {
        Get.back();
        openAppSettings();
      },
    );
  }
}