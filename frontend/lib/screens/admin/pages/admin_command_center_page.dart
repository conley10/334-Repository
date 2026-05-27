import 'package:flutter/material.dart';
import '../../../models/admin/command_center_data.dart';
import '../../../models/admin/parking_zone.dart';
import '../../../models/admin/report_summary.dart';
import '../../../services/admin/reports_service.dart';
import '../../../services/admin/violations_service.dart';
import '../../../services/admin/zone_service.dart';
import '../widgets/admin_page_header.dart';

class AdminCommandCenterPage extends StatefulWidget {
  const AdminCommandCenterPage({super.key});

  @override
  State<AdminCommandCenterPage> createState() => _AdminCommandCenterPageState();
}

class _AdminCommandCenterPageState extends State<AdminCommandCenterPage> {
  final ReportsService _reportsService = ReportsService();
  final ZoneService _zoneService = ZoneService();
  final ViolationsService _violationsService = ViolationsService();

  ReportSummary? _summary;
  List<ParkingZone>? _zones;
  List<AbnormalAlert>? _alerts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _reportsService.getReportSummary(),
        _zoneService.getZones(),
        _violationsService.getRecentAlerts(limit: 5),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as ReportSummary;
        _zones = results[1] as List<ParkingZone>;
        _alerts = results[2] as List<AbnormalAlert>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'Command Center',
          subtitle: 'Real-time oversight of campus mobility infrastructure.',
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          _buildError()
        else ...[
          _buildKpiRow(),
          const SizedBox(height: 24),
          _buildAlertsAndZones(),
          const SizedBox(height: 32),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D24),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 40, color: Color(0xFFDC2626)),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loadAll,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0D2E9B)),
        ),
      ]),
    );
  }

  Widget _buildKpiRow() {
    final kpis = [
      KpiData(
        title: 'TOTAL USERS',
        value: '${_summary?.totalUsers ?? 0}',
        change: 'Registered accounts',
        icon: Icons.people_outline,
        iconColor: const Color(0xFF0D2E9B),
      ),
      KpiData(
        title: 'TOTAL ZONES',
        value: '${_summary?.totalZones ?? 0}',
        change: 'Parking zones configured',
        icon: Icons.location_on_outlined,
        iconColor: const Color(0xFF10B981),
      ),
      KpiData(
        title: 'TOTAL SPOTS',
        value: '${_summary?.totalSpots ?? 0}',
        change: 'Across all zones',
        icon: Icons.local_parking_outlined,
        iconColor: const Color(0xFF0D2E9B),
      ),
      KpiData(
        title: 'TOTAL VIOLATIONS',
        value: '${_summary?.totalViolations ?? 0}',
        change: 'Reported incidents',
        icon: Icons.warning_amber_outlined,
        iconColor: const Color(0xFFEF4444),
      ),
    ];
    return Row(
      children: [
        for (int i = 0; i < kpis.length; i++) ...[
          Expanded(child: _KpiCard(data: kpis[i])),
          if (i < kpis.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildAlertsAndZones() {
    // TODO(backend): availableSpots is mocked equal to totalSpots; percentFull will always be 0 until backend exposes the real available count.
    final zoneDist = (_zones ?? []).map((z) {
      final pct = z.totalSpots > 0
          ? ((z.totalSpots - z.availableSpots) / z.totalSpots * 100).round()
          : 0;
      return ZoneDistribution(name: z.name, percentFull: pct);
    }).toList();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: _AlertsCard(alerts: _alerts ?? [])),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: _ZoneDistributionCard(zones: zoneDist)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        for (int i = 0; i < CommandCenterMockData.quickActions.length; i++) ...[
          Expanded(child: _QuickActionCard(data: CommandCenterMockData.quickActions[i])),
          if (i < CommandCenterMockData.quickActions.length - 1)
            const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final KpiData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(data.icon, size: 20, color: data.iconColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.change,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.alerts});
  final List<AbnormalAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Abnormal Activity Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D24),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'EXPORT LOG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No active alerts',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            for (final alert in alerts) ...[
              _AlertRow(alert: alert),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});
  final AbnormalAlert alert;

  Color _bgColor() {
    switch (alert.severity) {
      case AlertSeverity.warning: return const Color(0xFFFEF3C7);
      case AlertSeverity.danger:  return const Color(0xFFFEE2E2);
      case AlertSeverity.info:    return const Color(0xFFE0F2FE);
    }
  }

  Color _iconColor() {
    switch (alert.severity) {
      case AlertSeverity.warning: return const Color(0xFFD97706);
      case AlertSeverity.danger:  return const Color(0xFFDC2626);
      case AlertSeverity.info:    return const Color(0xFF0284C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _bgColor(), shape: BoxShape.circle),
            child: Icon(alert.icon, size: 18, color: _iconColor()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D24),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'View Details',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D2E9B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneDistributionCard extends StatelessWidget {
  const _ZoneDistributionCard({required this.zones});
  final List<ZoneDistribution> zones;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zone Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D24),
            ),
          ),
          const SizedBox(height: 16),
          for (final zone in zones) ...[
            _ZoneBar(zone: zone),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          const Text(
            'Next peak expected in 2 hours for evening lectures.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneBar extends StatelessWidget {
  const _ZoneBar({required this.zone});
  final ZoneDistribution zone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                zone.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1D24),
                ),
              ),
            ),
            Text(
              '${zone.percentFull}% Full',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: zone.percentFull / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D2E9B)),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data});
  final QuickAction data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(data.icon, size: 28, color: const Color(0xFF0D2E9B)),
            const SizedBox(height: 16),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
