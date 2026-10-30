class AssignmentSummaryModel {
  final int enquiryId;
  final int arrivalId;
  final String checkInDate;
  final String checkOutDate;
  final String arrivalDate;
  final String groupType;
  final int isAccepted;
  final int numberOfNights;
  final String leadName;
  final String leadContact;
  final int numberPersons;
  final int numberChild;
  final String tripState; // 'upcoming' ya 'ongoing'

  AssignmentSummaryModel({
    required this.enquiryId,
    required this.arrivalId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.arrivalDate,
    required this.groupType,
    required this.isAccepted,
    required this.numberOfNights,
    required this.leadName,
    required this.leadContact,
    required this.numberPersons,
    required this.numberChild,
    this.tripState = '',
  });

  factory AssignmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return AssignmentSummaryModel(
      enquiryId: int.tryParse(json['enquiry_id']?.toString() ?? '0') ?? 0,
      arrivalId: int.tryParse(json['arrival_id']?.toString() ?? '0') ?? 0,
      checkInDate: json['check_in_date']?.toString() ?? '',
      checkOutDate: json['check_out_date']?.toString() ?? '',
      arrivalDate: json['arrival_date']?.toString() ?? '',
      groupType: json['group_type']?.toString() ?? 'Standard',
      isAccepted: int.tryParse(json['is_accepted']?.toString() ?? '0') ?? 0,
      numberOfNights:
          int.tryParse(json['number_of_nights']?.toString() ?? '0') ?? 0,
      leadName: json['lead_name']?.toString() ?? '',
      leadContact: json['lead_contact']?.toString() ?? '',
      numberPersons:
          int.tryParse(json['number_persons']?.toString() ?? '0') ?? 0,
      numberChild: int.tryParse(json['number_child']?.toString() ?? '0') ?? 0,
      tripState: json['trip_state']?.toString() ?? '',
    );
  }

  /// Client-side check-in difference calculation
  DateTime? get parsedCheckInDate {
    try {
      final target = arrivalDate.isNotEmpty ? arrivalDate : checkInDate;
      if (target.isEmpty) return null;
      return DateTime.parse(target.trim());
    } catch (_) {
      return null;
    }
  }

  /// Check-in me kitne din bache hain
  int get calculatedDaysToStart {
    final dt = parsedCheckInDate;
    if (dt == null) return 0;
    final now = DateTime.now();
    // Midnight to midnight comparison (Date level)
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dt.year, dt.month, dt.day);
    return targetDate.difference(today).inDays;
  }

  /// 48 Hours Check (Agar check-in 48 hours ya 2 din ke andar hai, toh true)
  bool get isDetailsUnlocked {
    final dt = parsedCheckInDate;
    if (dt == null) return false;
    final now = DateTime.now();

    // 1. Agar check-in date pass ho chuki hai (ongoing trip)
    if (now.isAfter(dt)) return true;

    // 2. Exact 48 hours (yaani <= 2 din) ka window
    final differenceInHours = dt.difference(now).inHours;
    return differenceInHours <= 48;
  }
}
