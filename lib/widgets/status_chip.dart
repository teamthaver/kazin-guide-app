import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum KazinStatus {
  newAssignment,
  pending,
  accepted,
  ready,
  enRoute,
  arrived,
  inService,
  completed,
  actionRequired,
}

class StatusChip extends StatelessWidget {
  final KazinStatus status;
  final String? customLabel;

  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        customLabel ?? config.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusChipConfig _getStatusConfig(KazinStatus status) {
    switch (status) {
      case KazinStatus.accepted:
        return const _StatusChipConfig(
          label: "ACCEPTED",
          backgroundColor: KazinColors.greenAcceptedBg,
          textColor: KazinColors.greenAcceptedText,
        );
      case KazinStatus.actionRequired:
        return const _StatusChipConfig(
          label: "ACTION REQUIRED",
          backgroundColor: KazinColors.amberWarningBg,
          textColor: KazinColors.amberWarningText,
        );
      case KazinStatus.newAssignment:
        return const _StatusChipConfig(
          label: "NEW",
          backgroundColor: KazinColors.blueInfoBg,
          textColor: KazinColors.primaryBlue,
        );
      case KazinStatus.enRoute:
        return const _StatusChipConfig(
          label: "EN ROUTE",
          backgroundColor: KazinColors.blueInfoBg,
          textColor: KazinColors.primaryBlue,
        );
      case KazinStatus.ready:
        return const _StatusChipConfig(
          label: "READY",
          backgroundColor: KazinColors.lightTeal,
          textColor: KazinColors.secondaryTeal,
        );
      case KazinStatus.completed:
        return const _StatusChipConfig(
          label: "COMPLETED",
          backgroundColor: Color(0xFFF1F5F9),
          textColor: KazinColors.textSecondary,
        );
      case KazinStatus.pending:
      case KazinStatus.arrived:
      case KazinStatus.inService:
        return const _StatusChipConfig(
          label: "IN SERVICE",
          backgroundColor: KazinColors.blueInfoBg,
          textColor: KazinColors.primaryNavy,
        );
    }
  }
}

class _StatusChipConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusChipConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}