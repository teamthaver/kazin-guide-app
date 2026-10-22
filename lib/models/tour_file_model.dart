class TourFileModel {
  final int arrivalId;
  final String arrivalDate;
  final int guideId;
  final String groupType;
  final String leadName;
  final String leadContact;
  final String status;
  final int enquiryId;
  final String enquiryNo;
  final int numberPersons;
  final String checkInDate;
  final String checkOutDate;
  final String numberOfNights;
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
    required this.guideId,
    required this.groupType,
    required this.leadName,
    required this.leadContact,
    required this.status,
    required this.enquiryId,
    required this.enquiryNo,
    required this.numberPersons,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.itinerary,
    required this.flights,
    this.hotel,
    required this.restaurants,
    required this.persons,
    this.driver,
    this.transport,
  });

  factory TourFileModel.fromJson(Map<String, dynamic> json) {
    return TourFileModel(
      arrivalId: json['arrival_id'] ?? 0,
      arrivalDate: json['arrival_date'] ?? '',
      guideId: json['guide_id'] ?? 0,
      groupType: json['group_type'] ?? 'General',
      leadName: json['lead_name'] ?? 'Guest Group',
      leadContact:
          "+${json['lead_isd_code'] ?? '91'} ${json['lead_contact'] ?? ''}"
              .trim(),
      status: json['status'] ?? 'pending',
      enquiryId: json['enquiry_id'] ?? 0,
      enquiryNo: json['enquiry_no'] ?? '',
      numberPersons:
          int.tryParse(json['number_persons']?.toString() ?? '1') ?? 1,
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      numberOfNights: json['number_of_nights']?.toString() ?? '1',
      itinerary: (json['itinerary'] as List? ?? [])
          .map((i) => ItineraryStepModel.fromJson(i))
          .toList(),
      flights: (json['flights'] as List? ?? [])
          .map((f) => FlightDetailModel.fromJson(f))
          .toList(),
      hotel: json['hotels'] is Map<String, dynamic>
          ? HotelBundleModel.fromJson(json['hotels'])
          : null,
      restaurants: (json['restaurants'] as List? ?? [])
          .map((r) => RestaurantDetailModel.fromJson(r))
          .toList(),
      persons: (json['persons'] as List? ?? [])
          .map((p) => PersonModel.fromJson(p))
          .toList(),
      driver: (json['driver'] as List? ?? []).isNotEmpty
          ? DriverModel.fromJson(json['driver'][0])
          : null,
      transport: (json['transport'] as List? ?? []).isNotEmpty
          ? TransportModel.fromJson(json['transport'][0])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'arrival_id': arrivalId,
    'arrival_date': arrivalDate,
    'guide_id': guideId,
    'group_type': groupType,
    'lead_name': leadName,
    'lead_contact': leadContact,
    'status': status,
    'enquiry_id': enquiryId,
    'enquiry_no': enquiryNo,
    'number_persons': numberPersons,
    'check_in_date': checkInDate,
    'check_out_date': checkOutDate,
    'number_of_nights': numberOfNights,
    'itinerary': itinerary.map((i) => i.toJson()).toList(),
    'flights': flights.map((f) => f.toJson()).toList(),
    'hotels': hotel?.toJson(),
    'restaurants': restaurants.map((r) => r.toJson()).toList(),
    'persons': persons.map((p) => p.toJson()).toList(),
    'driver': driver != null ? [driver!.toJson()] : [],
    'transport': transport != null ? [transport!.toJson()] : [],
  };

  // Unique operational tour days list
  List<String> get uniqueTourDates {
    final dates = itinerary
        .map((e) => e.date.split('T')[0])
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    dates.sort();
    return dates;
  }
}

// 1. Itinerary Step Item
class ItineraryStepModel {
  final int id;
  final String date;
  final String time;
  final String title;
  final String content;
  final String remarks;
  final bool isCompleted;

  ItineraryStepModel({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.content,
    required this.remarks,
    required this.isCompleted,
  });

