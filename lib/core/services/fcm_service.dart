import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';

class FcmService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _defaultChannel =
      const AndroidNotificationChannel(
        'kazin_guide_default_channel',
        'Kazin Guide Alerts',
        description: 'Notifications for new tour file assignments and alerts.',
        importance: Importance.max,
        playSound: true,
      );

  @override
  void onInit() {
    super.onInit();
    _initLocalNotifications();
    _listenForegroundMessages();
    _handleKilledStateMessage();
    _checkAndAutoSubscribe();

    // Token refresh listener: Agar device token change ho toh backend par auto update ho
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      log("🔄 [FCM]: Token refresh hua: $newToken");
      GetStorage().write('fcm_token', newToken);
      syncTokenWithBackend(newToken);
    });
  }

  // Backend par token send karne ka function
  Future<void> syncTokenWithBackend([String? token]) async {
    try {
      final fcmToken = token ?? GetStorage().read<String>('fcm_token');
      final authService = Get.isRegistered<AuthService>()
          ? Get.find<AuthService>()
          : null;

      // Agar guide logged in nahi hai ya token nahi hai toh return ho jao
      if (fcmToken == null ||
          fcmToken.isEmpty ||
          authService == null ||
          !authService.isLoggedIn.value) {
        log(
          "⚠️ [FCM]: Guide logged in nahi hai ya token missing hai, sync skip kiya.",
        );
        return;
      }

      if (Get.isRegistered<ApiService>()) {
        final response = await Get.find<ApiService>().saveFcmToken(fcmToken);
        if (response.isOk && response.body?['success'] == true) {
          log("✅ [FCM]: Backend par token successfully save ho gaya.");
        } else {
          log(
            "❌ [FCM]: Backend save token fail: ${response.statusCode} - ${response.body}",
          );
        }
      }
    } catch (e) {
      log("❌ [FCM]: Error syncing token to backend: $e");
    }
  }

  void _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _navigateToAlertsScreen();
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);

    log("🚀 [FCM]: Default Local Notification Channel Registered.");
  }

  void _listenForegroundMessages() {
    // 1. App Active / Foreground State Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("📱 [FCM Foreground]: ${message.notification?.title}");

      // UI state reactive update
      if (Get.isRegistered<KazinController>()) {
        Get.find<KazinController>().hasUnreadAlerts.value = true;
      }
      if (Get.isRegistered<AssignmentsController>()) {
        Get.find<AssignmentsController>().fetchAlertsData();
      }

      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        await _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _defaultChannel.id,
              _defaultChannel.name,
              channelDescription: _defaultChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
        );
      }
    });

    // 2. App in Background State (Notification tap listener)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🎯 [FCM Background Tap]: ${message.notification?.title}");
      _navigateToAlertsScreen();
    });
  }

  // 3. App in Terminated / Killed State (Notification tap on closed app)
  void _handleKilledStateMessage() async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      log("🔥 [FCM Killed State Tap]: ${initialMessage.notification?.title}");
      Future.delayed(const Duration(milliseconds: 600), () {
        _navigateToAlertsScreen();
      });
    }
  }

  void _navigateToAlertsScreen() {
    if (Get.isRegistered<KazinController>()) {
      final ctrl = Get.find<KazinController>();
      ctrl.currentBottomNavIndex.value = 2; // Switch to Alerts Tab
      ctrl.markAlertsAsRead();
    }
    if (Get.isRegistered<AssignmentsController>()) {
      Get.find<AssignmentsController>().fetchAlertsData();
    }
  }

  // Guide-specific Topic Subscription: "guide_$guideId"
  Future<void> subscribeToGuideTopic(int guideId) async {
    if (guideId <= 0) return;
    try {
      final String topicName = "guide_$guideId";
      await FirebaseMessaging.instance.subscribeToTopic(topicName);
      log("📢 [FCM]: Subscribed to topic: $topicName");
    } catch (e) {
      log("❌ [FCM]: Failed to subscribe to topic: $e");
    }
  }

  Future<void> unsubscribeFromGuideTopic(int guideId) async {
    if (guideId <= 0) return;
    try {
      final String topicName = "guide_$guideId";
      await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
      log("🛑 [FCM]: Unsubscribed from topic: $topicName");
    } catch (e) {
      log("❌ [FCM]: Failed to unsubscribe from topic: $e");
    }
  }

  void _checkAndAutoSubscribe() {
    if (Get.isRegistered<AuthService>()) {
      final int guideId = Get.find<AuthService>().guideId;
      if (guideId > 0) {
        subscribeToGuideTopic(guideId);
      }
    }
  }
}
