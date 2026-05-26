import 'package:flutter/material.dart';

class KpiData {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color iconColor;

  const KpiData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.iconColor,
  });
}

enum AlertSeverity { warning, danger, info }

class AbnormalAlert {
  final AlertSeverity severity;
  final IconData icon;
  final String title;
  final String description;

  const AbnormalAlert({
    required this.severity,
    required this.icon,
    required this.title,
    required this.description,
  });
}

class ZoneDistribution {
  final String name;
  final int percentFull;

  const ZoneDistribution({required this.name, required this.percentFull});
}

class QuickAction {
  final IconData icon;
  final String title;
  final String description;

  const QuickAction({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class CommandCenterMockData {
  static const List<KpiData> kpis = [
    KpiData(
      title: 'TOTAL OCCUPANCY',
      value: '84%',
      change: '4,210 / 5,000 active spots',
      icon: Icons.local_parking_outlined,
      iconColor: Color(0xFF0D2E9B),
    ),
    KpiData(
      title: 'REVENUE TODAY',
      value: '\$12,480',
      change: 'Pending processing: \$1,200',
      icon: Icons.payments_outlined,
      iconColor: Color(0xFF10B981),
    ),
    KpiData(
      title: 'ACTIVE VIOLATIONS',
      value: '42',
      change: '12 require immediate dispatch',
      icon: Icons.warning_amber_outlined,
      iconColor: Color(0xFFEF4444),
    ),
  ];

  static const List<AbnormalAlert> alerts = [
    AbnormalAlert(
      severity: AlertSeverity.warning,
      icon: Icons.access_time,
      title: 'Overstay: Zone B-4',
      description: 'Vehicle Plate: K-902-XLT  •  45m past limit',
    ),
    AbnormalAlert(
      severity: AlertSeverity.danger,
      icon: Icons.block,
      title: 'Unauthorised Entry: Staff Lot',
      description: 'Vehicle Plate: P-118-YJI  •  Unknown RFID',
    ),
    AbnormalAlert(
      severity: AlertSeverity.info,
      icon: Icons.electric_car_outlined,
      title: 'Wrong Zone: EV Only',
      description: 'Vehicle Plate: J-442-MND  •  Internal combustion detected',
    ),
  ];

  static const List<ZoneDistribution> zones = [
    ZoneDistribution(name: 'North Campus (Staff)', percentFull: 92),
    ZoneDistribution(name: 'South Deck (Student)', percentFull: 74),
    ZoneDistribution(name: 'Innovation Hub (Visitor)', percentFull: 30),
  ];

  static const List<QuickAction> quickActions = [
    QuickAction(
      icon: Icons.map_outlined,
      title: 'Premise Editor',
      description: 'Update zone boundaries and spot sensor configurations.',
    ),
    QuickAction(
      icon: Icons.verified_user_outlined,
      title: 'Permit Approval',
      description: 'Review and authorize new faculty parking requests.',
    ),
    QuickAction(
      icon: Icons.monitor_heart_outlined,
      title: 'System Health',
      description: 'Check sensor connectivity and API gateway status.',
    ),
  ];
}
