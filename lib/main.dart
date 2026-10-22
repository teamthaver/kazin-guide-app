import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/core/services/api_service.dart';
import 'package:kazin_guide_app/core/services/auth_service.dart';
import 'package:kazin_guide_app/core/services/network_sync_service.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(NetworkSyncService(), permanent: true);
  Get.put(ApiService(), permanent: true);
  await Get.putAsync<AuthService>(() => AuthService().init());
  Get.put<KazinController>(KazinController(), permanent: true);
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
