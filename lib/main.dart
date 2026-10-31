import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/fcm_service.dart';
import 'package:kazin_guide_app/core/services/network_sync_service.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("📡 [FCM Background]: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Storage & Firebase Init
  await GetStorage.init();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 2. Base Services Injection
  Get.put(NetworkSyncService(), permanent: true);
  Get.put(ApiService(), permanent: true);
  Get.put(FcmService(), permanent: true);

  // 3. Auth Init (Session Check)
  await Get.putAsync<AuthService>(() => AuthService().init(), permanent: true);

  // 4. Controller Init
  Get.put<KazinController>(KazinController(), permanent: true);

  // 5. Asynchronous Permissions & Token Save (Non-blocking: splash screen freeze nahi hogi)
  FirebaseMessaging.instance
      .requestPermission(alert: true, badge: true, sound: true)
      .then((settings) {
    log("🔔 [FCM Permission Status]: ${settings.authorizationStatus}");
  });

  FirebaseMessaging.instance.getToken().then((token) {
    if (token != null) {
      log("🔑 [FCM Token Saved Locally]: $token");
      GetStorage().write('fcm_token', token);
      // NOTE: Backend sync startup par call nahi karna hai, login ke baad hoga.
    }
  }).catchError((err) {
    log("⚠️ [FCM Token Fetch Error]: $err");
  });

  runApp(const KazinGuideApp());
}

class KazinGuideApp extends StatelessWidget {
  const KazinGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kazin Guide',
      debugShowCheckedModeBanner: false,
      theme: KazinTheme.lightTheme,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 280),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}