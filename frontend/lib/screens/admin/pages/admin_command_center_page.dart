import 'package:flutter/material.dart';
import '../../../models/admin/command_center_data.dart';
import '../widgets/admin_page_header.dart';

class AdminCommandCenterPage extends StatelessWidget {
  const AdminCommandCenterPage({super.key});

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
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        for (int i = 0; i < CommandCenterMockData.kpis.length; i++) ...[
          Expanded(child: _KpiCard(data: CommandCenterMockData.kpis[i])),
          if (i < CommandCenterMockData.kpis.length - 1)
            const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildAlertsAndZones() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: _AlertsCard()),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: _ZoneDistributionCard()),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        for (int i = 0; i < CommandCenterMockData.quickActions.length; i++) ...[
          Expanded(
            child: _QuickActionCard(data: CommandCenterMockData.quickActions[i]),
          ),
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
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
          for (final alert in CommandCenterMockData.alerts) ...[
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
      case AlertSeverity.warning:
        return const Color(0xFFFEF3C7);
      case AlertSeverity.danger:
        return const Color(0xFFFEE2E2);
      case AlertSeverity.info:
        return const Color(0xFFE0F2FE);
    }
  }

  Color _iconColor() {
    switch (alert.severity) {
      case AlertSeverity.warning:
        return const Color(0xFFD97706);
      case AlertSeverity.danger:
        return const Color(0xFFDC2626);
      case AlertSeverity.info:
        return const Color(0xFF0284C7);
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
            decoration: BoxDecoration(
              color: _bgColor(),
              shape: BoxShape.circle,
            ),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
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
          for (final zone in CommandCenterMockData.zones) ...[
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
