import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'emergency_sos_screen.dart';

class IncidentReportingScreen extends StatelessWidget {
  const IncidentReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      "Guest Issue",
      "Vehicle Issue",
      "Hotel Issue",
      "Restaurant Issue",
      "Ticket Issue",
      "Medical Situation",
      "Complaint",
      "Other",
    ];
    final selectedCategory = "Guest Issue".obs;
    final selectedSeverity = "Normal".obs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Report an Issue",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text("Report an Issue", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            // const SizedBox(height: 6),
            const Text(
              "Tell us what happened so the operations team can help.",
              style: TextStyle(color: KazinColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map(
                    (cat) => Obx(() {
                      final isSel = selectedCategory.value == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        onSelected: (val) => selectedCategory.value = cat,
                        selectedColor: KazinColors.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : KazinColors.textPrimary,
                        ),
                      );
                    }),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Severity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildSeverityCard(
                  title: "Normal",
                  icon: Icons.check_circle_outline_rounded,
                  activeColor: KazinColors.secondaryTeal,
                  activeBgColor: KazinColors.lightTeal,
                  selectedSeverity: selectedSeverity,
                  onTap: () => selectedSeverity.value = "Normal",
                ),
                const SizedBox(width: 8),
                _buildSeverityCard(
                  title: "Urgent",
                  icon: Icons.warning_amber_rounded,
                  activeColor: KazinColors.amberWarningText,
                  activeBgColor: KazinColors.amberWarningBg,
                  selectedSeverity: selectedSeverity,
                  onTap: () => selectedSeverity.value = "Urgent",
                ),
                const SizedBox(width: 8),
                _buildSeverityCard(
                  title: "Emergency",
                  icon: Icons.error_outline_rounded,
                  activeColor: KazinColors.redDanger,
                  activeBgColor: KazinColors.redDangerBg,
                  selectedSeverity: selectedSeverity,
                  onTap: () {
                    selectedSeverity.value = "Emergency";
                    Get.to(() => const EmergencySosScreen());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KazinColors.borderSubtle),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: Column(
                children: [
                  const TextField(
                    maxLines: 4,
                    minLines: 3,
                    style: TextStyle(
                      fontSize: 14,
                      color: KazinColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "What happened?",
                      hintStyle: TextStyle(
                        color: KazinColors.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showAttachmentBottomSheet(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.attach_file_rounded,
                            color: KazinColors.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: KazinColors.redDanger,
              ),
              child: const Text("Submit Incident"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KazinColors.borderSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add Attachment",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: KazinColors.primaryNavy,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Photo",
                  bgColor: const Color(0xFFEFF6FF),
                  iconColor: KazinColors.primaryBlue,
                  onTap: () {
                    Get.back();
                    // TODO: Image picker photo
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam_rounded,
                  label: "Video",
                  bgColor: const Color(0xFFFEE2E2),
                  iconColor: KazinColors.redDanger,
                  onTap: () {
                    Get.back();
                    // TODO: Video picker
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.mic_rounded,
                  label: "Audio",
                  bgColor: KazinColors.lightTeal,
                  iconColor: KazinColors.secondaryTeal,
                  onTap: () {
                    Get.back();
                    // TODO: Voice record
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: "Document",
                  bgColor: const Color(0xFFFEF3C7),
                  iconColor: KazinColors.amberWarningText,
                  onTap: () {
                    Get.back();
                    // TODO: Document picker
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: bgColor,
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: KazinColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityCard({
    required String title,
    required IconData icon,
    required Color activeColor,
    required Color activeBgColor,
    required RxString selectedSeverity,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = selectedSeverity.value == title;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeBgColor.withValues(alpha: 0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? activeColor : KazinColors.borderSubtle,
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? activeColor : KazinColors.textMuted,
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : KazinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
