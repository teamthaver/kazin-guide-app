import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/assignment_details_controller.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/controllers/notifications_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';

class AssignmentDetailsScreen extends StatelessWidget {
  final TourFileModel? tourFile;
  final bool isNewAssignment;

  const AssignmentDetailsScreen({
    super.key,
    this.tourFile,
    this.isNewAssignment = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssignmentDetailsController());
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final TourFileModel? file = tourFile ?? args?["tourFile"];
    final bool showAssignmentActions =
        isNewAssignment || (args?["isNewAssignment"] == true);

    if (file == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Tour Dossier")),
        body: const Center(child: Text("No dossier available")),
      );
    }

    final bool isClosed = file.status.toLowerCase().contains("closed");
    final groupedItinerary = controller.groupByDate(file.itinerary);
    final sortedDates = groupedItinerary.keys.toList()..sort();

    return Scaffold(
      backgroundColor: KazinColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "File #${file.enquiryNo}",
          style: const TextStyle(
            color: KazinColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: showAssignmentActions
                  ? KazinColors.blueInfoBg
                  : (isClosed
                        ? KazinColors.borderSubtle
                        : KazinColors.greenAcceptedBg),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              showAssignmentActions
                  ? "NEW ASSIGNMENT"
                  : file.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: showAssignmentActions
                    ? KazinColors.primaryBlue
                    : (isClosed
                          ? KazinColors.textSecondary
                          : KazinColors.greenAcceptedText),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: showAssignmentActions
          ? _buildAssignmentActionsBar(file)
          : null,
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildLeadHeader(controller, file, sortedDates),
          const SizedBox(height: 14),
          if (file.persons.isNotEmpty) ...[
            _buildGuestsSection(file.persons),
            const SizedBox(height: 14),
          ],
          if (file.flights.isNotEmpty) ...[
            _buildFlightsSection(controller, file.flights),
            const SizedBox(height: 14),
          ],
          if (file.driver != null || file.transport != null) ...[
            _buildCompleteTransportSection(
              controller,
              file.driver,
              file.transport,
            ),
            const SizedBox(height: 14),
          ],
          if (file.hotel != null) ...[
            _buildHotelSection(file.hotel!),
            const SizedBox(height: 14),
          ],
          if (sortedDates.isNotEmpty) ...[
            _buildDayWiseSection(controller, sortedDates, groupedItinerary),
            const SizedBox(height: 14),
          ],
          if (file.restaurants.isNotEmpty) ...[
            _buildRestaurantsSection(controller, file.restaurants),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignmentActionsBar(TourFileModel file) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: KazinColors.borderSubtle)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: KazinColors.redDanger,
                  side: const BorderSide(color: KazinColors.redDanger),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.toNamed(
                    Routes.DECLINE_ASSIGNMENT,
                    arguments: {"tourFile": file},
                  );
                },
                child: const Text("Decline Assignment"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KazinColors.greenAcceptedText,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // 1. Add to Upcoming Assignments
                  final assignmentsCtrl =
                      Get.isRegistered<AssignmentsController>()
                      ? Get.find<AssignmentsController>()
                      : Get.put(AssignmentsController());
                  assignmentsCtrl.addUpcomingAssignment(file);

                  // 2. Remove assignment card from Notifications Screen
                  if (Get.isRegistered<NotificationsController>()) {
                    Get.find<NotificationsController>()
                        .removeAssignmentNotification();
                  }

                  // 3. Remove red dot badge from navigation bar
                  if (Get.isRegistered<KazinController>()) {
                    Get.find<KazinController>().hasUnreadAlerts.value = false;
                  }

                  Get.back(); // Return to previous screen

                  Get.snackbar(
                    "Assignment Accepted!",
                    "File #${file.enquiryNo} added to your Upcoming Assignments.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: KazinColors.greenAcceptedText,
                    icon: const Icon(
                      Icons.check_circle,
                      color: KazinColors.greenAcceptedText,
                    ),
                  );
                },
                child: const Text("Accept Assignment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Lead & Summary ---
  Widget _buildLeadHeader(
    AssignmentDetailsController controller,
    TourFileModel file,
    List<String> dates,
  ) {
    final start = dates.isNotEmpty
        ? controller.formatShortDate(dates.first)
        : "";
    final end = dates.isNotEmpty ? controller.formatShortDate(dates.last) : "";
    final totalDays = dates.length;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    file.leadName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: KazinColors.primaryNavy,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: KazinColors.blueInfoBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${file.numberPersons} PAX • ${file.groupType}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: KazinColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => controller.safeLaunch(
                    'tel:${file.leadContact.replaceAll(RegExp(r'[^0-9+]'), '')}',
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 15,
                        color: KazinColors.secondaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        file.leadContact,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.secondaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (start.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: KazinColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "$start → $end (${totalDays > 0 ? totalDays - 1 : file.numberOfNights}N/${totalDays > 0 ? totalDays : 1}D)",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: KazinColors.primaryNavy,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Guest List ---
  Widget _buildGuestsSection(List<PersonModel> persons) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  size: 18,
                  color: KazinColors.primaryBlue,
                ),
                SizedBox(width: 8),
                Text(
                  "Passenger Information",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KazinColors.primaryNavy,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            ...persons.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final p = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      "$idx.",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: KazinColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: KazinColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${p.nationality.toUpperCase()} • ${p.meals.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: KazinColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- Flight Section ---
  Widget _buildFlightsSection(
    AssignmentDetailsController controller,
    List<FlightDetailModel> flights,
  ) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.flight_takeoff_rounded,
                  size: 18,
                  color: KazinColors.primaryBlue,
                ),
                SizedBox(width: 8),
                Text(
                  "Flight Itinerary",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KazinColors.primaryNavy,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            ...flights.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KazinColors.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${f.airlineName} ${f.flightNumber}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${f.flightMode.toUpperCase()}: ${f.departureAirport.split('-')[0]} → ${f.arrivalCity}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Date: ${controller.formatShortDate(f.departureDate)} • Departure: ${f.departureTime}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: KazinColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Transport Section ---
  Widget _buildCompleteTransportSection(
    AssignmentDetailsController controller,
    DriverModel? driver,
    TransportModel? transport,
  ) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 18,
                  color: KazinColors.primaryBlue,
                ),
                SizedBox(width: 8),
                Text(
                  "Transport & Assigned Driver",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KazinColors.primaryNavy,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            if (driver != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Driver Contact: ${driver.phone}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (driver.phone.isNotEmpty)
                    IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: KazinColors.greenAcceptedBg,
                        radius: 17,
                        child: Icon(
                          Icons.call,
                          size: 17,
                          color: KazinColors.greenAcceptedText,
                        ),
                      ),
                      onPressed: () => controller.safeLaunch(
                        'tel:${driver.phone.replaceAll(RegExp(r'[^0-9+]'), '')}',
                      ),
                    ),
                ],
              ),
            if (transport != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: KazinColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Vehicle: ${transport.vehicleName}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Capacity: ${transport.capacity} Seats",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (transport.vehicleType.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Types: ${transport.vehicleType}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: KazinColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Hotel Section ---
  Widget _buildHotelSection(HotelBundleModel hotel) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.hotel_rounded,
                      size: 18,
                      color: KazinColors.primaryBlue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Hotel Accommodation",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Text(
                    hotel.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Text(
              hotel.hotelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            if (hotel.address.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                "${hotel.address}, ${hotel.city}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: KazinColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Room: ${hotel.roomCategory}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Voucher #: ${hotel.confirmationNum}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: KazinColors.secondaryTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Day Wise Section with Obx ---
  Widget _buildDayWiseSection(
    AssignmentDetailsController controller,
    List<String> sortedDates,
    Map<String, List<ItineraryStepModel>> groupedItinerary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            "Tour Itinerary",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: KazinColors.primaryNavy,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final selectedIdx = controller.selectedDayIndex.value;

          return SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sortedDates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIdx;
                final dateStr = sortedDates[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => controller.selectDay(index),
                  child: Container(
                    width: 78,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? KazinColors.primaryNavy
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? KazinColors.primaryNavy
                            : KazinColors.borderSubtle,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Day ${index + 1}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : KazinColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.formatShortDate(dateStr),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.tealAccent
                                : KazinColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
        const SizedBox(height: 12),
        Obx(() {
          final idx = controller.selectedDayIndex.value;
          final validIdx = (idx < sortedDates.length) ? idx : 0;
          final selectedDateStr = sortedDates.isNotEmpty
              ? sortedDates[validIdx]
              : "";
          final steps = sortedDates.isNotEmpty
              ? (groupedItinerary[selectedDateStr] ?? [])
              : <ItineraryStepModel>[];

          return Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: steps.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No activities scheduled"),
                      ),
                    )
                  : Column(
                      children: List.generate(steps.length, (sIdx) {
                        final step = steps[sIdx];
                        final isLast = sIdx == steps.length - 1;
                        final hasRemarksOrTicket = step.remarks.isNotEmpty;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: hasRemarksOrTicket
                                          ? KazinColors.secondaryTeal
                                          : KazinColors.primaryNavy,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 1.5,
                                        color: KazinColors.borderSubtle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 44,
                                child: Text(
                                  step.time,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: KazinColors.primaryNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: KazinColors.textPrimary,
                                        ),
                                      ),
                                      if (step.content.isNotEmpty &&
                                          step.content != step.title) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          step.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: KazinColors.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                      if (hasRemarksOrTicket) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.teal.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.confirmation_num_outlined,
                                                size: 13,
                                                color:
                                                    KazinColors.secondaryTeal,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  step.remarks,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: KazinColors
                                                        .secondaryTeal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ),
          );
        }),
      ],
    );
  }

  // --- Restaurants Section ---
  Widget _buildRestaurantsSection(
    AssignmentDetailsController controller,
    List<RestaurantDetailModel> restaurants,
  ) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  size: 18,
                  color: KazinColors.primaryBlue,
                ),
                SizedBox(width: 8),
                Text(
                  "Confirmed Meals & Locations",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KazinColors.primaryNavy,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            ...restaurants.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${r.cuisine.toUpperCase()} • ${r.buffetType} • ${r.address}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: KazinColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (r.mapUrl.isNotEmpty)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: KazinColors.primaryBlue,
                        ),
                        onPressed: () => controller.safeLaunch(r.mapUrl),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
