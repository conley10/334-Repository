class Zone {
  final int zoneID;
  final String name;
  final int capacity;
  final double pricePerHour;
  final int maxDuration;
  final String accessLevel;
  final String zoneType;

  const Zone({
    required this.zoneID,
    required this.name,
    required this.capacity,
    required this.pricePerHour,
    required this.maxDuration,
    required this.accessLevel,
    required this.zoneType,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      zoneID: json['zoneID'],
      name: json['name'],
      capacity: json['capacity'],
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      maxDuration: json['maxDuration'],
      accessLevel: json['accessLevel'],
      zoneType: json['zoneType'],
    );
  }
}