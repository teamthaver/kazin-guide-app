enum MealBilling { prepaid, directPayment, none }

enum StepType {
  airportPickup,
  transfer,
  sightseeing,
  meal,
  hotelCheckIn,
  hotelCheckOut,
  shopping,
  airportDrop,
}

class TourTaskStep {
  final int stepNumber;
  final String time;
  final String title;
  final String remarks;
  final String? restaurantName;
  final MealBilling mealBilling;
  final bool voucherRequired;
  final String? voucherDocId;
  final bool isCompleted;

  TourTaskStep({
    required this.stepNumber,
    required this.time,
    required this.title,
    this.remarks = "",
    this.restaurantName,
    this.mealBilling = MealBilling.none,
    this.voucherRequired = false,
    this.voucherDocId,
    this.isCompleted = false,
  });
}

class DailyItinerary {
  final int dayNumber;
  final DateTime date;
  final String dateDisplay;
  final String driverName;
  final String driverPhone;
  final String vehicleName;
  final String vehicleCapacity; 
  final List<TourTaskStep> tasks;

  DailyItinerary({
    required this.dayNumber,
    required this.date,
    required this.dateDisplay,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleName,
    required this.vehicleCapacity,
    required this.tasks,
  });
}
