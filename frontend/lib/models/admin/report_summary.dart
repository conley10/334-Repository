class ReportSummary {
  final int totalUsers;
  final int totalZones;
  final int totalSpots;
  final int totalViolations;

  const ReportSummary({
    required this.totalUsers,
    required this.totalZones,
    required this.totalSpots,
    required this.totalViolations,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
        totalZones: (json['totalZones'] as num?)?.toInt() ?? 0,
        totalSpots: (json['totalSpots'] as num?)?.toInt() ?? 0,
        totalViolations: (json['totalViolations'] as num?)?.toInt() ?? 0,
      );
}
