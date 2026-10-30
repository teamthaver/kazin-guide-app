// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kazin_guide_app/controllers/app_controller.dart';
// import 'package:kazin_guide_app/core/theme/app_theme.dart';
// import 'service_execution_screen.dart';

// class ReadinessChecklistScreen extends StatelessWidget {
//   const ReadinessChecklistScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<KazinController>();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           "Ready for Service?",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         actions: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
//             decoration: BoxDecoration(
//               color: KazinColors.amberWarningBg,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Center(
//               child: Text(
//                 "4 / 5",
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: KazinColors.amberWarningText,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Ready for Service?",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Complete these checks before marking ready.",
//               style: TextStyle(color: KazinColors.textSecondary),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Text(
//                   "Checklist progress",
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 Text(
//                   "4 / 5 completed",
//                   style: TextStyle(
//                     color: KazinColors.primaryBlue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             LinearProgressIndicator(
//               value: 0.8,
//               color: KazinColors.primaryBlue,
//               backgroundColor: KazinColors.borderSubtle,
//               minHeight: 6,
//             ),
//             const SizedBox(height: 24),
//             Expanded(
//               child: Obx(
//                 () => ListView(
//                   children: ctrl.checklistState.entries
//                       .map(
//                         (entry) => Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(14),
//                             border: Border.all(color: KazinColors.borderSubtle),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Row(
//                                   children: [
//                                     Checkbox(
//                                       value: entry.value,
//                                       onChanged: (val) =>
//                                           ctrl.toggleChecklistItem(entry.key),
//                                       activeColor: KazinColors.primaryBlue,
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         entry.key,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               const SizedBox(width: 8),

//                               Icon(
//                                 entry.value
//                                     ? Icons.check_circle_outline
//                                     : Icons.radio_button_unchecked,
//                                 color: entry.value
//                                     ? KazinColors.greenAcceptedText
//                                     : KazinColors.textMuted,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => Get.to(() => const ServiceExecutionScreen()),
//               child: const Text("Mark Ready"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
