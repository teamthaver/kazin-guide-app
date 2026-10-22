class AssignmentSummaryModel {
  final int enquiryId;
  final int arrivalId;
  final String leadName;
  final String leadContact;
  final String checkInDate;
  final String checkOutDate;
  final String arrivalDate;
  final String numberOfNights;
  final int numberPersons;
  final int numberChild;
  final int isAccepted;
  final int open;

  AssignmentSummaryModel({
    required this.enquiryId,
    required this.arrivalId,
    required this.leadName,
    required this.leadContact,
    required this.checkInDate,
    required this.checkOutDate,
    required this.arrivalDate,
    required this.numberOfNights,
    required this.numberPersons,
    required this.numberChild,
    this.isAccepted = 0,
    this.open = 0,
  });

  factory AssignmentSummaryModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return AssignmentSummaryModel(
      enquiryId: toInt(json['enquiry_id']),
      arrivalId: toInt(json['arrival_id']),
      leadName: (json['lead_name']?.toString() ?? '').trim(),
      leadContact: (json['lead_contact']?.toString() ?? '').trim(),
      checkInDate: json['check_in_date']?.toString() ?? '',
      checkOutDate: json['check_out_date']?.toString() ?? '',
      arrivalDate: json['arrival_date']?.toString() ?? '',
      numberOfNights: json['number_of_nights']?.toString() ?? '0',
      numberPersons: toInt(json['number_persons']),
      numberChild: toInt(json['number_child']),
      isAccepted: toInt(json['is_accepted']),
      open: toInt(json['open']),
    );
  }
}
