import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/arrival_controller.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/profile_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<KazinController>(KazinController(), permanent: true);
    Get.put<ArrivalController>(ArrivalController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
}
