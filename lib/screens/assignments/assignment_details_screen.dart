import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:kazin_guide_app/controllers/app_controller.dart';
import 'package:kazin_guide_app/controllers/assignment_details_controller.dart';
import 'package:kazin_guide_app/controllers/assignments_controller.dart';
import 'package:kazin_guide_app/controllers/notifications_controller.dart';
import 'package:kazin_guide_app/core/routes/app_pages.dart';
import 'package:kazin_guide_app/core/theme/app_theme.dart';
import 'package:kazin_guide_app/models/tour_file_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentDetailsScreen extends StatelessWidget {
  final TourFileModel? tourFile;
  final bool isNewAssignment;

  const AssignmentDetailsScreen({
    super.key,
    this.tourFile,
    this.isNewAssignment = false,
  });

  Future<void> _openWhatsApp({
    required String phone,
    String isdCode = '',
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    String cleanIsd = isdCode.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.isEmpty) return;

    String fullNumber = cleanPhone;
    if (cleanIsd.isNotEmpty && !cleanPhone.startsWith(cleanIsd)) {
      fullNumber = '$cleanIsd$cleanPhone';
    }

    final Uri whatsappNativeUri = Uri.parse(
      "whatsapp://send?phone=$fullNumber",
    );
    final Uri whatsappWebUri = Uri.parse("https://wa.me/$fullNumber");

    try {
      if (await canLaunchUrl(whatsappNativeUri)) {
        await launchUrl(
          whatsappNativeUri,
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      } else {
        final Uri telUri = Uri.parse("tel:$fullNumber");
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      }
    } catch (_) {
      final Uri telUri = Uri.parse("tel:$fullNumber");
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssignmentDetailsController());
    final assignmentsCtrl = Get.isRegistered<AssignmentsController>()
        ? Get.find<AssignmentsController>()
        : Get.put(AssignmentsController());

    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final bool showAssignmentActions =
        isNewAssignment || (args?["isNewAssignment"] == true);

    return Obx(() {
      // 1. Loading State Check
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: KazinColors.scaffoldBg,
          appBar: AppBar(
            title: const Text(
              "Tour Dossier",
              style: TextStyle(
                color: KazinColors.primaryNavy,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(color: KazinColors.primaryNavy),
          ),
        );
      }

      // 2. Resolve Tour File Model
      final TourFileModel? file =
          tourFile ?? args?["tourFile"] ?? controller.tourFile.value;

      if (file == null) {
        return Scaffold(
          backgroundColor: KazinColors.scaffoldBg,
          appBar: AppBar(
            title: const Text(
              "Tour Dossier",
              style: TextStyle(
                color: KazinColors.primaryNavy,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
          ),
          body: const Center(
            child: Text(
              "No dossier details available.",
              style: TextStyle(
                color: KazinColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

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
            file.enquiryNo.isNotEmpty
                ? "File-${file.enquiryNo}"
                : "File-${file.arrivalId}",
            style: const TextStyle(
              color: KazinColors.primaryNavy,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          // actions: [
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //     margin: const EdgeInsets.only(right: 14),
          //     decoration: BoxDecoration(
          //       color: showAssignmentActions
          //           ? KazinColors.blueInfoBg
          //           : (isClosed
          //                 ? KazinColors.borderSubtle
          //                 : KazinColors.greenAcceptedBg),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: Text(
          //       showAssignmentActions
          //           ? "NEW ASSIGNMENT"
          //           : file.status.toUpperCase(),
          //       style: TextStyle(
          //         fontSize: 10,
          //         fontWeight: FontWeight.bold,
          //         color: showAssignmentActions
          //             ? KazinColors.primaryBlue
          //             : (isClosed
          //                   ? KazinColors.textSecondary
          //                   : KazinColors.greenAcceptedText),
          //       ),
          //     ),
          //   ),
          // ],
        ),
        bottomNavigationBar: showAssignmentActions
            ? _buildAssignmentActionsBar(context, assignmentsCtrl, file)
            : null,
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _buildLeadHeader(controller, file, sortedDates),
              const SizedBox(height: 14),
              if (file.persons.isNotEmpty) ...[
                _buildGuestsSection(file.persons, file),
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
                _buildHotelSection(controller, file.hotel!, file),
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
        ),
      );
    });
  }

  // --- 1. Actions Bottom Bar ---
  Widget _buildAssignmentActionsBar(
    BuildContext context,
    AssignmentsController assignmentsCtrl,
    TourFileModel file,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: KazinColors.borderSubtle)),
      ),
      child: SafeArea(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KazinColors.greenAcceptedText,
                    minimumSize: const Size.fromHeight(50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: assignmentsCtrl.isActionLoading.value
                      ? null
                      : () async {
                          final bool isSuccess = await assignmentsCtrl
                              .acceptTourFile(file);

                          if (isSuccess) {
                            if (Get.isRegistered<NotificationsController>()) {
                              Get.find<NotificationsController>()
                                  .removeAssignmentNotification();
                            }

                            if (Get.isRegistered<KazinController>()) {
                              Get.find<KazinController>()
                                      .hasUnreadAlerts
                                      .value =
                                  false;
                            }

                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }
                        },
                  child: assignmentsCtrl.isActionLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Accept Assignment",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KazinColors.redDanger,
                    side: const BorderSide(color: KazinColors.redDanger),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: assignmentsCtrl.isActionLoading.value
                      ? null
                      : () {
                          Get.toNamed(
                            Routes.DECLINE_ASSIGNMENT,
                            arguments: {
                              "enquiryId": file.enquiryId,
                              "arrivalId": file.arrivalId,
                              "leadName": file.leadName,
                            },
                          );
                        },
                  child: const Text(
                    "Decline Assignment",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. Lead & Header Section (NO PAX - ONLY ADULTS, CHILD & GROUP TYPE) ---
  Widget _buildLeadHeader(
    AssignmentDetailsController controller,
    TourFileModel file,
    List<String> dates,
  ) {
    final start = dates.isNotEmpty
        ? controller.formatShortDate(dates.first)
        : (file.checkInDate.isNotEmpty
              ? controller.formatShortDate(file.checkInDate)
              : "");
    final end = dates.isNotEmpty
        ? controller.formatShortDate(dates.last)
        : (file.checkOutDate.isNotEmpty
              ? controller.formatShortDate(file.checkOutDate)
              : "");

    final contactDisplay = file.leadContact.isNotEmpty
        ? "${file.leadIsdCode.isNotEmpty ? '+${file.leadIsdCode} ' : ''}${file.leadContact}"
        : "No Contact";

    // Format guests: e.g., "2 Adults, 1 Child • Family" ya "2 Adults • FIT"
    final int adults = file.numAdults > 0 ? file.numAdults : file.numberPersons;
    final int children = file.numChild;
    final String guestsCountText = children > 0
        ? "$adults Adults, $children Child"
        : "$adults Adults";
    final String groupTypeText = file.groupType.isNotEmpty
        ? file.groupType
        : "Standard";

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
                    file.leadName.isNotEmpty ? file.leadName : "Group Tour",
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
                    "$guestsCountText • $groupTypeText",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: KazinColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openWhatsApp(
                    phone: file.leadContact,
                    isdCode: file.leadIsdCode,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KazinColors.greenAcceptedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          contactDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: KazinColors.greenAcceptedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (start.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KazinColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      end.isNotEmpty ? "$start → $end" : start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  // --- 3. Passengers Section ---
  Widget _buildGuestsSection(List<PersonModel> persons, TourFileModel file) {
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
                Text(
                  file.numChild > 0
                      ? "${file.numAdults} Adults, ${file.numChild} Child"
                      : "${file.numAdults > 0 ? file.numAdults : file.numberPersons} Adults",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

  // --- 4. Flights Section ---
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
                        "${f.airlineName} ${f.flightNumber}".trim(),
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
                            "Date: ${controller.formatShortDate(f.departureDate)} • ${f.departureTime}",
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

  // --- 5. Transport & Driver Section ---
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
                          driver.phone.isNotEmpty
                              ? "Driver Contact: ${driver.phone}"
                              : "No driver phone assigned",
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
                        child: FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                      onPressed: () => _openWhatsApp(phone: driver.phone),
                    ),
                ],
              ),
            if (transport != null) ...[
              if (driver != null) const SizedBox(height: 10),
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

  // --- 6. Hotel & Rooms Allocation Section ---
  Widget _buildHotelSection(
    AssignmentDetailsController controller,
    HotelBundleModel hotel,
    TourFileModel file,
  ) {
    final String fullLocation = [
      if (hotel.address.isNotEmpty) hotel.address,
      if (hotel.city.isNotEmpty) hotel.city,
      if (hotel.country.isNotEmpty) hotel.country,
    ].join(', ');

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: KazinColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      size: 20,
                      color: KazinColors.primaryBlue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Hotel Accommodation",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: KazinColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        hotel.category.isNotEmpty ? hotel.category : "Hotel",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              hotel.hotelName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: KazinColors.primaryNavy,
              ),
            ),
            if (fullLocation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: KazinColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      fullLocation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: KazinColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (hotel.contactNumber.isNotEmpty || hotel.mapUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (hotel.contactNumber.isNotEmpty)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _openWhatsApp(phone: hotel.contactNumber),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: KazinColors.greenAcceptedBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              size: 13,
                              color: KazinColors.greenAcceptedText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hotel.contactNumber,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: KazinColors.greenAcceptedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (hotel.contactNumber.isNotEmpty && hotel.mapUrl.isNotEmpty)
                    const SizedBox(width: 8),
                  if (hotel.mapUrl.isNotEmpty)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => controller.safeLaunch(hotel.mapUrl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: KazinColors.blueInfoBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 13,
                              color: KazinColors.primaryBlue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "View Location",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: KazinColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              "Room Allocation & Inclusions",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: KazinColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            // Safe fallback agar rooms null ya empty hon
            if (hotel.rooms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: KazinColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: KazinColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.meeting_room_outlined,
                      size: 16,
                      color: KazinColors.primaryNavy,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.numberRooms.isNotEmpty && file.numberRooms != "0"
                            ? "${file.numberRooms} Room Allocated (Standard Inclusions)"
                            : "Standard Room Allocation Confirmed",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...hotel.rooms.asMap().entries.map((entry) {
                final rIndex = entry.key + 1;
                final room = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KazinColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KazinColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              hotel.rooms.length > 1
                                  ? "Room $rIndex: ${room.roomType}"
                                  : room.roomType,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: KazinColors.primaryNavy,
                              ),
                            ),
                          ),
                          if (room.confirmationNum.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: KazinColors.blueInfoBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Confirmation ID: ${room.confirmationNum}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: KazinColors.primaryBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildBadgePill(
                            icon: Icons.meeting_room_outlined,
                            label: "${room.numberOfRooms} Room",
                          ),
                          _buildBadgePill(
                            icon: Icons.person_outline,
                            label:
                                "${room.numberAdults} Adults${room.numberChild > 0 ? ', ${room.numberChild} Child' : ''}",
                          ),
                          if (room.roomSize.isNotEmpty)
                            _buildBadgePill(
                              icon: Icons.square_foot_rounded,
                              label: room.roomSize,
                            ),
                          if (room.hasBreakfast)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: KazinColors.greenAcceptedBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.free_breakfast_rounded,
                                    size: 11,
                                    color: KazinColors.greenAcceptedText,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Breakfast Included",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: KazinColors.greenAcceptedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (room.categoryDescription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          room.categoryDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: KazinColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgePill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KazinColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: KazinColors.primaryNavy),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: KazinColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Day-Wise Section (Day x of totalDays) ---
  Widget _buildDayWiseSection(
    AssignmentDetailsController controller,
    List<String> sortedDates,
    Map<String, List<ItineraryStepModel>> groupedItinerary,
  ) {
    final int totalDays = sortedDates.length;

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
            height: 58,
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
                    width: 92,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
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
                          "Day ${index + 1} of $totalDays",
                          style: TextStyle(
                            fontSize: 11,
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
                        child: Text("No activities scheduled for this day"),
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

  // --- 8. Restaurants Section ---
  Widget _buildRestaurantsSection(
    AssignmentDetailsController controller,
    List<RestaurantDetailModel> restaurants,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.restaurant_rounded,
                size: 18,
                color: KazinColors.primaryBlue,
              ),
              SizedBox(width: 8),
              Text(
                "Confirmed Dining Reservations",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: KazinColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...restaurants.map((r) {
          final String formattedMealDate = r.date.isNotEmpty
              ? controller.formatShortDate(r.date)
              : "";

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KazinColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: KazinColors.primaryNavy,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              r.buffetType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: KazinColors.secondaryTeal.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              r.cuisine.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: KazinColors.secondaryTeal,
                              ),
                            ),
                          ),
                          if (formattedMealDate.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              "• $formattedMealDate",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: KazinColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: KazinColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (r.openingTime.isNotEmpty && r.closingTime.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: KazinColors.scaffoldBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: KazinColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Open: ${r.openingTime}  –  Close: ${r.closingTime}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: KazinColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (r.address.isNotEmpty)
                        Text(
                          r.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: KazinColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (r.contactNumber.isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _openWhatsApp(phone: r.contactNumber),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KazinColors.greenAcceptedBg,
                              border: Border.all(
                                color: KazinColors.greenAcceptedText.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: KazinColors.greenAcceptedText,
                            ),
                          ),
                        ),
                      ),
                    if (r.contactNumber.isNotEmpty && r.mapUrl.isNotEmpty)
                      const SizedBox(width: 8),
                    if (r.mapUrl.isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => controller.safeLaunch(r.mapUrl),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KazinColors.blueInfoBg,
                              border: Border.all(
                                color: KazinColors.primaryBlue.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.navigation_outlined,
                              size: 18,
                              color: KazinColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
