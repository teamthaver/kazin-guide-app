import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum BannerType { offline, savedLocally, synced, syncFailed }

class OfflineBanner extends StatelessWidget {
  final BannerType type;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.type = BannerType.offline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (type == BannerType.savedLocally) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.wifi_off_outlined, size: 14, color: KazinColors.textMuted),
          SizedBox(width: 6),
          Text(
            "Saved locally — waiting to sync",
            style: TextStyle(
              color: KazinColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final isOffline = type == BannerType.offline;
    final isSynced = type == BannerType.synced;

    final bgColor = isOffline
        ? KazinColors.blueInfoBg
        : (isSynced ? KazinColors.greenAcceptedBg : KazinColors.redDangerBg);

    final textColor = isOffline
        ? KazinColors.primaryNavy
        : (isSynced ? KazinColors.greenAcceptedText : KazinColors.redDanger);

    final icon = isOffline
        ? Icons.wifi_off_rounded
        : (isSynced ? Icons.check_circle_outline : Icons.error_outline);

    final text = isOffline
        ? "Offline — essential data available"
        : (isSynced ? "Synced successfully" : "Sync failed — Tap to retry");

    return InkWell(
      onTap: type == BannerType.syncFailed ? onRetry : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}