  factory ItineraryStepModel.fromJson(Map<String, dynamic> json) {
    String cleanTitle = (json['title_search'] ?? '').toString().trim();
    if (cleanTitle.isEmpty) {
      cleanTitle = _cleanText(json['title']);
    }

    return ItineraryStepModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      title: cleanTitle.isNotEmpty ? cleanTitle : _cleanText(json['content']),
      content: _cleanText(json['content']),
      remarks: _cleanText(json['remarks']),
      isCompleted: json['is_completed'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'time': time,
    'title_search': title,
    'content': content,
    'remarks': remarks,
    'is_completed': isCompleted ? 1 : 0,
  };

  static String _cleanText(String? raw) {
    if (raw == null || raw.isEmpty) return "";
    try {
      String decoded = Uri.decodeComponent(raw);
      decoded = decoded.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
      return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (_) {
      return raw.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
    }
  }
}

class FlightDetailModel {
  final int id;
  final String flightNumber;
  final String departureAirport;
  final String arrivalCity;
  final String departureDate;
  final String departureTime;
  final String flightMode;
  final String airlineName;

  FlightDetailModel({
    required this.id,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalCity,
    required this.departureDate,
    required this.departureTime,
    required this.flightMode,
    required this.airlineName,
  });

  factory FlightDetailModel.fromJson(Map<String, dynamic> json) =>
      FlightDetailModel(
        id: json['id'] ?? 0,
        flightNumber: json['flight_number'] ?? '',
        departureAirport: json['departure_airport'] ?? '',
        arrivalCity: json['arrival_city'] ?? '',
        departureDate: json['departure_date'] ?? '',
        departureTime: json['departure_time'] ?? '',
        flightMode: json['flight_mode'] ?? 'inbound',
        airlineName: json['name'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'flight_number': flightNumber,
    'departure_airport': departureAirport,
    'arrival_city': arrivalCity,
    'departure_date': departureDate,
    'departure_time': departureTime,
    'flight_mode': flightMode,
    'name': airlineName,
  };
}

// 3. Hotel Bundle
class HotelBundleModel {
  final String hotelName;
  final String category;
  final String city;
  final String address;
  final String roomCategory;
  final String confirmationNum;

  HotelBundleModel({
    required this.hotelName,
    required this.category,
    required this.city,
    required this.address,
    required this.roomCategory,
    required this.confirmationNum,
  });

  factory HotelBundleModel.fromJson(Map<String, dynamic> json) {
    final details = (json['details'] as List? ?? []);
    final rooms = (json['rooms'] as List? ?? []);

    final detailFirst = details.isNotEmpty ? details[0] : {};
    final roomFirst = rooms.isNotEmpty ? rooms[0] : {};

    return HotelBundleModel(
      hotelName: detailFirst['hotel_name'] ?? roomFirst['name'] ?? 'Hotel',
      category: detailFirst['category'] ?? 'Standard',
      city: detailFirst['city'] ?? '',
      address:
          "${detailFirst['address_1'] ?? ''} ${detailFirst['address_2'] ?? ''}"
              .trim(),
      roomCategory: roomFirst['category'] ?? 'Standard Room',
      confirmationNum: roomFirst['hotel_confirmation_num']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'details': [
      {
        'hotel_name': hotelName,
        'category': category,
        'city': city,
        'address_1': address,
      },
    ],
    'rooms': [
      {'category': roomCategory, 'hotel_confirmation_num': confirmationNum},
    ],
  };
}

// 4. Restaurant Detail
class RestaurantDetailModel {
  final int id;
  final String name;
  final String cuisine;
  final String buffetType;
  final String contactNumber;
  final String address;
  final String mapUrl;
  final String openingTime;
  final String closingTime;
  final String date;

  RestaurantDetailModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.buffetType,
    required this.contactNumber,
    required this.address,
    required this.mapUrl,
    required this.openingTime,
    required this.closingTime,
    required this.date,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) =>
      RestaurantDetailModel(
        id: json['id'] ?? json['restaurant_id'] ?? 0,
        name: json['name']?.toString() ?? '',
        cuisine: json['cuisine']?.toString() ?? 'Indian',
        buffetType:
            json['buffet']?.toString() ??
            json['buffet_type']?.toString() ??
            'Dinner',
        contactNumber: json['contact_number']?.toString() ?? '',
        address:
            json['restaurant_address']?.toString() ??
            json['address']?.toString() ??
            '',
        mapUrl: json['map']?.toString() ?? json['map_url']?.toString() ?? '',
        openingTime: json['opening_time']?.toString() ?? '',
        closingTime: json['closing_time']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cuisine': cuisine,
    'buffet': buffetType,
    'contact_number': contactNumber,
    'restaurant_address': address,
    'map': mapUrl,
    'opening_time': openingTime,
    'closing_time': closingTime,
    'date': date,
  };
}

// 5. Driver & Vehicle Models
class DriverModel {
  final String name;
  final String phone;

  DriverModel({required this.name, required this.phone});

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
    name: json['driver_name'] ?? 'Assigned Driver',
    phone: json['driver_phone_number'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'driver_name': name,
    'driver_phone_number': phone,
  };
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

  factory TransportModel.fromJson(Map<String, dynamic> json) => TransportModel(
    vehicleName: json['vehicle_name'] ?? 'Vehicle',
    vehicleType: json['vehicle_type'] ?? '',
    capacity: json['capacity'] ?? 3,
  );

  Map<String, dynamic> toJson() => {
    'vehicle_name': vehicleName,
    'vehicle_type': vehicleType,
    'capacity': capacity,
  };
}

// 6. Person Model
class PersonModel {
  final String fullName;
  final String nationality;
  final String meals;

  PersonModel({
    required this.fullName,
    required this.nationality,
    required this.meals,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
    fullName: "${json['first_name'] ?? ''} ${json['last_name'] ?? ''}".trim(),
    nationality: json['nationality'] ?? 'India',
    meals: json['meals'] ?? 'veg',
  );

  Map<String, dynamic> toJson() => {
    'first_name': fullName,
    'nationality': nationality,
    'meals': meals,
  };
}
