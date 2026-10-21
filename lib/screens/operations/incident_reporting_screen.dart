import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazin_guide_app/controllers/incident_reporting_controller.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'emergency_sos_screen.dart';

class IncidentReportingScreen extends StatelessWidget {
  const IncidentReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(IncidentReportingController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
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
            const Text(
              "Tell us what happened so the operations team can help.",
              style: TextStyle(color: KazinColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Document category chips
            const Text(
              "Category",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ctrl.categoryMap.keys.map((cat) {
                  final isSel = ctrl.selectedCategoryKey.value == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (_) => ctrl.setCategory(cat),
                    selectedColor: KazinColors.primaryNavy,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : KazinColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
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
                  ctrl: ctrl,
                  onTap: () => ctrl.setSeverity("Normal"),
                ),
                const SizedBox(width: 8),
                _buildSeverityCard(
                  title: "Urgent",
                  icon: Icons.warning_amber_rounded,
                  activeColor: KazinColors.amberWarningText,
                  activeBgColor: KazinColors.amberWarningBg,
                  ctrl: ctrl,
                  onTap: () => ctrl.setSeverity("Urgent"),
                ),
                const SizedBox(width: 8),
                _buildSeverityCard(
                  title: "Emergency",
                  icon: Icons.error_outline_rounded,
                  activeColor: KazinColors.redDanger,
                  activeBgColor: KazinColors.redDangerBg,
                  ctrl: ctrl,
                  onTap: () {
                    ctrl.setSeverity("Emergency");
                    Get.to(() => const EmergencySosScreen());
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Description *",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KazinColors.borderSubtle),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: ctrl.issueCtrl,
                maxLines: 4,
                minLines: 3,
                style: const TextStyle(
                  fontSize: 14,
                  color: KazinColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: "What happened? Describe the issue in detail...",
                  hintStyle: TextStyle(
                    color: KazinColors.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl.locationCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Where did this happen? (optional)",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KazinColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KazinColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photo Evidence Section (Max 5 image files)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Photo Evidence",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Obx(
                  () => Text(
                    "${ctrl.attachedImages.length} / 5",
                    style: const TextStyle(
                      fontSize: 12,
                      color: KazinColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(() {
              if (ctrl.attachedImages.isEmpty) return const SizedBox.shrink();

              return Column(
                children: [
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ctrl.attachedImages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                ctrl.attachedImages[idx],
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => ctrl.removeImage(idx),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),

            OutlinedButton.icon(
              onPressed: () => _showPhotoPickerSheet(context, ctrl),
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text("Attach Photo"),
              style: OutlinedButton.styleFrom(
                foregroundColor: KazinColors.primaryNavy,
                minimumSize: const Size.fromHeight(46),
                side: const BorderSide(color: KazinColors.borderSubtle),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Obx(
              () => ElevatedButton(
                onPressed: ctrl.isSubmitting.value ? null : ctrl.submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.redDanger,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: ctrl.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Submit Incident",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPhotoPickerSheet(
    BuildContext context,
    IncidentReportingController ctrl,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: KazinColors.primaryNavy,
              ),
              title: const Text("Take Photo with Camera"),
              onTap: () {
                Get.back();
                ctrl.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: KazinColors.primaryNavy,
              ),
              title: const Text("Select from Gallery"),
              onTap: () {
                Get.back();
                ctrl.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSeverityCard({
    required String title,
    required IconData icon,
    required Color activeColor,
    required Color activeBgColor,
    required IncidentReportingController ctrl,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = ctrl.selectedSeverity.value == title;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
