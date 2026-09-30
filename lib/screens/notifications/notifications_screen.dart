import 'package:flutter/material.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ["All", "Assignments", "Changes", "Reminders", "Urgent"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: filters
                  .map(
                    (f) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(f),
                        backgroundColor: f == "All"
                            ? KazinColors.primaryNavy
                            : Colors.white,
                        labelStyle: TextStyle(
                          color: f == "All"
                              ? Colors.white
                              : KazinColors.textPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: KazinColors.borderSubtle,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "No new notifications",
                style: TextStyle(color: KazinColors.textMuted, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
