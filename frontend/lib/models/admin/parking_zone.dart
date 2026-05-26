enum ZoneType { staff, student, visitor, ev, accessible }

enum ZoneStatus { active, maintenance, closed }

class ParkingZone {
  final int? zoneID;
  final String name;
  final ZoneType type;
  final int totalSpots;
  final int availableSpots;
  final double hourlyRate;
  final ZoneStatus status;

  const ParkingZone({
    this.zoneID,
    required this.name,
    required this.type,
    required this.totalSpots,
    required this.availableSpots,
    required this.hourlyRate,
    required this.status,
  });

  int get occupiedSpots => totalSpots - availableSpots;
  int get occupancyPercent => totalSpots == 0 ? 0 : ((occupiedSpots / totalSpots) * 100).round();

  String get typeLabel {
    switch (type) {
      case ZoneType.staff: return 'Staff';
      case ZoneType.student: return 'Student';
      case ZoneType.visitor: return 'Visitor';
      case ZoneType.ev: return 'EV Charging';
      case ZoneType.accessible: return 'Accessible';
    }
  }

  String get statusLabel {
    switch (status) {
      case ZoneStatus.active: return 'Active';
      case ZoneStatus.maintenance: return 'Maintenance';
      case ZoneStatus.closed: return 'Closed';
    }
  }

  factory ParkingZone.fromJson(Map<String, dynamic> json) {
    return ParkingZone(
      zoneID: json['zoneID'] as int?,
      name: json['name'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      totalSpots: json['totalSpots'] as int? ?? 0,
      availableSpots: json['availableSpots'] as int? ?? 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status'] as String?),
    );
  }

  static ZoneType _parseType(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'staff': return ZoneType.staff;
      case 'student': return ZoneType.student;
      case 'visitor': return ZoneType.visitor;
      case 'ev': case 'ev_charging': return ZoneType.ev;
      case 'accessible': return ZoneType.accessible;
      default: return ZoneType.visitor;
    }
  }

  static ZoneStatus _parseStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'active': return ZoneStatus.active;
      case 'maintenance': return ZoneStatus.maintenance;
      case 'closed': return ZoneStatus.closed;
      default: return ZoneStatus.active;
    }
  }

  ParkingZone copyWith({
    int? zoneID,
    String? name,
    ZoneType? type,
    int? totalSpots,
    int? availableSpots,
    double? hourlyRate,
    ZoneStatus? status,
  }) {
    return ParkingZone(
      zoneID: zoneID ?? this.zoneID,
      name: name ?? this.name,
      type: type ?? this.type,
      totalSpots: totalSpots ?? this.totalSpots,
      availableSpots: availableSpots ?? this.availableSpots,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      status: status ?? this.status,
    );
  }
}
