import 'dart:convert';

class TourFileModel {
  final int arrivalId;
  final String arrivalDate;
  final String groupType;
  final String leadName;
  final String leadIsdCode;
  final String leadContact;
  final String leadPhoto;
  final int hotelId;
  final String numberRooms;
  final int numAdults;
  final int numChild;
  final List<String> childAges;
  final int driverId;
  final String status;
  final String remarks;
  final int enquiryId;
  final String enquiryNo;
  final String enquiryAbbr;
  final int enquirySequence;
  final String mode;
  final int numberPersons;
  final String checkInDate;
  final String checkOutDate;
  final int numberOfNights;
  final String enquiryFor;
  final String enquiryType;
  final String enquiryRemarks;
  final int guideId;

  // Nested structures
  final List<ItineraryStepModel> itinerary;
  final List<FlightDetailModel> flights;
  final HotelBundleModel? hotel;
  final List<RestaurantDetailModel> restaurants;
  final List<PersonModel> persons;
  final DriverModel? driver;
  final TransportModel? transport;

  TourFileModel({
    required this.arrivalId,
    required this.arrivalDate,
    required this.groupType,
    required this.leadName,
    required this.leadIsdCode,
    required this.leadContact,
    required this.leadPhoto,
    required this.hotelId,
    required this.numberRooms,
    required this.numAdults,
    required this.numChild,
    required this.childAges,
    required this.driverId,
    required this.status,
    required this.remarks,
    required this.enquiryId,
    required this.enquiryNo,
    required this.enquiryAbbr,
    required this.enquirySequence,
    required this.mode,
    required this.numberPersons,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.enquiryFor,
    required this.enquiryType,
    required this.enquiryRemarks,
    required this.guideId,
    required this.itinerary,
    required this.flights,
    this.hotel,
    required this.restaurants,
    required this.persons,
    this.driver,
    this.transport,
  });

