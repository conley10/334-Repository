class BookingModel {
  final int bookingID;
  final DateTime startTime;
  final DateTime endTime;
  final int userID;
  final int spotID;
  final int vehicleID;
  final String status;

  const BookingModel({
    required this.bookingID,
    required this.startTime,
    required this.endTime,
    required this.userID,
    required this.spotID,
    required this.vehicleID,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingID: json['bookingID'] as int,
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      userID: json['userID'] as int,
      spotID: json['spotID'] as int,
      vehicleID: json['vehicleID'] as int,
      status: json['status'] as String? ?? 'upcoming',
    );
  }
}