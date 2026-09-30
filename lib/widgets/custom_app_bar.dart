import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import 'kazin_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBrandLogo;
  final bool showBackButton;
  final bool showOfflineBadge;
  final List<Widget>? customActions;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBrandLogo = false,
    this.showBackButton = false,
    this.showOfflineBadge = false,
    this.customActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: KazinColors.primaryNavy,
              ),
              onPressed: () => Get.back(),
            )
          : null,
      title: showBrandLogo
          ? const KazinLogo(height: 28)
          : Text(
              title ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
            ),
      actions: [
        if (showOfflineBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: KazinColors.borderSubtle),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.wifi_off,
                  size: 13,
                  color: KazinColors.textSecondary,
                ),
                SizedBox(width: 5),
                Text(
                  "Offline",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: KazinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        if (customActions != null) ...customActions!,
        const SizedBox(width: 16),
      ],
    );
  }
}
