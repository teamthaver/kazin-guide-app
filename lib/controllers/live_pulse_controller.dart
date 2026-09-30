import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class LivePulseController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController pulseController;
  late final Animation<double> scaleAnimation;
  late final Animation<double> opacityAnimation;

  @override
  void onInit() {
    super.onInit();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    scaleAnimation = Tween<double>(begin: 1.0, end: 1.7).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeOutCubic),
    );

    opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void onClose() {
    pulseController.dispose();
    super.onClose();
  }
}