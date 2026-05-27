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
      zoneID: json['zoneID'] as int,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      maxDuration: json['maxDuration'] as int,
      accessLevel: json['accessLevel'] as String,
      zoneType: json['zoneType'] as String,
    );
  }
}