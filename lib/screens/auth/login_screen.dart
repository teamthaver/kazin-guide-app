import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/auth_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/widgets/kazin_logo.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KazinColors.cardWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KazinLogo(height: 38),
              const SizedBox(height: 36),
              const Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: KazinColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to manage your assignments",
                style: TextStyle(
                  color: KazinColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // Mobile Input
              const Text(
                "Mobile number",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: KazinColors.borderSubtle),
                    borderRadius: BorderRadius.circular(12),
                    color: controller.isOtpSent.value
                        ? KazinColors.scaffoldBg
                        : Colors.white,
                  ),
                  child: TextField(
                    controller: controller.phoneController,
                    enabled:
                        !controller.isOtpSent.value, // Lock input once verified
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Enter contact number",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input
              const Text(
                "Password",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: KazinColors.borderSubtle),
                    borderRadius: BorderRadius.circular(12),
                    color: controller.isOtpSent.value
                        ? KazinColors.scaffoldBg
                        : Colors.white,
                  ),
                  child: TextField(
                    controller: controller.passwordController,
                    enabled: !controller
                        .isOtpSent
                        .value, // Lock password once verified
                    obscureText: !controller.isPasswordVisible.value,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: KazinColors.textSecondary,
                        ),
                        onPressed: () => controller.isPasswordVisible.toggle(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Transition: Jab tak OTP sent nahi hua tabhi Continue button dikhega
              Obx(() {
                if (controller.isOtpSent.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: KazinColors.greenAcceptedBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_circle,
                          color: KazinColors.greenAcceptedText,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Credentials Verified",
                          style: TextStyle(
                            color: KazinColors.greenAcceptedText,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitLogin,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Continue"),
                );
              }),

              const SizedBox(height: 24),

              // OTP Section: Appears automatically when credentials succeed
              Obx(() {
                if (!controller.isOtpSent.value) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: KazinColors.borderSubtle),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: KazinColors.primaryNavy.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Enter verification code",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.isOtpSent.value = false;
                            },
                            child: const Text(
                              "Change",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Enter the six-digit code sent to your mobile.",
                        style: TextStyle(
                          color: KazinColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (index) => Container(
                            width: 44,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: KazinColors.borderSubtle,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: KazinColors.scaffoldBg,
                            ),
                            child: TextField(
                              controller: controller.otpControllers[index],
                              focusNode: controller.otpFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                counterText: "",
                                border: InputBorder.none,
                              ),
                              onChanged: (val) =>
                                  controller.onOtpDigitChanged(index, val),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submitVerifyOtp,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Verify & Enter"),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
