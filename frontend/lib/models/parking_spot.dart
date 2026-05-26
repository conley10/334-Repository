class ParkingSpot {
  final int spotID;
  final String spotNumber;
  final String status;
  final int zoneID;

  const ParkingSpot({
    required this.spotID,
    required this.spotNumber,
    required this.status,
    required this.zoneID,
  });

  bool get isAvailable => status.toLowerCase() == 'available';

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      spotID: json['spotID'] as int,
      spotNumber: json['spotNumber'] as String,
      status: json['status'] as String,
      zoneID: json['zoneID'] as int,
    );
  }
}