  factory TourFileModel.fromJson(Map<String, dynamic> json) {
    // 1. Safe Driver Parsing (List or Object or Empty)
    DriverModel? parsedDriver;
    if (json['driver'] is List && (json['driver'] as List).isNotEmpty) {
      parsedDriver = DriverModel.fromJson(json['driver'][0]);
    } else if (json['driver'] is Map<String, dynamic>) {
      parsedDriver = DriverModel.fromJson(json['driver']);
    }

    // 2. Safe Transport Parsing
    TransportModel? parsedTransport;
    if (json['transport'] is List && (json['transport'] as List).isNotEmpty) {
      parsedTransport = TransportModel.fromJson(json['transport'][0]);
    } else if (json['transport'] is Map<String, dynamic>) {
      parsedTransport = TransportModel.fromJson(json['transport']);
    }

    // 3. Safe Hotel Bundle Parsing (details + rooms)
    HotelBundleModel? parsedHotel;
    if (json['hotels'] is Map<String, dynamic>) {
      parsedHotel = HotelBundleModel.fromJson(json['hotels']);
    }

    // 4. Safe Child Ages Parsing
    List<String> parsedChildAges = [];
    final rawAges = json['child_ages'] ?? json['child_age'];
    if (rawAges is List) {
      parsedChildAges = rawAges.map((e) => e.toString()).toList();
    } else if (rawAges is String && rawAges.isNotEmpty && rawAges != "null") {
      try {
        final decoded = jsonDecode(rawAges);
        if (decoded is List) {
          parsedChildAges = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return TourFileModel(
      arrivalId: int.tryParse(json['arrival_id']?.toString() ?? '0') ?? 0,
      arrivalDate: json['arrival_date']?.toString() ?? '',
      groupType: json['group_type']?.toString() ?? 'Standard',
      leadName: json['lead_name']?.toString().trim() ?? '',
      leadIsdCode: json['lead_isd_code']?.toString() ?? '',
      leadContact: json['lead_contact']?.toString().trim() ?? '',
      leadPhoto: json['lead_photo']?.toString() ?? '',
      hotelId: int.tryParse(json['hotel_id']?.toString() ?? '0') ?? 0,
      numberRooms: json['number_rooms']?.toString() ?? '1',
      numAdults: int.tryParse(json['num_adults']?.toString() ?? '0') ?? 0,
      numChild: int.tryParse(json['num_child']?.toString() ?? '0') ?? 0,
      childAges: parsedChildAges,
      driverId: int.tryParse(json['driver_id']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'in-progress',
      remarks: json['remarks']?.toString() ?? '',
      enquiryId: int.tryParse(json['enquiry_id']?.toString() ?? '0') ?? 0,
      enquiryNo: json['enquiry_no']?.toString() ?? '',
      enquiryAbbr: json['enquiry_abbr']?.toString() ?? '',
      enquirySequence:
          int.tryParse(json['enquiry_sequence']?.toString() ?? '0') ?? 0,
      mode: json['mode']?.toString() ?? 'Email',
      numberPersons:
          int.tryParse(json['number_persons']?.toString() ?? '0') ?? 0,
      checkInDate: json['check_in_date']?.toString() ?? '',
      checkOutDate: json['check_out_date']?.toString() ?? '',
      numberOfNights:
          int.tryParse(json['number_of_nights']?.toString() ?? '0') ?? 0,
      enquiryFor: json['enquiry_for']?.toString() ?? '',
      enquiryType: json['enquiry_type']?.toString() ?? '',
      enquiryRemarks: json['enquiry_remarks']?.toString() ?? '',
      guideId: int.tryParse(json['guide_id']?.toString() ?? '0') ?? 0,

      // Nested Lists
      itinerary: (json['itinerary'] as List? ?? [])
          .map((e) => ItineraryStepModel.fromJson(e))
          .toList(),
      flights: (json['flights'] as List? ?? [])
          .map((e) => FlightDetailModel.fromJson(e))
          .toList(),
      restaurants: (json['restaurants'] as List? ?? [])
          .map((e) => RestaurantDetailModel.fromJson(e))
          .toList(),
      persons: (json['persons'] as List? ?? [])
          .map((e) => PersonModel.fromJson(e))
          .toList(),
      driver: parsedDriver,
      transport: parsedTransport,
      hotel: parsedHotel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arrival_id': arrivalId,
      'arrival_date': arrivalDate,
      'group_type': groupType,
      'lead_name': leadName,
      'lead_isd_code': leadIsdCode,
      'lead_contact': leadContact,
      'lead_photo': leadPhoto,
      'hotel_id': hotelId,
      'number_rooms': numberRooms,
      'num_adults': numAdults,
      'num_child': numChild,
      'child_ages': childAges,
      'driver_id': driverId,
      'status': status,
      'remarks': remarks,
      'enquiry_id': enquiryId,
      'enquiry_no': enquiryNo,
      'enquiry_abbr': enquiryAbbr,
      'enquiry_sequence': enquirySequence,
      'mode': mode,
      'number_persons': numberPersons,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'number_of_nights': numberOfNights,
      'enquiry_for': enquiryFor,
      'enquiry_type': enquiryType,
      'enquiry_remarks': enquiryRemarks,
      'guide_id': guideId,
      'itinerary': itinerary
          .map(
            (e) => {
              'id': e.id,
              'date': e.date,
              'time': e.time,
              'title': e.title,
              'content': e.content,
              'remarks': e.remarks,
              'is_completed': e.isCompleted,
              'completed_at': e.completedAt,
              'delay_reason': e.delayReason,
              'image': e.image,
            },
          )
          .toList(),
      'flights': flights
          .map(
            (e) => {
              'id': e.id,
              'flight_number': e.flightNumber,
              'departure_airport': e.departureAirport,
              'departure_city': e.departureCity,
              'arrival_city': e.arrivalCity,
              'departure_date': e.departureDate,
              'departure_time': e.departureTime,
              'flight_mode': e.flightMode,
              'name': e.airlineName,
              'code': e.airlineCode,
            },
          )
          .toList(),
      'persons': persons
          .map(
            (e) => {
              'first_name': e.fullName,
              'last_name': '',
              'nationality': e.nationality,
              'meals': e.meals,
              'smoking_status': e.smokingStatus,
            },
          )
          .toList(),
      if (driver != null)
        'driver': [
          {'driver_name': driver!.name, 'driver_phone_number': driver!.phone},
        ],
      if (transport != null)
        'transport': [
          {
            'vehicle_name': transport!.vehicleName,
            'vehicle_type': transport!.vehicleType,
            'capacity': transport!.capacity,
          },
        ],
    };
  }
}

// -------------------------------------------------------------
// SUB-MODELS
// -------------------------------------------------------------

class ItineraryStepModel {
  final int id;
  final String date;
  final String time;
  final String title;
  final String content;
  final String remarks;
  final int isCompleted;
  final String? completedAt;
  final String? delayReason;
  final String? image;

  ItineraryStepModel({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.content,
    required this.remarks,
    required this.isCompleted,
    this.completedAt,
    this.delayReason,
    this.image,
  });

  factory ItineraryStepModel.fromJson(Map<String, dynamic> json) {
    String cleanString(String? val) {
      if (val == null) return '';
      try {
        return Uri.decodeComponent(val)
            .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      } catch (_) {
        return val.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();
      }
    }

    final rawTitle = json['title_search']?.toString().isNotEmpty == true
        ? json['title_search']?.toString()
        : json['title']?.toString();

    return ItineraryStepModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      title: cleanString(rawTitle),
      content: cleanString(json['content']?.toString()),
      remarks: cleanString(json['remarks']?.toString()),
      isCompleted: int.tryParse(json['is_completed']?.toString() ?? '0') ?? 0,
      completedAt: json['completed_at']?.toString(),
      delayReason: json['delay_reason']?.toString(),
      image: json['image']?.toString(),
    );
  }
}

class FlightDetailModel {
  final int id;
  final String flightNumber;
  final String departureAirport;
  final String departureCity;
  final String arrivalCity;
  final String departureDate;
  final String departureTime;
  final String flightMode;
  final String airlineName;
  final String airlineCode;

  FlightDetailModel({
    required this.id,
    required this.flightNumber,
    required this.departureAirport,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureDate,
    required this.departureTime,
    required this.flightMode,
    required this.airlineName,
    required this.airlineCode,
  });

  factory FlightDetailModel.fromJson(Map<String, dynamic> json) {
    return FlightDetailModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      flightNumber: json['flight_number']?.toString() ?? '',
      departureAirport: json['departure_airport']?.toString() ?? '',
      departureCity: json['departure_city']?.toString() ?? '',
      arrivalCity: json['arrival_city']?.toString() ?? '',
      departureDate: json['departure_date']?.toString() ?? '',
      departureTime: json['departure_time']?.toString() ?? '',
      flightMode: json['flight_mode']?.toString() ?? 'inbound',
      airlineName: json['name']?.toString() ?? 'Airline',
      airlineCode: json['code']?.toString() ?? '',
    );
  }
}

class HotelBundleModel {
  final int hotelId;
  final String hotelName;
  final String category;
  final String address;
  final String city;
  final String country;
  final String mapUrl;
  final String contactNumber;
  final String email;
  final String description;
  final List<HotelRoomModel> rooms;

  HotelBundleModel({
    required this.hotelId,
    required this.hotelName,
    required this.category,
    required this.address,
    required this.city,
    required this.country,
    required this.mapUrl,
    required this.contactNumber,
    required this.email,
    required this.description,
    required this.rooms,
  });

  factory HotelBundleModel.fromJson(Map<String, dynamic> json) {
    int hId = 0;
    String name = '';
    String category = '4 Star';
    String address = '';
    String city = '';
    String country = '';
    String map = '';
    String mobile = '';
    String email = '';
    String desc = '';

    if (json['details'] is List && (json['details'] as List).isNotEmpty) {
      final d = json['details'][0];
      hId = int.tryParse(d['hotel_id']?.toString() ?? '0') ?? 0;
      name = d['hotel_name']?.toString() ?? '';
      category = d['category']?.toString() ?? '4 Star';
      address = "${d['address_1'] ?? ''} ${d['address_2'] ?? ''}".trim();
      city = d['city']?.toString() ?? '';
      country = d['country']?.toString() ?? '';
      map = d['map']?.toString() ?? '';
      final isd = d['isd_codes']?.toString() ?? '';
      final mob = d['mobile']?.toString() ?? '';
      mobile = isd.isNotEmpty ? "$isd $mob" : mob;
      email = d['email']?.toString() ?? '';
      desc = d['description']?.toString() ?? '';
    }

    final parsedRooms = <HotelRoomModel>[];
    if (json['rooms'] is List) {
      for (var r in json['rooms']) {
        parsedRooms.add(HotelRoomModel.fromJson(r));
      }
    }

    return HotelBundleModel(
      hotelId: hId,
      hotelName: name.isNotEmpty ? name : "Hotel Accommodation",
      category: category,
      address: address,
      city: city,
      country: country,
      mapUrl: map,
      contactNumber: mobile,
      email: email,
      description: desc,
      rooms: parsedRooms,
    );
  }
}

class HotelRoomModel {
  final int roomId;
  final int bookingId;
  final String roomType;
  final String numberOfRooms;
  final int numberAdults;
  final int numberChild;
  final String childBed;
  final bool hasBreakfast;
  final String confirmationNum;
  final String roomSize;
  final String capacity;
  final String categoryDescription;
  final String categoryImage;

  HotelRoomModel({
    required this.roomId,
    required this.bookingId,
    required this.roomType,
    required this.numberOfRooms,
    required this.numberAdults,
    required this.numberChild,
    required this.childBed,
    required this.hasBreakfast,
    required this.confirmationNum,
    required this.roomSize,
    required this.capacity,
    required this.categoryDescription,
    required this.categoryImage,
  });

  factory HotelRoomModel.fromJson(Map<String, dynamic> json) {
    return HotelRoomModel(
      roomId: int.tryParse(json['room_id']?.toString() ?? '0') ?? 0,
      bookingId: int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
      roomType: (json['room_type'] ?? json['category'] ?? 'Standard Room')
          .toString()
          .trim(),
      numberOfRooms: (json['number_of_rooms'] ?? '1').toString(),
      numberAdults: int.tryParse(json['number_adults']?.toString() ?? '2') ?? 2,
      numberChild: int.tryParse(json['number_child']?.toString() ?? '0') ?? 0,
      childBed: (json['child_bed'] ?? 'N/A').toString(),
      hasBreakfast: (json['breakfast']?.toString().toLowerCase() == 'yes'),
      confirmationNum: (json['hotel_confirmation_num'] ?? '').toString().trim(),
      roomSize: (json['room_size'] ?? '').toString().trim(),
      capacity: (json['capacity_per_room'] ?? '').toString().trim(),
      categoryDescription: (json['category_description'] ?? '')
          .toString()
          .trim(),
      categoryImage: (json['category_image'] ?? '').toString().trim(),
    );
  }
}

class RestaurantDetailModel {
  final int id;
  final String name;
  final String date;
  final String buffetType;
  final String cuisine;
  final String openingTime;
  final String closingTime;
  final String address;
  final String contactNumber;
  final String mapUrl;

  RestaurantDetailModel({
    required this.id,
    required this.name,
    required this.date,
    required this.buffetType,
    required this.cuisine,
    required this.openingTime,
    required this.closingTime,
    required this.address,
    required this.contactNumber,
    required this.mapUrl,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailModel(
      id:
          int.tryParse(
            json['restaurant_id']?.toString() ?? json['id']?.toString() ?? '0',
          ) ??
          0,
      name: json['name']?.toString() ?? 'Restaurant',
      date: json['date']?.toString() ?? '',
      buffetType: json['buffet']?.toString() ?? 'Dinner',
      cuisine: json['cuisine']?.toString() ?? 'Multi-Cuisine',
      openingTime: json['opening_time']?.toString() ?? '',
      closingTime: json['closing_time']?.toString() ?? '',
      address: json['restaurant_address']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      mapUrl: json['map']?.toString() ?? '',
    );
  }
}

class PersonModel {
  final String fullName;
  final String nationality;
  final String meals;
  final String smokingStatus;

  PersonModel({
    required this.fullName,
    required this.nationality,
    required this.meals,
    required this.smokingStatus,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    final first = json['first_name']?.toString().trim() ?? '';
    final last = json['last_name']?.toString().trim() ?? '';
    return PersonModel(
      fullName: "$first $last".trim(),
      nationality: json['nationality']?.toString().toUpperCase() ?? 'INDIAN',
      meals: json['meals']?.toString() ?? 'Veg',
      smokingStatus: json['smoking_status']?.toString() ?? 'Non-Smoking',
    );
  }
}

class DriverModel {
  final String name;
  final String phone;

  DriverModel({required this.name, required this.phone});

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      name:
          json['driver_name']?.toString() ??
          json['name']?.toString() ??
          'Assigned Driver',
      phone:
          json['driver_phone_number']?.toString() ??
          json['phone']?.toString() ??
          '',
    );
  }
}

class TransportModel {
  final String vehicleName;
  final String vehicleType;
  final int capacity;

  TransportModel({
    required this.vehicleName,
    required this.vehicleType,
    required this.capacity,
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      vehicleName: json['vehicle_name']?.toString() ?? 'Vehicle',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      capacity: int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
    );
  }
}
